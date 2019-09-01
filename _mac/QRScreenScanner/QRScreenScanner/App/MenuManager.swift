import Cocoa

final class MenuManager {
    
    //static let shared = MenuManager()
    
    private let mainMenu = NSMenu(title: "Main")
    
    func setup() {
        /// first menu is hidden under app name
        addAppMenu()
        addFileMenu()
        addEditMenu()
        addWindowMenu()
        addHelpMenu()
        
        /// call the last to add system hidden items like emojy
        NSApp.mainMenu = mainMenu
    }
    
    private func addAppMenu() {
        let menu = NSMenu(title: "App")
        
        
        menu.addItem(withTitle: "About",
                        action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)),
                        keyEquivalent: "a")
            .keyEquivalentModifierMask = [.option, .shift]
        
        menu.addItem(NSMenuItem.separator())
        
        //appMenu.addItem(withTitle: "Hide \(App.name)", action: #selector(NSApp.hide(_:)), keyEquivalent: "h")
        
        menu.addItem(withTitle: "Hide Others",
                        action: #selector(NSApp.hideOtherApplications(_:)),
                        keyEquivalent: "")
            .keyEquivalentModifierMask = [.option, .command]
        
        menu.addItem(withTitle: "Show all", action: #selector(NSApp.unhideAllApplications(_:)), keyEquivalent: "")
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        
        
        mainMenu.addSubmenu(menu: menu)
    }
        
    private func addFileMenu() {
        let menu = NSMenu(title: "File")
        
        
        menu.addItem(withTitle: "Open…", action: #selector(NSDocumentController.openDocument(_:)), keyEquivalent: "o")
        
        let openRecentMenu = NSMenu(title: "Open Recent")
        
        openRecentMenu.addItem(NSMenuItem.separator())
        
        openRecentMenu.addItem(withTitle: "Clear Menu", action: #selector(NSDocumentController.clearRecentDocuments(_:)), keyEquivalent: "")
        
        menu.addSubmenu(menu: openRecentMenu)
        
        
        
        //        menu.addItem(withTitle: "Release Notes", action: #selector(openReleaseNotes), keyEquivalent: "").target = self
        //
        //        menu.addItem(withTitle: "Feedback and Bugs", action: #selector(openIssues), keyEquivalent: "").target = self
        //
        //        /// "Submit feedback..."
        //        menu.addItem(withTitle: "Report an Issue", action: #selector(openSubmitFeedbackPage), keyEquivalent: "").target = self
        
        
        mainMenu.addSubmenu(menu: menu)
    }
    
    let deleteMenuItem = NSMenuItem()
    let selectAllMenuItem = NSMenuItem()
    
    private func addEditMenu() {
        let menu = NSMenu(title: "Edit")
        //editMenu.autoenablesItems = false
        
        menu.addItem(withTitle: "Undo", action: #selector(MenuItems.undo(_:)), keyEquivalent: "z")

        menu.addItem(withTitle: "Redo", action: #selector(MenuItems.redo(_:)), keyEquivalent: "z").keyEquivalentModifierMask = [.shift, .command]
        
        // TODO: clear separator
        menu.addItem(.separator())

        let deleteKey = String(format: "%c", NSBackspaceCharacter)
        //let deleteKey = String(Character(UnicodeScalar(NSBackspaceCharacter)!))
        
        
        menu.addItem(withTitle: "Delete", action: #selector(NSTextView.delete(_:)), keyEquivalent: deleteKey)
        
//        deleteMenuItem.title = "Delete"
//        deleteMenuItem.keyEquivalent = deleteKey
//        deleteMenuItem.keyEquivalentModifierMask = .command
//        menu.addItem(deleteMenuItem)
        
//        menu.addItem(withTitle: "Select all", action: #selector(NSTableView.selectAll(_:)), keyEquivalent: "a")
        selectAllMenuItem.title = "Select all"
        selectAllMenuItem.keyEquivalent = "a"
        selectAllMenuItem.keyEquivalentModifierMask = .command
        selectAllMenuItem.action = #selector(NSTableView.selectAll(_:))
        menu.addItem(selectAllMenuItem)
        
        
        
        
        
//        let copyAllMenuItem = NSMenuItem()
//        copyAllMenuItem.title = "Copy"
//        copyAllMenuItem.keyEquivalent = "c"
        
//        copyAllMenuItem.action = NSSelectorFromString("copy:")//#selector(ViewController.copy1)
        //copyAllMenuItem.keyEquivalentModifierMask = .command
//        menu.addItem(copyAllMenuItem)
        
        menu.addItem(withTitle: "Cut", action: #selector(NSTextView.cut(_:)), keyEquivalent: "x")
        menu.addItem(withTitle: "Copy", action: #selector(NSTextView.copy(_:)), keyEquivalent: "c")
        menu.addItem(withTitle: "Paste", action: #selector(NSTextView.paste(_:)), keyEquivalent: "v")
        
//            editMenu.addItem(withTitle: "About 2", action: #selector(about), keyEquivalent: "x").target = self
        
        mainMenu.addSubmenu(menu: menu)
    }
    
    private func addWindowMenu() {
        let menu = NSMenu(title: "Window")
        
        
        menu.addItem(withTitle: "Minimize", action: #selector(NSWindow.miniaturize(_:)), keyEquivalent: "m")
        
        menu.addItem(withTitle: "Zoom", action: #selector(NSWindow.zoom(_:)), keyEquivalent: "")
        
        menu.addItem(withTitle: "Hide all", action: #selector(NSApp.hide(_:)), keyEquivalent: "h")
        
        menu.addItem(withTitle: "Enter full screen", action: #selector(NSWindow.toggleFullScreen(_:)), keyEquivalent: "f")
            .keyEquivalentModifierMask = [.control, .command]
        
        menu.addItem(withTitle: "Customize toolbar...", action: #selector(NSWindow.runToolbarCustomizationPalette(_:)), keyEquivalent: "")
        
        
        mainMenu.addSubmenu(menu: menu)
    }
    
    private func addHelpMenu() {
        let menu = NSMenu(title: "Help")
        
        
        menu.addItem(withTitle: "Documentation", action: #selector(openDocumentation), keyEquivalent: "").target = self
        
        menu.addItem(NSMenuItem.separator())
        
        menu.addItem(withTitle: "Release Notes", action: #selector(openReleaseNotes), keyEquivalent: "").target = self
        
        menu.addItem(withTitle: "Feedback and Bugs", action: #selector(openIssues), keyEquivalent: "").target = self
        
        /// "Submit feedback..."
        menu.addItem(withTitle: "Report an Issue", action: #selector(openSubmitFeedbackPage), keyEquivalent: "").target = self
        
        
        mainMenu.addSubmenu(menu: menu)
    }
    
    @objc private func openSubmitFeedbackPage() {
        App.openSubmitFeedbackPage()
    }
    
    @objc private func openReleaseNotes() {
        App.openReleaseNotes()
    }
    
    @objc private func openIssues() {
        App.openIssues()
    }
    
    @objc private func openDocumentation() {
        App.openDocumentation()
    }
    
    //    @objc private func quit() {
    //        NSApp.terminate(nil)
    //    }
    //
    //    @objc private func about() {
    //        NSApp.orderFrontStandardAboutPanel(self)
    //    }
}

extension NSMenu {
    
    /// for title "Edit" will add emojy menuItem. it bcz of `addItem(withTitle: "Edit"`.
    /// setSubmenu must be called before `NSApp.mainMenu = mainMenu` to add emojy menuItem.
    func createSubmenu(title: String) -> NSMenu {
        let menu = NSMenu(title: title)
        let menuItem = addItem(withTitle: title, action: nil, keyEquivalent: "")
        setSubmenu(menu, for: menuItem)
        return menu
    }
    
    func addSubmenu(menu: NSMenu) {
        let menuItem = addItem(withTitle: menu.title, action: nil, keyEquivalent: "")
        setSubmenu(menu, for: menuItem)
    }
}

private final class MenuItems {

    /// need instead of NSSelectorFromString("undo:")
    @objc static func redo(_: Any?) {
        assertionFailure("need instead of NSSelectorFromString(\"undo:\")")
    }
    
    /// need instead of NSSelectorFromString("undo:")
    @objc static func undo(_: Any?) {
        assertionFailure("need instead of NSSelectorFromString(\"undo:\")")
    }
}
