import Cocoa

// TODO: dock manager
// TODO: https://stackoverflow.com/a/9220857/5893286
// TODO: https://stackoverflow.com/a/50832237/5893286 + https://stackoverflow.com/a/4686782/5893286
// TODO: https://developer.apple.com/library/archive/technotes/tn2083/_index.html

// TODO: fix horizonal scroll
// TODO: saving window size

final class App {
    
    static let shared = App()
    
    let statusItemManager = StatusItemManager()
    let menuManager = MenuManager()
    let toolbarManager = ToolbarManager()
    
    private let window: NSWindow = {
        let window = NSWindow(contentViewController: ViewController())
        window.center()
        return window
    }()
    
    func start() {
        //        ScreenManager.disableHardwareMirroring()
        //        ScreenManager.allDisplayImages()
        //        ScreenManager.toggleMirroring()
        
        //        let window = ScreenManager.compositedWindow(for: "Google Chrome")
        //        let w = ScreenManager.compositedWindowsByName()
        //let e = ScreenManager.windowsByName()
        //ScreenManager.visibleWindowsImages()
        
        menuManager.setup()
        statusItemManager.setup()
        showWindow()
        
        toolbarManager.addToWindow(window)
    }
    
    
    
    func showWindow() {
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
