//
//  AppDelegate.swift
//  Keyboard Connect Open Source
//
//  Created by Arthur Yidi on 4/11/16.
//  Copyright © 2016 Arthur Yidi. All rights reserved.
//

import AppKit
import Foundation
import IOBluetooth

final class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let permissionManager = PermissionManager()
    private var btKey: BTKeyboard?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        startOrAskPermissions()
    }
    
    private func startOrAskPermissions() {
        if permissionManager.isAccessibilityAvailableWithoutAlert() {
            start()
        } else {
            askPermissions()
            startOrAskPermissions()
        }
    }
    
    private func askPermissions() {
        let alert = NSAlert()
        let appName = "Keyboard Connect Open Source"
        alert.messageText = "Enable \(appName)"
        alert.informativeText = "Once you have enabled \"\(appName)\" in System Preferences, click OK."
        alert.addButton(withTitle: "Retry")
        alert.addButton(withTitle: "Open System Preference")
        alert.addButton(withTitle: "Quit")
        
        let result = alert.runModal()
//        let isQuitButtonPressed = (result == .alertSecondButtonReturn)
//
//        if isQuitButtonPressed {
//            NSApp.terminate(self)
//        }
        
        switch result {
        case .alertFirstButtonReturn:
            break
        case .alertSecondButtonReturn:
            openSecurityPane()
        case .alertThirdButtonReturn:
            NSApp.terminate(self)
        default:
            assertionFailure()
        }
    }
    
    /// https://macosxautomation.com/system-prefs-links.html
    /// https://stackoverflow.com/a/6658201
    func openSecurityPane() {
        let prefpaneUrl = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_Accessibility")!
        NSWorkspace.shared.open(prefpaneUrl)

        /// https://github.com/cho45/KeyCast/blob/master/KeyCast/Accessibility.swift
        // openURL 使うのが最も簡単だが、アクセシビリティの項目まで選択された状態で開くことができない
//        NSWorkspace.shared.open( NSURL.fileURL(withPath: "/System/Library/PreferencePanes/Security.prefPane") )
        
        // ScriptingBridge を使い、表示したいところまで自動で移動させる
        // open System Preference -> Security and Privacy -> Accessibility
//        let prefs = SBApplication.applicationWithBundleIdentifier("com.apple.systempreferences")! as! SBSystemPreferencesApplication
//        prefs.activate()
//        for pane_ in prefs.panes! {
//            let pane = pane_ as! SBSystemPreferencesPane
//            if pane.id == "com.apple.preference.security" {
//                for anchor_ in pane.anchors! {
//                    let anchor = anchor_ as! SBSystemPreferencesAnchor
//                    if anchor.name == "Privacy_Accessibility" {
//                        println(pane, anchor)
//                        anchor.reveal!()
//                        break
//                    }
//                }
//                break
//            }
//        }
    }
    
    let eventHandler = EventHandler()
    
    private func start() {
        btKey = BTKeyboard()
        eventHandler.delegate = self
        eventHandler.start()
    }
    
    func applicationDidBecomeActive(_ notification: Notification) {

    }
    
//    func applicationShouldTerminate(_ sender: NSApplication) -> NSApplication.TerminateReply {
//        print("ShouldTerminate")
//        return .terminateNow
//    }

    func applicationWillTerminate(aNotification: NSNotification) {
        print("WillTerminate")
        btKey?.terminate()
    }
    
    deinit {
        print("-- deinit")
    }
}

/// AXObserverAddNotification
/// https://stackoverflow.com/questions/853833/how-can-my-app-detect-a-change-to-another-apps-window
///
final class PermissionManager {
//    static let shared = PermissionManager()
    
    /// "System Preferences - Security & Privacy - Privacy - Accessibility".
    func isAccessibilityAvailable() -> Bool {
        /// will not open system alert
        //return AXIsProcessTrusted()
        
        /// open system alert to the settings
        /// https://stackoverflow.com/a/36260107
        let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        return AXIsProcessTrustedWithOptions(options)
    }
    
    func isAccessibilityAvailableWithoutAlert() -> Bool {
        /// will not open system alert
        /// or #1
        return AXIsProcessTrusted()
        
        /// or #2
        //let options = [kAXTrustedCheckOptionPrompt.takeRetainedValue(): false] as CFDictionary
        //return AXIsProcessTrustedWithOptions(options)
    }
}

extension AppDelegate: EventHandlerDelegate {
    func send(keyCode: UInt8, modifier: UInt8) {
        btKey?.sendKey(keyCode: keyCode, modifier: modifier)
    }
    
    func quite() {
        btKey?.terminate()
        NSApp.terminate(nil)
    }
    
    
}

protocol EventHandlerDelegate: class {
    func send(keyCode: UInt8, modifier: UInt8)
    func quite()
}

final class EventHandler {
    
    weak var delegate: EventHandlerDelegate?
    
    func start() {
        
        let cgEventCallback: CGEventTapCallBack = { _, eventType, cgEvent, rawPointer in
            
            guard NSApp.isActive else {
                
                /// https://stackoverflow.com/a/5785895
                /// 0x0b is the virtual keycode for "b"
                /// 0x09 is the virtual keycode for "v"
                //if cgEvent.getIntegerValueField(.keyboardEventKeycode) == 0x0B {
                //    cgEvent.setIntegerValueField(.keyboardEventKeycode, value: 0x09)
                //}
                
                return Unmanaged.passUnretained(cgEvent)
            }

            guard let rawPointer = rawPointer, let event = NSEvent(cgEvent: cgEvent) else {
                assertionFailure()
                return nil
            }
            
            let eventHandler = Unmanaged<EventHandler>.fromOpaque(rawPointer).takeUnretainedValue()
            eventHandler.logKey(eventType: eventType, cgEvent: cgEvent)
            
            switch eventType {
            case .keyUp:
                eventHandler.sendKey(vkeyCode: -1, event.modifierFlags)
            case .keyDown:
                eventHandler.sendKey(vkeyCode: Int(event.keyCode), event.modifierFlags)
            default:
                assertionFailure("possible eventType set in 'let eventMask: CGEventMask'. this: \(eventType.rawValue)")
                //break
            }
            
            /// call after all
            eventHandler.handleQuite(eventType: eventType, cgEvent: cgEvent)
            
            /// to remove error sound pass nil
            return nil
            //return Unmanaged.passUnretained(cgEvent)
        }
        
        /// https://stackoverflow.com/a/31898592
        let eventMask: CGEventMask = (1 << CGEventType.keyUp.rawValue) | (1 << CGEventType.keyDown.rawValue)// | (1 << CGEventType.flagsChanged.rawValue)
        
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        guard let eventTap = CGEvent.tapCreate(tap: .cgSessionEventTap,
                                               place: .headInsertEventTap,
                                               options: .defaultTap,
                                               eventsOfInterest: eventMask,
                                               callback: cgEventCallback,
                                               userInfo: selfPointer)
            else {
                assertionFailure("called without Accessibility permission. search AXIsProcessTrustedWithOptions")
                return
        }
        
        
        let runLoopSource = CFMachPortCreateRunLoopSource(kCFAllocatorDefault, eventTap, 0)
        CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, .commonModes)
        CGEvent.tapEnable(tap: eventTap, enable: true)
        //CFRunLoopRun()
        
    }
    
    private func sendKey(vkeyCode: Int, _ modifierFlags: NSEvent.ModifierFlags) {
        var modifier: UInt8 = 0
        
        if modifierFlags.contains(.command) {
            modifier |= (1 << 3)
        }
        if modifierFlags.contains(.option) {
            modifier |= (1 << 2)
        }
        if modifierFlags.contains(.shift) {
            modifier |= (1 << 1)
        }
        if modifierFlags.contains(.control) {
            modifier |= 1
        }
        
        let keyCode = UInt8(virtualKeyCodeToHIDKeyCode(vKeyCode: vkeyCode))
        delegate?.send(keyCode: keyCode, modifier: modifier)
    }
    
    private func handleQuite(eventType: CGEventType, cgEvent: CGEvent) {
        guard eventType == .keyDown, cgEvent.flags.contains(.maskCommand) else {
            return
        }
        var char = UniChar()
        var length = 0
        cgEvent.keyboardGetUnicodeString(maxStringLength: 1, actualStringLength: &length, unicodeString: &char)
        
        /// 113 = q or cmd+q
        if char == 113 {
            delegate?.quite()
        }
    }
    
    private func logKey(eventType: CGEventType, cgEvent: CGEvent) {
        
        /// https://stackoverflow.com/a/44507450
        if eventType == .keyDown {
            let flags = cgEvent.flags
            var msg = ""
            
            if flags.contains(.maskAlphaShift) {
                msg+="caps+"
            }
            if flags.contains(.maskShift) {
                msg+="shift+"
            }
            if flags.contains(.maskControl) {
                msg+="control+"
            }
            if flags.contains(.maskAlternate) {
                msg+="option+"
            }
            if flags.contains(.maskCommand) {
                msg += "command+"
            }
            if flags.contains(.maskSecondaryFn) {
                msg += "function+"
            }
            
            assert(eventType != .flagsChanged, "NSEvent.charactersIgnoringModifiers will crash on .flagsChanged")
            if let event = NSEvent(cgEvent: cgEvent), let chars = event.charactersIgnoringModifiers {
                msg += chars
                print(msg)
            }
        }
    }
}
