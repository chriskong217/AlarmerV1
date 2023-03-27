//
//  AlarmScheduler.swift
//  Alarmer Test
//
//  Created by Mohamad on 3/26/23.
//

import Foundation
import UserNotifications

class AlarmScheduler {
    static let shared = AlarmScheduler()
    private let notificationManager = AlarmNotificationManager.shared
    
    private init() {}
    
    func scheduleAlarm(alarm: Alarm) {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute, .second], from: alarm.time)
        let newAlarm = Alarm(id: alarm.id, time: calendar.date(from: components)!, message: alarm.message, phoneNumber: alarm.phoneNumber, isEnabled: alarm.isEnabled, isRecurring: alarm.isRecurring)
        notificationManager.scheduleLocalNotification(alarm: newAlarm)
    }
    
    func updateAlarm(oldAlarm: Alarm, newAlarm: Alarm) {
        cancelAlarm(alarm: oldAlarm)
        scheduleAlarm(alarm: newAlarm)
    }
    
    func cancelAlarm(alarm: Alarm) {
        notificationManager.cancelLocalNotifications(for: alarm)
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

// In this implementation, the AlarmScheduler class has methods for scheduling, updating, and canceling alarms. It interacts with the AlarmNotificationManager to schedule local notifications for the alarms. Note that you'll need to replace "your_obnoxious_sound_file_name.mp3" with the name of your actual sound file.

//Make sure to create an Alarm model with properties such as id, time, isRecurring, message, and phoneNumber to store the alarm details. the code for this is below (but not sure where to put it)
//import Foundation

/*
struct Alarm: Identifiable {
    let id: UUID
    var time: Date
    var isRecurring: Bool
    var message: String
    var phoneNumber: String
    
    init(time: Date, isRecurring: Bool, message: String, phoneNumber: String, id: UUID = UUID()) {
        self.id = id
        self.time = time
        self.isRecurring = isRecurring
        self.message = message
        self.phoneNumber = phoneNumber
    }
}
*/
//Additionally, you'll need to implement the AlarmNotificationManager to handle the scheduling, canceling, and receiving of alarm notifications, as well as other classes mentioned in the app structure.

//Please note that this code is just a starting point, and you might need to adjust it to fit your app's exact requirements and logic.

//new fi;e
// new
// new 
