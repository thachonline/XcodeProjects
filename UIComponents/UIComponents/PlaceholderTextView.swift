import UIKit

/// inspired  https://github.com/MoZhouqi/KMPlaceholderTextView
class PlaceholderTextView: UITextView {
    
    private let systemPlaceholderColor: UIColor = {
        if #available(iOS 13.0, *) {
            return .systemGray3
        } else {
            return UIColor(red: 0.0, green: 0.0, blue: 0.0980392, alpha: 0.22)
        }
    }()
    
    let placeholderLabel = UILabel()
    
    var placeholderColor: UIColor {
        get { return placeholderLabel.textColor }
        set { placeholderLabel.textColor = newValue }
    }
    
    var placeholder: String {
        get { return placeholderLabel.text ?? "" }
        set { placeholderLabel.text = newValue }
    }
    
    override var font: UIFont? {
        didSet {
            placeholderLabel.font = font
        }
    }
    
    override var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override var textContainerInset: UIEdgeInsets {
        didSet {
            updatePlaceholderConstraints()
        }
    }
    
    private var placeholderConstraints = [NSLayoutConstraint]()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        
        /// font == nil from init frame
        font = UIFont.preferredFont(forTextStyle: .body)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        setupSelf()
        setupPlaceholderLabel()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
    }
    
    //deinit {
    //    NotificationCenter.default.removeObserver(self, name: UITextView.textDidChangeNotification, object: nil)
    //}
    
    private func setupSelf() {
        adjustsFontForContentSizeCategory = true
        removePadding()
        placeholderColor = systemPlaceholderColor
    }
    
    private func setupPlaceholderLabel() {
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.adjustsFontForContentSizeCategory = true
        
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        
        addSubview(placeholderLabel)
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        updatePlaceholderConstraints()
    }
    
    private func updatePlaceholderConstraints() {
        
        /// guard for textContainerInset change after init()
        if placeholderLabel.superview == nil {
            return
        }
        
        removeConstraints(placeholderConstraints)
        
        // TODO: check for RTL languages
        let leftConstant = textContainerInset.left + textContainer.lineFragmentPadding
        let rightConstant = textContainerInset.right + textContainer.lineFragmentPadding
        let topConstant = textContainerInset.top
        let bottomConstant = textContainerInset.bottom
        
        placeholderConstraints = [
            placeholderLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leftConstant),
            placeholderLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -rightConstant),
            placeholderLabel.topAnchor.constraint(equalTo: topAnchor, constant: topConstant),
            placeholderLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottomConstant)
        ]
        
        addConstraints(placeholderConstraints)
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
}

extension UITextView {

    func removePadding() {
        /// remove insets https://stackoverflow.com/a/42333832/5893286
        textContainer.lineFragmentPadding = 0
        textContainerInset = .zero
    }
}

import UIKit

class ResizableTextView: UITextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isScrollEnabled = false
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
}

final class ResizableEmptiableTextView: ResizableTextView {
    override var intrinsicContentSize: CGSize {
        return text.isEmpty ? .zero : super.intrinsicContentSize
    }
}

class ResizablePlaceholderTextView: PlaceholderTextView {
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        isScrollEnabled = false
    }
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        
        /// max text size
        //if placeholderLabel.intrinsicContentSize.height > super.intrinsicContentSize.height {
        //    return placeholderLabel.intrinsicContentSize
        //} else {
        //    return super.intrinsicContentSize
        //}
        
        /// visible text size
        if text.isEmpty, placeholderLabel.intrinsicContentSize.height > super.intrinsicContentSize.height {
            return placeholderLabel.intrinsicContentSize
        } else {
            return super.intrinsicContentSize
        }
        
    }
}

class UnderlineResizablePlaceholderTextView: ResizablePlaceholderTextView {
    
    var underlineHeight: CGFloat = 1 {
        didSet { setNeedsDisplay() }
    }
    
    var underlineOffset: CGFloat = 4 {
        didSet { setNeedsDisplay() }
    }
    
    var underlineColor = Colors.text {
        didSet {
            updateUnderlineColor()
        }
    }
    
    private let underlineLayer = CALayer()
    
    override init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        layer.addSublayer(underlineLayer)
        updateUnderlineColor()
        
        /// to test underlineLayer frame
        //layer.masksToBounds = true
    }
    
    private func updateUnderlineColor() {
        underlineLayer.backgroundColor = underlineColor.cgColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        CALayer.performWithoutAnimation {
            underlineLayer.frame = CGRect(x: 0.0,
                                          y: frame.height - underlineHeight,
                                          width: frame.width,
                                          height: underlineHeight);
        }
        
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        size.height += underlineOffset + underlineHeight
        return size
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        /// not working COLOR.resolvedColor(with: traitCollection).cgColor https://stackoverflow.com/a/57177411/5893286
        /// cgColor update https://stackoverflow.com/a/58312205/5893286
        if #available(iOS 13.0, *), traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) {
            updateUnderlineColor()
        }
        
    }
}

extension CALayer {
    
    /// source https://stackoverflow.com/a/33961937/5893286
    static func performWithoutAnimation(_ actionsWithoutAnimation: () -> Void) {
        CATransaction.begin()
        CATransaction.setValue(true, forKey: kCATransactionDisableActions)
        actionsWithoutAnimation()
        CATransaction.commit()
    }
}
