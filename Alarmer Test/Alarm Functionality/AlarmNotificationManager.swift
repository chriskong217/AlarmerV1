//
//  AlarmNotificationManager.swift
//  Alarmer Test
//
//  Created by Mohamad on 3/26/23.
//

import Foundation
import UserNotifications

class AlarmNotificationManager: NSObject, UNUserNotificationCenterDelegate {
    
    static let shared = AlarmNotificationManager()
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }
    
    func requestNotificationAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
            if let error = error {
                print("Failed to request notification authorization: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleLocalNotification(alarm: Alarm, content: UNMutableNotificationContent) {
        let content = content
        
        let interval = 5.0
        let maxNotifications = 50
        
        for i in 0..<maxNotifications {
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: alarm.time.timeIntervalSinceNow + (interval * Double(i)), repeats: false)
            let request = UNNotificationRequest(identifier: "\(alarm.id.uuidString)-\(i)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Failed to schedule local notification: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelLocalNotifications(for alarm: Alarm) {
        let maxNotifications = 50
        let notificationIdentifiers = (0..<maxNotifications).map { "\(alarm.id.uuidString)-\($0)" }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationIdentifiers)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // Handle user interaction with the notification, e.g. dismiss the alarm
        completionHandler()
    }
}

private func createNotificationContent(alarm: Alarm) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = "Time to wake up!"
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "your_obnoxious_sound_file_name.mp3"))
        content.categoryIdentifier = "ALARM"
        content.userInfo = ["id": alarm.id]
        return content
    }

//This implementation of AlarmNotificationManager provides the required functionality to schedule, cancel, and handle local notifications. It uses a singleton pattern with the shared instance for easy access throughout the app.

// Remember to call requestNotificationAuthorization() to request the necessary permissions from the user before scheduling any notifications.
// new file
// new
// new 
