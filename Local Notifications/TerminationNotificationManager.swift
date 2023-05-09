//
//  TerminationNotificationManager.swift
//  Alarmer Test
//
//  Created by Kong, Chris on 4/23/23.
//

import Foundation
import UserNotifications

struct TerminationNotificationManager {
    static func scheduleTerminationNotification(alarms: [Alarm]) {
        if alarms.isEmpty {
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Oops, you terminated Alarmer!"
        content.body = "Your alarm may not ring. Please leave Alarmer running in the background so that your alarm can ring with sound."

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(identifier: "terminationNotification", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling termination notification: \(error)")
            }
        }
    }
}

