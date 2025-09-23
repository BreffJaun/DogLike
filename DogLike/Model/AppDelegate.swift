//
//  AppDelegate.swift
//  DogLike
//
//  Created by Jeff Braun on 23.09.25.
//

import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        let center = UNUserNotificationCenter.current()
        center.delegate = self

        let notificationVM = NotificationViewModel()
        notificationVM.registerNotificationCategories()

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        
        switch response.actionIdentifier {
        case "OPEN_APP_ACTION":
            NotificationCenter.default.post(name: NSNotification.Name("OpenAppActionTriggered"), object: nil)
        case "DISMISS_ACTION":
            break
        default:
            break
        }
        
        completionHandler()
    }
}
