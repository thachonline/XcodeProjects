//
//  SceneDelegate.swift
//  KeychainManager
//
//  Created by Bondar Yaroslav on 4/3/20.
//  Copyright © 2020 Bondar Yaroslav. All rights reserved.
//

import UIKit

extension String {
    func split(by length: Int) -> [String] {
        var startIndex = self.startIndex
        var results = [Substring]()

        while startIndex < self.endIndex {
            let endIndex = self.index(startIndex, offsetBy: length, limitedBy: self.endIndex) ?? self.endIndex
            results.append(self[startIndex..<endIndex])
            startIndex = endIndex
        }

        return results.map { String($0) }
    }
}

struct Char {
    //ascii
    let unicodeScalar: UnicodeScalar
    let character: Character
    let position: Int
}

extension Data {
    func string(radix: Int) -> String {
        return reduce("") { (str, byte) -> String in
            str + String(byte, radix: radix)
        }
    }
}

/// String.availableStringEncodings.map { String.localizedName(of: $0) }
/// String.localizedName(of: String.defaultCStringEncoding)
///"".canBeConverted(to: .utf8)
//        CFStringCreateWithCString(nil, "я", CFStringEncoding(CFStringEncodings.KOI8_R.rawValue))
//        CFStringGetNameOfEncoding(<#T##encoding: CFStringEncoding##CFStringEncoding#>)
//        CFStringIsEncodingAvailable(<#T##encoding: CFStringEncoding##CFStringEncoding#>)
//        CFStringGetSystemEncoding()
//        CFStringGetListOfAvailableEncodings()
//        kCFStringEncodingInvalidId
final class BinaryCoder {
    
    static let koi8rtNSEncoding: String.Encoding = {
        let koi8rtCFEncoding = CFStringEncoding(CFStringEncodings.KOI8_R.rawValue)
//        let name = CFStringGetNameOfEncoding(koi8rtCFEncoding)
//        print("koi8rtNSEncoding name: \(name ?? "" as CFString)")
        let koi8rtNSEncoding = CFStringConvertEncodingToNSStringEncoding(koi8rtCFEncoding)
        return String.Encoding(rawValue: koi8rtNSEncoding) // String.Encoding(rawValue: 2147486210)
    }()
    
    static var availableStringEncodings: [String.Encoding] {
        return String.availableStringEncodings
    }
    
    func decode(_ decodingString: String) -> String {
        
        return ""
    }
    
    func encodeInAll(_ encodingString: String) -> [String] {
        return Self.availableStringEncodings.compactMap { encode(encodingString, in: $0) }
    }
    
    func encode(_ encodingString: String, in encoding: String.Encoding) -> String? {
        return encodingString
            .data(using: encoding, allowLossyConversion: false)
            .map { $0.string(radix: 2) }
                /// availableStringEncodings source https://github.com/jie-json/swift-corelibs-foundation-master/blob/9dcd02178d6516c137fc3970f87090904f334acd/Foundation/NSString.swift
                /// online Binary Converter https://www.rapidtables.com/convert/number/ascii-to-binary.html
                
                
                
                //let q = "0000111000101101001011110001010000001110001011100001101100001110001011110001101000001110001011110010111100010100000011100010111000011100000011100010111000101110000011100010111100011001000011100010111100101110"
                
                //let mirror = "0111010011110100011100001001100011110100011100000111010001110100011100000011100001110100011100000010100011110100111101000111000001011000111101000111000011011000011101000111000000101000111101001011010001110000"
                
                //let q = "01101000 01100101 01101100 01101100 01101111".replacingOccurrences(of: " ", with: "")
                
                //print(Unicode.Scalar("A").value)
                
                
                //"я вся горю"
                
                let q = "11010001 10001111 00100000 11010000 10110010 11010001 10000001 11010001 10001111 00100000 11010000 10110011 11010000 10111110 11010001 10000000 11010001 10001110"
                    .replacingOccurrences(of: " ", with: "")
                
                let unicodeRange = UnicodeScalar("а").value...UnicodeScalar("я").value
                
                let xx = unicodeRange.map({ Character(UnicodeScalar($0)!) })
                
                let chars = unicodeRange.enumerated().map { arg -> Char in
                    let unicode = UnicodeScalar(arg.element)!
                    //let unicodePosition = Int(unicode.value) % unicodeRange.count
                    return Char(unicodeScalar: unicode, character: Character(unicode), position: arg.offset)
                }
                
                print(chars)
                
                chars.map({ $0.unicodeScalar.value % 32 })
                
                print(xx, String(xx))
                
                print(unicodeRange.count)
                print(unicodeRange.map({ ( Character(UnicodeScalar($0)!)  , $0 % 33) }))
        //        for value in zz.map({$0 % 33}) {
        //            print(value)
        //        }
                
                //print(q)
                //print(q.count)
                let w = q.split(by: 8)
                    //.map({ String($0.reversed()) })
                let e = w.map({ Int($0, radix: 2)! })
                    //.filter({ $0 <= 32})
        //            .map({ $0 % 33 })
                let r = e.map({ Character(UnicodeScalar($0)!) })
                //print(w)
                print(e, e.count)
                print(r)
                print("-|\n",String(r), "\n|-")
                
        //        let q = 0b00001110 00101101 00101111 00010100 00
        //        Character("0b00001110")
        //        let w = Character(UnicodeScalar(0b00001110))
        //        print(q, w)
        
        return ""
    }
    
}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        let encodingString = "я"
        print(
            BinaryCoder().encodeInAll(encodingString),
            "\n",
            BinaryCoder().encode(encodingString, in: BinaryCoder.koi8rtNSEncoding) ?? "nil"
        )
        
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

