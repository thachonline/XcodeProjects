//
//  AppDelegate.swift
//  MuteMic
//
//  Created by Bondar Yaroslav on 8/17/19.
//  Copyright © 2019 Bondar Yaroslav. All rights reserved.
//

import Cocoa

// TODO: clear file
// TODO: clear storyboard and window
// TODO: right click menu (statusItemMenu)
// TODO: launch at login

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    let statusItemManager = StatusItemManager()
    let audioManager = AudioManager.shared

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        statusItemManager.setup()
        
        statusItemManager.setImage(for: audioManager.isMuted())
        audioManager.didChange = { [weak self] isMuted in
            DispatchQueue.main.async {
                self?.statusItemManager.setImage(for: isMuted)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {}
}


/// can be handled in system "Audio MIDI Setup.app"
/// mute touchBar https://github.com/CocoaHeadsBrasil/MuteUnmuteMic
/// mute https://github.com/pixel-point/mute-me
/// swift Audio https://github.com/Sunnyyoung/Suohai
final class AudioManager {
    
    static let shared = AudioManager()
    
    /// called in background twice!!
    var didChange: ((_ isMuted: Bool) -> Void)?
    
    private var defaultInputDevicePropertyAddress = AudioObjectPropertyAddress(
        mSelector: kAudioHardwarePropertyDefaultInputDevice,
        mScope: kAudioObjectPropertyScopeGlobal,
        mElement: kAudioObjectPropertyElementMaster)
    
    private var mutePropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyMute,
                                                                 mScope: kAudioDevicePropertyScopeInput,
                                                                 mElement: kAudioObjectPropertyElementMaster)
    
    private let systemInputDeviceID = AudioObjectID(kAudioObjectSystemObject)
    private var currentInputDeviceID = AudioObjectID(kAudioObjectUnknown)
    private var propertySize = UInt32(MemoryLayout<UInt32>.size)
    
    init() {
        setupCurrentInputDeviceID()
        startListener()
    }
    
    deinit {
        stopListener()
    }
    
    private func setupCurrentInputDeviceID() {
        AudioObjectGetPropertyData(systemInputDeviceID, &defaultInputDevicePropertyAddress, 0, nil, &propertySize, &currentInputDeviceID).handleError()
        assert(currentInputDeviceID != kAudioObjectUnknown)
    }
    
    func isMuted() -> Bool {
        var isMuted: DarwinBoolean = false
        AudioObjectGetPropertyData(currentInputDeviceID, &mutePropertyAddress, 0, nil, &propertySize, &isMuted).handleError()
        return isMuted.boolValue
    }
    
    func setMute(_ mute: Bool) {
        var toggleMute: UInt32 = mute ? 1 : 0
        AudioObjectSetPropertyData(currentInputDeviceID, &mutePropertyAddress, 0, nil, propertySize, &toggleMute).handleError()
    }
    
    func toogleMute() {
        assert(isMuteSettable())
        setMute(!isMuted())
    }
    
    private func isMuteSettable() -> Bool {
        var isSettable: DarwinBoolean = false
        AudioObjectIsPropertySettable(currentInputDeviceID, &mutePropertyAddress, &isSettable).handleError()
        return isSettable.boolValue
    }
    
    // MARK: - Listener
    
    private func startListener() {
        /// https://stackoverflow.com/a/33310021/5893286
        let selfPointer = Unmanaged.passUnretained(self).toOpaque()
        
        /// can be used AudioObjectRemovePropertyListenerBlock
        AudioObjectAddPropertyListener(systemInputDeviceID, &defaultInputDevicePropertyAddress, defaultInputDeviceListener, selfPointer).handleError()
        AudioObjectAddPropertyListener(currentInputDeviceID, &mutePropertyAddress, muteListener, selfPointer).handleError()
    }
    
    private func stopListener() {
        let selfPonter = Unmanaged.passUnretained(self).toOpaque()
        AudioObjectRemovePropertyListener(systemInputDeviceID, &defaultInputDevicePropertyAddress, defaultInputDeviceListener, selfPonter).handleError()
        AudioObjectRemovePropertyListener(currentInputDeviceID, &mutePropertyAddress, muteListener, selfPonter).handleError()
    }
    
    /// doesn't called on headphone connection
    private let defaultInputDeviceListener: AudioObjectPropertyListenerProc = { _, _, _, selfPointer in
        selfPointer.assertExecute {
            let audioManager = Unmanaged<AudioManager>.fromOpaque($0).takeUnretainedValue()
            audioManager.deviceDidChange()
        }
        return kAudioHardwareNoError
    }
    
    private let muteListener: AudioObjectPropertyListenerProc = { _, _, _, selfPointer in
        selfPointer.assertExecute {
            let audioManager = Unmanaged<AudioManager>.fromOpaque($0).takeUnretainedValue()
            audioManager.muteDidChange()
        }
        return kAudioHardwareNoError
    }
    
    private func deviceDidChange() {
        assert(currentInputDeviceID != kAudioObjectUnknown)
        let savedMute = isMuted()
        stopListener()
        
        setupCurrentInputDeviceID()
        
        setMute(savedMute)
        startListener()
        print("-",savedMute)
    }
    
    private func muteDidChange() {
        didChange?(isMuted())
    }
}

extension Optional {
    func assert(or defaultValue: Wrapped) -> Wrapped {
        switch self {
        case .none:
            assertionFailure()
            return defaultValue
        case .some(let value):
            return value
        }
    }
    
    /**
     it is nonescaping, so there is no perfermance issue
     
         text.assertExecute { print($0) }
     
    vs
     
         if let text = text {
             print(text)
         } else {
             assertionFailure()
         }
    
    */
    // TODO: check with and without "rethrows"
    func assertExecute(_ action: (Wrapped) throws -> Void) rethrows {
        switch self {
        case .none:
            assertionFailure()
        case .some(let value):
            try action(value)
        }
    }
}


//import AudioToolbox
import CoreAudio


//    private func get() {
//        var propertySize: UInt32 = 0
//
//        // Get the size of the property in the kAudioObjectSystemObject so we can make space to store it
//        AudioObjectGetPropertyDataSize(systemID, &inputDeviceAddress, 0, nil, &propertySize).handleError()
//
//        assert(propertySize == UInt32(MemoryLayout<UInt32>.size))
//
//        let numberOfDevices = Int(propertySize) / MemoryLayout<AudioDeviceID>.size
//        var deviceIDs = [AudioDeviceID](repeating: AudioDeviceID(), count: numberOfDevices)
//        AudioObjectGetPropertyData(systemID, &inputDeviceAddress, 0, nil, &propertySize, &deviceIDs).handleError()
//
//
//
//    }

/// big app https://github.com/kyleneideck/BackgroundMusic
/// app https://github.com/mattingalls/Soundflower
/// depricated volume https://github.com/drudge/MacDroidNotifier/blob/master/SoundVolume.m
/// swift sample https://stackoverflow.com/a/38982906/5893286
/// mute micro https://github.com/pixel-point/mute-me/blob/master/Mute%20Me%20Now/AppDelegate.m
func getInputDevices() throws -> [AudioDeviceID] {
    
    var inputDevices: [AudioDeviceID] = []
    
    // Construct the address of the property which holds all available devices
    var devicesPropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioHardwarePropertyDevices, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
    var propertySize = UInt32(0)
    
    // Get the size of the property in the kAudioObjectSystemObject so we can make space to store it
    try handle(AudioObjectGetPropertyDataSize(AudioObjectID(kAudioObjectSystemObject), &devicesPropertyAddress, 0, nil, &propertySize))
    
    // Get the number of devices by dividing the property address by the size of AudioDeviceIDs
    
    let numberOfDevices = Int(propertySize) / MemoryLayout<AudioDeviceID>.size//sizeof(AudioDeviceID.self)
    
    // Create space to store the values
    var deviceIDs: [AudioDeviceID] = []
    for _ in 0 ..< numberOfDevices {
        deviceIDs.append(AudioDeviceID())
    }
    
    // Get the available devices
    try handle(AudioObjectGetPropertyData(AudioObjectID(kAudioObjectSystemObject), &devicesPropertyAddress, 0, nil, &propertySize, &deviceIDs))
    
    // Iterate
    for id in deviceIDs {
        
        // Get the device name for fun
        var name: CFString = "" as CFString
        var propertySize = UInt32(MemoryLayout<AudioDeviceID>.size)// sizeof(CFString.self))
        var deviceNamePropertyAddress = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyDeviceNameCFString, mScope: kAudioObjectPropertyScopeGlobal, mElement: kAudioObjectPropertyElementMaster)
        try handle(AudioObjectGetPropertyData(id, &deviceNamePropertyAddress, 0, nil, &propertySize, &name))
        
        // Check the input scope of the device for any channels. That would mean it's an input device
        
        // Get the stream configuration of the device. It's a list of audio buffers.
        var streamConfigAddress = AudioObjectPropertyAddress(mSelector: kAudioDevicePropertyStreamConfiguration, mScope: kAudioDevicePropertyScopeInput, mElement: 0)
        
        // Get the size so we can make room again
        try handle(AudioObjectGetPropertyDataSize(id, &streamConfigAddress, 0, nil, &propertySize))
        
        // Create a buffer list with the property size we just got and let core audio fill it
        let audioBufferList = AudioBufferList.allocate(maximumBuffers: Int(propertySize))
        try handle(AudioObjectGetPropertyData(id, &streamConfigAddress, 0, nil, &propertySize, audioBufferList.unsafeMutablePointer))
        
        // Get the number of channels in all the audio buffers in the audio buffer list
        var channelCount = 0
        for i in 0 ..< Int(audioBufferList.unsafeMutablePointer.pointee.mNumberBuffers) {
            channelCount = channelCount + Int(audioBufferList[i].mNumberChannels)
        }
        
        free(audioBufferList.unsafeMutablePointer)
        
        // If there are channels, it's an input device
        if channelCount > 0 {
            Swift.print("Found input device '\(name)' with \(channelCount) channels")
            inputDevices.append(id)
        }
    }
    
    return inputDevices
}

func handle(_ errorCode: OSStatus) throws {
    if errorCode != kAudioHardwareNoError {
        //let error = NSError(domain: NSOSStatusErrorDomain, code: Int(errorCode), userInfo: [NSLocalizedDescriptionKey : "CAError: \(errorCode)" ])
        print("- error code:", errorCode)
        //NSApplication.shared.presentError(error)
        //throw error
    }
}

extension OSStatus {
    func handleError() {
        assert(self == kAudioHardwareNoError, "reason: \(self)")
    }
}
