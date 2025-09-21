//
//  AppDelegate.swift
//  Spellbook
//
//  Created by Jonathan Carifio on 11/26/18.
//  Copyright © 2018 Jonathan Carifio. All rights reserved.
//

import UIKit
import ReSwift

typealias SpellbookStore = Store<SpellbookAppState>
let store = SpellbookStore(reducer: appReducer, state: nil, middleware: [switchProfileMiddleware, switchProfileByNameMiddleware, createProfileMiddleware, saveProfileMiddleware, saveCurrentProfileMiddleware, renameProfileMiddleware, deleteProfileMiddleware, deleteProfileByNameMiddleware, makeToastMiddleware])

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    private func saveInfo() {
        if let profile = store.state.profile {
            SerializationUtils.saveCharacterProfile(profile: profile)
        }
        SerializationUtils.saveSettings(store.state.settings)
    }

    // Disable rotation
    private let orientationLock = oniPad ? UIInterfaceOrientationMask.allButUpsideDown : UIInterfaceOrientationMask.portrait
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return self.orientationLock
    }


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        // Load all of the view controller subclasses
        // Useful for generic classes
//        for subclass in subclasses(of: UIViewController.self) {
//            subclass.load()
//        }
        
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        guard let info = shortcutItem.userInfo else {
            completionHandler(false)
            return
        }
        
        if let spellJSON = info["spell"], let type = info["type"], type as? String == "SpellView" {
            let codec = SpellCodec()
            let jsonString = spellJSON as! String
            let sion = SION(json: jsonString)
            let spell = codec.parseSpell(sion: sion)

            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let controller = storyboard.instantiateViewController(withIdentifier: "spellWindow") as! SpellWindowController
            controller.modalPresentationStyle = .fullScreen
            controller.transitioningDelegate = controller
            controller.fromShortcut = true
            Controllers.mainNavController.present(controller, animated: true, completion: { controller.spell = spell })
            completionHandler(true)
        } else {
            completionHandler(false)
        }
        
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        saveInfo()
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        saveInfo()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        saveInfo()
    }

    
    public func address(of object: Any?) -> UnsafeMutableRawPointer {
        return Unmanaged.passUnretained(object as AnyObject).toOpaque()
    }

    public func subclasses<T>(of theClass: T) -> [T] {
        var count: UInt32 = 0, result: [T] = []
        let allClasses = objc_copyClassList(&count)!
        let classPtr = address(of: theClass)

        for n in 0 ..< count {
            let someClass: AnyClass = allClasses[Int(n)]
            guard let someSuperClass = class_getSuperclass(someClass), address(of: someSuperClass) == classPtr else { continue }
            result.append(someClass as! T)
        }

        return result
    }

}

