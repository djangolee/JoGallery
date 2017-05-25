//
//  JoAppDelegate.swift
//  Example
//
//  Created by Django on 5/25/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit

@UIApplicationMain

class JoAppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let rootViewController = JoViewController()
        let navigationController = JoNavigationController(rootViewController: rootViewController)
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = navigationController
        self.window?.backgroundColor = UIColor.white
        self.window?.makeKeyAndVisible()
        
        return true
    }
}
