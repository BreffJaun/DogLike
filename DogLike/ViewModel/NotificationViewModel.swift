//
//  RemindMeNotificationVM.swift
//  03_W10_Notes
//
//  Created by Jeff Braun on 23.09.25.
//

import Foundation
import UserNotifications
internal import Combine

@MainActor
class NotificationViewModel: ObservableObject {
    
    @Published var areNotificationsAllowed: Bool? = nil
    @Published var customNotificationText = ""
    
    private let center = UNUserNotificationCenter.current()
    
    func requestPermission(){
        Task {
            do {
                guard areNotificationsAllowed == nil else {
                    print("Permission already requested or already determined")
                    return
                }
                
                let result = try await center.requestAuthorization(options: [.alert, .badge, .sound])
                areNotificationsAllowed = result
                
                if result {
                    scheduleNotification()
                }
                
            } catch {
                print("Notification request failed: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleNotification() {
        let content = UNMutableNotificationContent()
        
        //        var date = DateComponents()
        //        date.hour = 18
        //        date.minute = 25
        //
        content.title = "Daily Reminder"
        content.body = "Open me 😎"
        content.badge = 1
        content.sound = .default
        content.categoryIdentifier = "DAILY_REMINDER"
        
        customNotificationText = ""
        
        //        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        center.add(request) { error in
            if let error {
                print("Error while scheduling the notification: \(error.localizedDescription)")
            }
        }
    }
    
    func resetBadgeCount() {
        Task {
            do {
                try await center.setBadgeCount(0)
            } catch {
                print("Fehler beim zurücksetzen des Badgecounts: \(error.localizedDescription)")
            }
        }
    }
    
    private func scheduleMilestoneNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: UUID().uuidString,
                                            content: content,
                                            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    func checkMilestone(likes: Int, dislikes: Int) {
        print("Checking milestones: likes \(likes), dislikes \(dislikes)")
        if likes % 10 == 0 && likes != 0 {
            print("Scheduling like milestone notification")
            scheduleMilestoneNotification(title: "Milestone reached!", body: "You liked \(likes) dogs 🥳!")
        }
        
        if dislikes % 10 == 0 && dislikes != 0 {
            print("Scheduling dislike milestone notification")
            scheduleMilestoneNotification(title: "Milestone reached!", body: "You have \(dislikes) Dogs disliked 🫨!")
        }
    }
    
    func registerNotificationCategories() {
        let openAction = UNNotificationAction(
            identifier: "OPEN_APP_ACTION",
            title: "Willkommen zurück!",
            options: [.foreground]
        )
        
        let dismissAction = UNNotificationAction(
            identifier: "DISMISS_ACTION",
            title: "Schließen",
            options: []
        )
        
        let dailyCategory = UNNotificationCategory(
            identifier: "DAILY_REMINDER",
            actions: [openAction, dismissAction],
            intentIdentifiers: [],
            hiddenPreviewsBodyPlaceholder: "",
            options: .customDismissAction
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([dailyCategory])
    }
}

