import UIKit

class ResizableCollectionView: UICollectionView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}


class ResizableTableView: UITableView {
    
    override var contentSize: CGSize {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

import UIKit

/// https://stackoverflow.com/a/21267507
final class TextInsetsLabel: UILabel {
    
    override var text: String? {
        didSet {
            sizeToFit()
        }
    }
    
    @IBInspectable var topBottom: CGSize = .zero {
        didSet {
            textInsets.bottom = topBottom.width
            textInsets.top = topBottom.height
        }
    }
    
    @IBInspectable var leftRight: CGSize = .zero {
        didSet {
            textInsets.left = leftRight.width
            textInsets.right = leftRight.height
        }
    }
    
    var textInsets = UIEdgeInsets.zero {
        didSet { invalidateIntrinsicContentSize() }
    }
    
    override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        let insetRect = bounds.inset(by: textInsets)
        let textRect = super.textRect(forBounds: insetRect, limitedToNumberOfLines: numberOfLines)
        let invertedInsets = UIEdgeInsets(top: -textInsets.top,
                                          left: -textInsets.left,
                                          bottom: -textInsets.bottom,
                                          right: -textInsets.right)
        return textRect.inset(by: invertedInsets)
    }
}
class InsetsLabel: UILabel {
    
    var insets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var topBottom: CGSize = .zero {
        didSet {
            insets.bottom = topBottom.width
            insets.top = topBottom.height
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var leftRight: CGSize = .zero {
        didSet {
            insets.left = leftRight.width
            insets.right = leftRight.height
            setNeedsDisplay()
        }
    }
    
    override func drawText(in rect: CGRect) {
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size != .zero {
            size.width += insets.left + insets.right
            size.height += insets.top + insets.bottom
        }
        return size
    }
}

class InsetsButton: UIButton {
    
    var insets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var topBottom: CGSize = .zero {
        didSet {
            insets.bottom = topBottom.width
            insets.top = topBottom.height
            setNeedsDisplay()
        }
    }
    
    @IBInspectable var leftRight: CGSize = .zero {
        didSet {
            insets.left = leftRight.width
            insets.right = leftRight.height
            setNeedsDisplay()
        }
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        return super.titleRect(forContentRect: contentRect.inset(by: insets))
    }
    
    /// can be used
    //override func draw(_ rect: CGRect) {
    //    super.draw(UIEdgeInsetsInsetRect(rect, insets))
    //}
    
    override var intrinsicContentSize: CGSize {
        var size = super.intrinsicContentSize
        if size != .zero {
            size.width += insets.left + insets.right
            size.height += insets.top + insets.bottom
        }

        size.width = ceil(size.width)
        size.height = ceil(size.height)

        return size
    }
    
    
    /// another
//    override var intrinsicContentSize: CGSize {
//        let size = super.intrinsicContentSize
//
//        return CGSize(width: size.width + self.titleEdgeInsets.left + self.titleEdgeInsets.right,
//                      height: size.height + self.titleEdgeInsets.top + self.titleEdgeInsets.bottom)
//    }
}


/// source https://github.com/Rightpoint/Swiftilities/issues/88
// These let you start a touch on a button that's inside a scroll view,
// and then if you start dragging, it cancels the touch on the button
// and lets you scroll instead. Without these scroll view subclasses,
// buttons in scroll views will eat touches that start in them, which
// prevents scrolling and makes the app feel broken.
//
// The UITextInput exception is for cases where you have a text field
// or a label in a scroll view. If you press and hold there, you want
// to get the text editing magnifier cursor, instead of canceling the
// touch in the text input element.
class ControlContainableScrollView: UIScrollView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        // TODO: check needs. add to others if need
        /// Hack to allow buttons to show highlight state immediately on touch https://stackoverflow.com/a/19299451/5893286
        
        /// tableview hack https://stackoverflow.com/a/33743183/5893286
        
        /// maybe don't need this https://stackoverflow.com/a/45240170/5893286
        delaysContentTouches = false
    }
    
    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl && !(view is UITextInput) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }

}

class ControlContainableTableView: UITableView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl && !(view is UITextInput) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }

}

class ControlContainableCollectionView: UICollectionView {

    override func touchesShouldCancel(in view: UIView) -> Bool {
        if view is UIControl && !(view is UITextInput) {
            return true
        }

        return super.touchesShouldCancel(in: view)
    }

}

final class BorderDotsPageControl: UIPageControl {
    
    var borderColor: UIColor = .clear {
        didSet {
            updateBorderColor()
        }
    }

    override var currentPage: Int {
        didSet {
            updateBorderColor()
        }
    }

    func updateBorderColor() {
        subviews.forEach { subview in
            subview.layer.borderColor = borderColor.cgColor
            subview.layer.borderWidth = 1
        }
    }
}

class AdjustsFontSizeInsetsButton: UIButton {
    
    var insets: UIEdgeInsets = .zero {
        didSet {
            setNeedsDisplay()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }

    private func setup() {
        guard let buttonLabel = titleLabel else {
            assertionFailure()
            return
        }
        /// lineBreakMode must be at the beginning!
        buttonLabel.lineBreakMode = .byClipping

        buttonLabel.adjustsFontSizeToFitWidth = true
        buttonLabel.numberOfLines = 0
        buttonLabel.minimumScaleFactor = 0.5
        buttonLabel.textAlignment = .center
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel?.frame = bounds.inset(by: insets)
    }
}
extension UILabel {
    func adjustsFontSizeToFitWidth() {
        minimumScaleFactor = 0.5
        adjustsFontSizeToFitWidth = true
    }
}



final class SpringLabel: UILabel {
    
    var duration = 0.1
    
    override var text: String? {
        didSet {
            UIView.animate(withDuration: duration) {
                self.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }
            UIView.animate(withDuration: duration, delay: duration, options: [], animations: {
                self.transform = .identity
            }, completion: nil)
        }
    }
    
}


extension UIButton {
    
    /// https://stackoverflow.com/a/43785519/5893286
    func forceImageToRightSide() {
        /// or 1
        let newTransform = CGAffineTransform(scaleX: -1.0, y: 1.0)
        transform = newTransform
        titleLabel?.transform = newTransform
        imageView?.transform = newTransform
        
        /// or 2
        //sortByButton.semanticContentAttribute = .forceRightToLeft
    }
}

class UnderlineView: UIView {
    
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
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
}


/// need fof iPad
final class NumbersTextField: UITextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
    }
    
    private func isAvailableCharacters(in text: String) -> Bool {
        return text.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil
    }
}
extension NumbersTextField: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return isAvailableCharacters(in: string)
    }
}


final class SecureTextField: UnderlineTextField {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private let eyeButton = DynamicFontButton(type: .custom)
    
    private func setup() {
        eyeButton.setImage(UIImage(systemName: "eye"), for: .normal)
        eyeButton.setImage(UIImage(systemName: "eye.slash"), for: .selected)
        eyeButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        eyeButton.tintColor = Colors.text
        //eyeButton.sizeToFit()
        
        rightView = eyeButton
        rightViewMode = .always
        
        isSecureTextEntry = true
        
        /// style
        setDynamicFont(Fonts.button)
        borderStyle = .none
        textColor = Colors.text
        backgroundColor = Colors.background
        isOpaque = true
        
        /// return key
        returnKeyType = .next
        enablesReturnKeyAutomatically = true
        
        /// removes suggestions bar above keyboard
        autocorrectionType = .no
        
        /// removed useless features
        autocapitalizationType = .none
        spellCheckingType = .no
        smartQuotesType = .no
        smartDashesType = .no
    }
    
    var saveTextAfterTogglePasswordVisibility = true
    
    @objc func togglePasswordVisibility() {
        eyeButton.isSelected.toggle()
        toggleTextFieldSecureType()
        
        if saveTextAfterTogglePasswordVisibility, isSecureTextEntry, let existingText = text {
            /// fix existing text clearing https://stackoverflow.com/a/48115361/5893286
            /* When toggling to secure text, all text will be purged if the user
             * continues typing unless we intervene. This is prevented by first
             * deleting the existing text and then recovering the original text. */
            
            text = nil
            insertText(existingText)
            
            /// instantly shows a text selection on the latest iOS versions
            //deleteBackward()
            
            ////// triggers the .editingChanged event
            //if let textRange = textRange(from: beginningOfDocument, to: endOfDocument) {
            //    replace(textRange, withText: existingText)
            //}
        }
    }
    
}

extension UITextField {
    /// call layoutIfNeeded() if placeholderLabel is nil
    var placeholderLabel: UILabel? {
        return subviews.first(where: { $0 is UILabel }) as? UILabel
    }
    
    func toggleTextFieldSecureType() {
        /// incorrect font https://stackoverflow.com/a/35295940/5893286
        isSecureTextEntry.toggle()
        let font = self.font
        self.font = nil
        self.font = font
        
        /// incorrect font https://stackoverflow.com/a/35351541/5893286
        /// there is keyboard blink on simulator iOS 13.4.1
        //resignFirstResponder()
        //isSecureTextEntry.toggle()
        //becomeFirstResponder()
    }
    
    func addToolBarWithButton(title: String, target: Any, selector: Selector) {
        let doneButton = UIBarButtonItem(title: title,
                                         font: UIFont.systemFont(ofSize: 19),
                                         tintColor: UIColor.white,
                                         accessibilityLabel: title,
                                         style: .plain,
                                         target: target,
                                         selector: selector)
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.items = [
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            doneButton
        ]
        keyboardToolbar.sizeToFit()
        
        inputAccessoryView = keyboardToolbar
    }
}
}
