//
//  AppDelegate.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 17.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        let mainViewController = AGLMainViewController()
        self.window?.rootViewController = UINavigationController(rootViewController: mainViewController)
        self.window?.makeKeyAndVisible()
        
        let directory: URL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: "group.com.aglTaskapp")!
        AGLRealmManager.shared.setupDataStorage(directory)
        
        return true
    }
    
    // MARK: UISceneSession Lifecycle
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    }
}
