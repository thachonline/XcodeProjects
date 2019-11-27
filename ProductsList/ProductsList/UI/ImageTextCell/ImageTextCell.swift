import UIKit
import Kingfisher

/// Content View added for simplifying copying of all content and possible insets
/// changed subtitleLabel content hugging priority and content compression resistance
final class ImageTextCell: UICollectionViewCell {
    
    typealias Item = ProductItemDB
    typealias CellDelegate = ImageTextCellDelegate
    
    @IBOutlet private weak var imageView: UIImageView! {
        willSet {
            /// newValue used for simplifying copying same settings
            
            newValue.contentMode = .scaleAspectFill
            newValue.isOpaque = true
            
            /// used color to show empty state bcz UIActivityIndicatorView is too expensive for performance
            newValue.backgroundColor = .systemBackground
        }
    }
    
    @IBOutlet private weak var titleLabel: UILabel! {
        willSet {
            /// newValue used for simplifying copying same settings
            newValue.font = UIFont.preferredFont(forTextStyle: .headline)
            newValue.textAlignment = .center
            newValue.backgroundColor = .systemBackground
            newValue.textColor = .label
            newValue.numberOfLines = 1
        }
    }
    
    @IBOutlet private weak var subtitleLabel: UILabel! {
        willSet {
            /// newValue used for simplifying copying same settings
            newValue.font = UIFont.preferredFont(forTextStyle: .body)
            newValue.textAlignment = .center
            newValue.backgroundColor = .systemBackground
            newValue.textColor = .label
            newValue.numberOfLines = 1
        }
    }
    
    private var item: Item?
    private var isContextMenuDidAppear = false
    weak var delegate: CellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        addInteraction()
    }
    
    //func setup(for item: Product.Item) {
    //    titleLabel.text = item.name
    //    subtitleLabel.text = "\(item.price)"
    //
    //    imageView.kf.cancelDownloadTask()
    //    imageView.kf.setImage(with: item.imageUrl, placeholder: UIImage(systemName: "photo"))
    //
    //
    //    //imageView.image = UIImage(systemName: "photo")
    //    //KingfisherManager.shared.retrieveImage(with: item.imageUrl) { result in
    //    //    switch result {
    //    //    case .success(let source):
    //    //        let image = source.image
    //    //        self.imageView.contentMode = image.size.width < image.size.height ? .scaleAspectFill : .scaleAspectFit
    //    //        self.imageView.image = image
    //    //    case .failure(let error):
    //    //        print(error.debugDescription)
    //    //    }
    //    //}
    //
    //}
    
    private func addInteraction() {
        #if os(iOS)
        isUserInteractionEnabled = true
        let interaction = UIContextMenuInteraction(delegate: self)
        addInteraction(interaction)
        #else /// tvOS
        //let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(longPressGesture(_:)))
        //longPressGesture.allowedPressTypes = [NSNumber(value: UIPress.PressType.select.rawValue),
        //                                      NSNumber(value: UIPress.PressType.playPause.rawValue)]
        //addGestureRecognizer(longPressGesture)
        //
        //
        //layer.shadowRadius = 16
        //layer.shadowColor = UIColor.black.cgColor
        //layer.shadowOffset = CGSize(width: 0, height: 16)
        ///// turned off at start
        //layer.shadowOpacity = 0.0
        #endif
    }
    
    func setup(for item: Item) {
        self.item = item
        titleLabel.text = item.name
        subtitleLabel.text = "Price: \(item.price)"
        
        imageView.kf.cancelDownloadTask()
        imageView.kf.setImage(with: item.imageUrl, placeholder: UIImage(systemName: "photo"))
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
    }
}

/// without delegate can be used: func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration?
#if os(iOS)
/// rus tutorial https://habr.com/ru/company/apphud/blog/455854/
/// eng tutorial https://kylebashour.com/posts/ios-13-context-menus
/// full description  https://kylebashour.com/posts/context-menu-guide
/// code example https://github.com/kylebshr/context-menus/tree/kyle/suggested-actions
@available(tvOS, unavailable)
extension ImageTextCell: UIContextMenuInteractionDelegate {
    
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                willDisplayMenuFor configuration: UIContextMenuConfiguration,
                                animator: UIContextMenuInteractionAnimating?) {
        
        delegate?.photoCellPreivewWillAppear()
        
        animator?.addCompletion { [weak self] in
            self?.delegate?.photoCellPreivewDidAppear()
            self?.isContextMenuDidAppear = true
        }
    }
    
    /// long tap on view to open context menu
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        
        guard
//            let delegate = self.delegate,
            let item = self.item,
            let itemName = item.name
        else {
            assertionFailure()
            return nil
        }
        
        return UIContextMenuConfiguration(identifier: nil, previewProvider: {
            #if targetEnvironment(macCatalyst)
            /// for macCatalyst controller will not be presented.
            /// viewDidLoad will not be called but controller will be created so pass nil.
            return nil
            #else
            return ProductDetailController(item: item)
            #endif
        }, actionProvider: { _ in //[weak self] systemActions in
            
//            guard let self = self else {
//                return nil
//            }
            

            
            /// SF Symbols
            // let share "square.and.arrow.up"
            // The "title" will show up as an action for opening this menu
            //let shareSubmenu = UIMenu(title: "Share...", children: [rename, delete])
            
            //let delete = UIAction(title: "Delete", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { _ in
            //    /// strong reference to item
            //    delegate.photoCell(cell: self, didDelete: item, at: indexPath)
            //}
            
            //UIBarButtonItem.SystemItem.trash
            //UIMenuSystem.context
            return UIMenu(title: itemName, image: nil, identifier: nil, options: [], children: [])
        })
    }
    
    /// tap on context preview
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                willPerformPreviewActionForMenuWith configuration: UIContextMenuConfiguration,
                                animator: UIContextMenuInteractionCommitAnimating) {
        
        /// animation fix https://stackoverflow.com/a/57731149
        /// needs only to dismiss preview without open animation.
//        animator.preferredCommitStyle = .dismiss
        
        guard
            let delegate = self.delegate,
            let item = self.item
        else {
            assertionFailure()
            return
        }
        
        animator.addCompletion {
            /// or #1
            if let vc = animator.previewViewController {
                delegate.photoCellDidTapOnPreivew(previewController: vc, item: item)
                //UIApplication.shared.topMostViewController()?.navigationController?.pushViewController(vc, animated: true)
//                App.shared.window.rootViewController?.present(vc, animated: true, completion: nil)
            }
            
            /// or #2
//            let vc = PreviewViewController(image: self.imageView.image)
//            UIApplication.shared.topMostViewController()?.navigationController?.show(vc, sender: nil)
            
            
        }
    }
    
//    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
//                                previewForDismissingMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
//        configuration.identifier
////        interaction.delegate.
//        let vc = PreviewViewController(image: self.imageView.image)
//        App.shared.window.rootViewController?.present(vc, animated: false, completion: nil)
//        return UITargetedPreview(view: vc.view)
////        return nil
//    }
    
    /// not called for macCatalyst
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction,
                                willEndFor configuration: UIContextMenuConfiguration,
                                animator: UIContextMenuInteractionAnimating?) {
        
        if isContextMenuDidAppear {
            isContextMenuDidAppear = false
            delegate?.photoCellPreivewWillDisappear()
            
            animator?.addCompletion { [weak self] in
                self?.delegate?.photoCellPreivewDidDisappear()
            }
        } else {
            animator?.addCompletion {// [weak self] in
                print("preview dragged without menu appear")
            }
        }

    }
    
}
#endif

protocol ImageTextCellDelegate: class {
    //func photoCell(cell: PhotoCell, didDelete item: RemoteItem, at indexPath: IndexPath)
    func photoCellDidTapOnPreivew(previewController: UIViewController, item: ImageTextCell.Item)
    
    func photoCellPreivewWillAppear()
    func photoCellPreivewDidAppear()

    func photoCellPreivewWillDisappear()
    func photoCellPreivewDidDisappear()
}

extension ImageTextCellDelegate {
    func photoCellPreivewWillAppear() {}
    func photoCellPreivewDidAppear() {}

    func photoCellPreivewWillDisappear() {}
    func photoCellPreivewDidDisappear() {}
}
