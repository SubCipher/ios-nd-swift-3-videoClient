//
//  AppDelegate.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/6/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit

@UIApplicationMain


class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool {
        
        if let sourceApplication = options[.sourceApplication] {
            if (String(describing: sourceApplication) == "com.apple.SafariViewService") {
                NotificationCenter.default.post(name: Notification.Name("codeRequest"), object: url)
                return true
            }
        }
        
        return false
    }

    
    
        
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
               
        return true
    }
}

