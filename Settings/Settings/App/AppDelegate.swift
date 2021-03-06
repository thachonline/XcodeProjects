//
//  AppDelegate.swift
//  Settings
//
//  Created by Bondar Yaroslav on 9/27/18.
//  Copyright © 2018 Bondar Yaroslav. All rights reserved.
//

import UIKit

/// Features:
//
// Supports 4 languages
// Supports navigation for RTL languages (Hebrew, Arabic)
// Language changing without reload
// Themes of interface
// Smart keyboard shortcuts support (UIKeyCommand)
// Supporting Accessibility: Larger Text
// Supporting Accessibility: VoiceOver
// Supports 3D touch on app icon (Quick Actions)
// Supports iPhoneX and newer
// Supports landscape (horizontal) mode + iPhoneX, XR split
// Supports iPad and split screen (controller)
// App restoration if system killed it (not user manual)
// AppRater by events
// Localization strings by swiftgen
// Window round coners
// Supports in-call status bar
// Supports iOS 11 large titles (there is a bug in pop vc after restoration)
//
/// Marketing:
// Fully offline
// Battery effective
// No ads
// Feedback is reading
// There is no any (auto turn on) statistics
// There is no registration (Registration don't need)
// Using latest version of Swift for best performance of app

/// Test cases
//cell height. iOS 10, iPhone 5. steps: settings screen - scroll to bottom - landscape - portrait

// FIXME: window tintColor for standart controllers
// TODO: remove storyboard
// TODO: clear appDelegate
// TODO: check all present on iPad (share app)
// TODO: Copyable version label
// TODO: custom cell with switcher
// TODO: auto turn on dark theme (Pet Finder_Completed_Swift3 project)
// TODO: for release mode shake to send a bug via email
// TODO: custom cells for DeveloperAppsController (get/optn button, icon image)

// TODO: POEditor shared localization
// TODO: real time localization by
// https://github.com/willpowell8/LocalizationKit_iOS

/// Not necessary right now
// TODO: there is degrease performance after set theme or language a lot of times
// TODO: URL Schemes for tab bar
// TODO: handling manager for URL Schemes + Quick Actions + UIKeyCommand + Notifcations
// TODO: Reset to default settings
// TODO: fix restoration layout for large texts
// TODO: check traitCollectionDidChange in background (user enabled 3d touch) (traitCollectionDidChange in AppDelegate don't work)
// TODO: split controller save selected index
// TODO: crashlitics? (Crash reports switch)
// TODO: fabric analytics?
// TODO: log JailbreakChecker
// TODO: spotlight
// TODO: siri
// TODO: external display support

// TODO: external display support (iPad pro 2018 + AirPlay)
// TODO: AirPlay support
//https://developer.apple.com/documentation/uikit/windows_and_screens/displaying_content_on_a_connected_screen
//https://www.swiftjectivec.com/supporting-external-displays/
//https://developer.apple.com/library/archive/documentation/WindowsViews/Conceptual/WindowAndScreenGuide/Introduction/Introduction.html

// TODO: other options in settings:
//
/// Optional:
// Clear cash (mb)
// Collect anonimus statistics
// Passcode
// font size slider
// prevent from sleeping / brightness slider
// Save after app deleted (by keychain, instant export/import after chnaging)
// iCloud sync of settings
// reset to default
//
/// FAQ (Questions & Answers)
/// Tell a friend (social, email, qr code (QRScanner), More(share with iOS share action) )
/// Software update (new update)
/// -About (Help / О приложении):
// Social links (buttons)
// Terms of Service
// Lisences (Legal notices, Acknowledgements) (pods)
// Notify about app?? (.never) (by local notifications)
/// --DONE
// Icon
// app version (с билд номером и без него)
// Developer page
// Rate Us
// Feedback (Send feedback / Contact Us / Написать автору)
// Privacy Policy
// More applications

// TODO: accessibility
// TODO: restoration scroll offset for large titles
// https://medium.com/bbc-design-engineering/improving-your-apps-accessibility-with-ios-11-db8bb4ee7c9f
// https://developer.apple.com/videos/play/wwdc2017/204/
//
/// To activate large bar items (navbar nad tabbar items)
/// Settings - General - Accessibility - Large Text
/// or 1: check Larger Accessibility Sizes - move slider right 4 times (for all iPhones)
/// or 2: move slider top right - check Larger Accessibility Sizes - move slider right one more time (for all iPhones)

extension Logger {
    func setupDefaultConfig() {
        configure {
            $0.showDate = true
            //                        $0.dateFormatter.dateFormat = "MM/dd/yyyy hh:mma"
            
            //            $0.showThreadName = false
            //            $0.showFileName = false
            //            $0.showLineNumber = false
            //            $0.showFunctionName = false
            //            $0.watchMainThead = true
        }
    }
}

#if DEBUG
extension Floating {
    static func setupDefaultConfig() {
        /// cmd + ctrl + z to shake
        Floating.mode = .shake
        
        let vc = FloatingPresentingController()
        let navVC = FloatingNavigationController(rootViewController: vc)
        FloatingManager.shared.presentingController = navVC
    }
}
#endif

/// added main.swift
//@UIApplicationMain
final class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    private var isApplicationRestored = false
    private let settingsStorage: SettingsStorage = SettingsStorageImp.shared
    
    private let rateAppDisplayManager = RateAppDisplayManager(untilPromptDays: 7,
                                                              launches: 10,
                                                              significantEvents: 3,
                                                              foregroundAppears: 15)
    
    private lazy var shortcutManager = ShortcutManager(window: window)
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        #if DEBUG
        Logger.shared.setupDefaultConfig()
        log("didFinishLaunchingWithOptions -----")
        log("--- isApplicationRestored: \(isApplicationRestored)")
        
        Floating.setupDefaultConfig()
        #endif
        
        LocalizationManager.shared.updateIsCurrentLanguageRTL()
        LocalizationManager.shared.register(self)
        
        AppearanceConfigurator.shared.loadSavedTheme()
        SettingsBundleManager.shared.setup()
        
        /// quick action can be handled from "didFinishLaunchingWithOptions" (at launch)
        /// or "performActionFor shortcutItem:" (when in memory)
        shortcutManager.handle(launchOptions: launchOptions)
        shortcutManager.registerShortcutItemsIfNeed()
        
        rateAppDisplayManager.startObserving(presentIn: window?.rootViewController)
        rateAppDisplayManager.rateCounter.appLaunched()
        //rateAppDisplayManager.isDebug = true
        
        observeLargeTextAccessibilityChanging()
        roundWindowCorners()
        
        /// not working
        //application.ignoreSnapshotOnNextApplicationLaunch()
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        /// Alternatively, a shortcut item may be passed in through this delegate method if the app was
        /// still in memory when the Home screen quick action was used. Again, store it for processing.
        //shortcutItemToProcess = shortcutItem
        
        /// apple sample code dont use completionHandler.
        completionHandler(shortcutManager.handleQuickAction(shortcutItem))
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

    /// If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    func applicationDidEnterBackground(_ application: UIApplication) {
        settingsStorage.saveIfNeed()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
        settingsStorage.saveIfNeed()
    }
}

extension AppDelegate {
    private func roundWindowCorners() {
        if Device.isIphoneXOrNewer {
            return
        }
        guard let window = window else {
            assertionFailure()
            return
        }
        
        window.clipsToBounds = true
        window.layer.cornerRadius = 5
        //window.backgroundColor = UIColor.black
    }
}

// MARK: - LocalizationManagerDelegate
extension AppDelegate: LocalizationManagerDelegate {
    func languageDidChange(to language: String) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard
            let window = window,
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController,
            let tabBarControllers = tabBarVC.viewControllers,
            !tabBarControllers.isEmpty
        else {
            assertionFailure()
            return
        }
        
        let lastIndex = tabBarControllers.count - 1
        tabBarVC.selectedIndex = lastIndex
        
        guard
            let settingsSplitVC = tabBarControllers[lastIndex] as? UISplitViewController,
            !settingsSplitVC.viewControllers.isEmpty,
            let settingsNavVC = settingsSplitVC.viewControllers[0] as? UINavigationController,
            let settingsVC = settingsNavVC.topViewController as? SettingsController
        else {
            assertionFailure()
            return
        }
        
        
//        guard let settingsNavVC = tabBarControllers[lastIndex] as? UINavigationController else {
//            assertionFailure()
//            return
//        }
        
//        let vc = LanguageSelectController()
        
        /// need bcz of iOS 10 bug with back button
//        if ProcessInfo().operatingSystemVersion.majorVersion == 10 {
//            settingsNavVC.pushViewController(vc, animated: true)
//        } else {
//            settingsNavVC.pushViewController(vc, animated: false)
//        }
        
        window.rootViewController = tabBarVC
        
        /// call after window.rootViewController =
        settingsVC.performSegue(withIdentifier: "detail!", sender: LanguageSelectController())
        
//        animateReload(for: window)
    }
    
    private func animateReload(for window: UIWindow) {
        UIView.transition(with: window, duration: 0.5, options: .transitionFlipFromLeft, animations: {
        }, completion: nil)
    }
}

// MARK: - UIStateRestoration
///
/// https://github.com/shagedorn/StateRestorationDemo/blob/master/Presentation/State%20Restoration.md
/*
 Unless these methods return YES, the application's state is not saved/restored, no
 matter what you do elsewhere. Consider it a global switch.
 You might want to return `false` conditionally in application(_:shouldRestoreApplicationState:)
 after app updates that include changes to the view (controller) hierarchy and other, potentially
 restoration-breaking changes.
 Returning `true` in application(_:shouldSaveApplicationState:) will create a restoration
 archive ("data.data") which you can inspect using the `restorationArchiveTool` provided by Apple:
 https://developer.apple.com/downloads/ (Login required; search for "restoration")
 Opting into state restoration will also take a snapshot of your app when entering
 background mode.
 While this generally switches on restoration, it doesn't do much yet: Individual
 controllers, views, and other participating objects must implement basic saving/
 restoration mechanisms in order for anything to actually restore. This can be
 done in code, or with the help of Storyboards. This demo focusses on code.
 
 General debugging tips:
 To get the app to restore in the simulator, follow these steps:
 - send the app to the background (home button / cmd + h)
 - quit the app in Xcode
 - relaunch the app
 
 Do not force-quit the app in the app switcher - this deletes the restoration archive.
 Do not kill the app while still in the foreground, as the restoration archive is created
 when the app goes into the background. To debug state restoration on device, read the
 documentation provided with the `restorationArchiveTool` mentioned above.
 */

extension AppDelegate {
    
    private func observeLargeTextAccessibilityChanging() {
        
        /// Another solution is apple AppearanceConfigurator theme textColor for lables in cells
        /// and subsribe all tableViews for theme did change
        /// and add label text color setting in all tableViews
        NotificationCenter.default.addObserver(self, selector: #selector(largeTextAccessibilityDidChanged), name: UIContentSizeCategory.didChangeNotification, object: nil)
    }
    
    @objc private func largeTextAccessibilityDidChanged() {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard
            let window = window,
            let tabBarVC = storyboard.instantiateViewController(withIdentifier: "TabBarController") as? UITabBarController
        else {
            assertionFailure()
            return
        }
        
        // TODO: check for any presentedViewController controller
        #if DEBUG
        if let oldVC = window.rootViewController?.presentedViewController as? FloatingNavigationController {
            oldVC.dismiss(animated: false) {
                window.rootViewController = tabBarVC
                Floating.isShownOnShake = false
                let vc = FloatingPresentingController()
                let navVC = FloatingNavigationController(rootViewController: vc)
                FloatingManager.shared.presentingController = navVC
            }
        } else {
            window.rootViewController = tabBarVC
        }
        #else
        window.rootViewController = tabBarVC
        #endif
    }
    
}

// MARK: - State Restoration
extension AppDelegate {
    
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        /// to see path to restoration file: data.data
        let lib = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!.appendingPathComponent("Saved Application State")
        print("Restoration files: \(lib.path)")
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreApplicationState coder: NSCoder) -> Bool {
        isApplicationRestored = true
        return true
    }
    
    /// decode any state at the app delegate level
    ///
    /// if you plan to do any asynchronous initialization for restoration -
    /// Use these methods to inform the system that state restoration is occuring
    /// asynchronously after the application has processed its restoration archive on launch.
    /// In the event of a crash, the system will be able to detect that it may have been
    /// caused by a bad restoration archive and arrange to ignore it on a subsequent application launch.
    ///
//    func application(_ application: UIApplication, didDecodeRestorableStateWith coder: NSCoder) {
//
//        application.extendStateRestoration()
//
//        DispatchQueue.global().async {
//            /// do any additional asynchronous initialization work here...
//
//            DispatchQueue.main.async {
//                application.completeStateRestoration()
//            }
//        }
//
//        // if you ever want to check for restore bundle version of user interface idiom, use this code:
//        //
//        //ask for the restoration version (used in case we have multiple versions of the app with varying UIs)
//        // String with value of info.plist's Bundle Version (app version) when state was last saved for the app
//        //
//        guard let restoreBundleVersion = coder.decodeObject(forKey: UIApplicationStateRestorationBundleVersionKey) as? String else {
//            return
//        }
//
//        print("Restore bundle version:", restoreBundleVersion)
//
//        // ask for the restoration idiom (used in case user ran used to run an iPhone version but now running on an iPad)
//        // NSNumber containing the UIUSerInterfaceIdiom enum value of the app that saved state
//        //
//        guard let restoreUserInterfaceIdiom = coder.decodeObject(forKey: UIApplicationStateRestorationUserInterfaceIdiomKey) as? NSNumber else {
//            return
//        }
//
//        print("Restore User Interface Idiom:", restoreUserInterfaceIdiom.intValue)
//
//    }
    
    /// note: if you don't assign a restoration class to each view controller,
    /// here we need to implement "viewControllerWithRestorationIdentifierPath"
//    func application(_ application: UIApplication, viewControllerWithRestorationIdentifierPath identifierComponents: [Any], coder: NSCoder) -> UIViewController? {
//
//        /// to get our main storyboard
//        guard let storyboard = coder.decodeObject(forKey: UIStateRestorationViewControllerStoryboardKey) as? UIStoryboard else {
//            return nil
//        }
//        return nil
//    }
    
    func application(_ application: UIApplication, willEncodeRestorableStateWith coder: NSCoder) {
        NotificationCenter.default.post(name: .willEncodeRestorableState, object: nil)
    }
}
