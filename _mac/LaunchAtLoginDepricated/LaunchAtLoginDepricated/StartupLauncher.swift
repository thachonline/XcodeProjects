import Foundation

final class StartupLauncher {
    
    static let shared = StartupLauncher()
    
    private let appUrl = URL(fileURLWithPath: Bundle.main.bundlePath)
    
    private let loginItemRef: LSSharedFileList = {
        return LSSharedFileListCreate(nil,
                                      kLSSharedFileListSessionLoginItems.takeRetainedValue(),
                                      nil).takeRetainedValue() as LSSharedFileList
    }()
    
    private func loginItems() -> [LSSharedFileListItem]? {
        return LSSharedFileListCopySnapshot(loginItemRef,
                                            nil).takeRetainedValue() as? [LSSharedFileListItem]
    }
    
    private func appItem(from loginItems: [LSSharedFileListItem]) -> LSSharedFileListItem? {
        return loginItems.first(where: { item in
            let itemUrl = LSSharedFileListItemCopyResolvedURL(item, 0, nil).takeRetainedValue() as URL
            return itemUrl == appUrl
        })
    }
    
    func setAppAsLoginItem(_ login: Bool) {
        guard let loginItems = loginItems() else {
            assertionFailure()
            return
        }
        
        if login {
            LSSharedFileListInsertItemURL(loginItemRef, loginItems.last, nil, nil, appUrl as CFURL, nil, nil)
        } else {
            guard let appItem = appItem(from: loginItems) else {
                assertionFailure("don't turn off LaunchAtLogin if it is already off")
                return
            }
            LSSharedFileListItemRemove(loginItemRef, appItem)
        }
    }
    
    func isAppLoginItem() -> Bool {
        guard let loginItems = loginItems() else {
            assertionFailure()
            return false
        }
        return appItem(from: loginItems) != nil
    }
    
    func toggle() {
        setAppAsLoginItem(!isAppLoginItem())
    }
    
    var isLaunchAtLogin: Bool {
        get {
            return isAppLoginItem()
        }
        set {
            setAppAsLoginItem(newValue)
        }
    }
}
