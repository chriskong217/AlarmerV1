import Foundation
import UserNotifications
import UIKit
@MainActor
class LocalNotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = LocalNotificationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    @Published var isAuthorized = false
    @Published var alarms: [Alarm] = [] {
        didSet {
            saveAlarms()
        }
    }
    
    @objc private func appDidBecomeActive() {
        updateAlarmsState()
    }
    
    func updateAlarmsState() {
        notificationCenter.getDeliveredNotifications { [weak self] deliveredNotifications in
            guard let self = self else { return }
            
            for deliveredNotification in deliveredNotifications {
                let notificationId = deliveredNotification.request.identifier
                if let index = self.alarms.firstIndex(where: { $0.id.uuidString == notificationId }) {
                    if !self.alarms[index].isRecurring {
                        DispatchQueue.main.async {
                            self.alarms[index].isEnabled = false
                        }
                    }
                }
            }
            
            self.notificationCenter.getPendingNotificationRequests { [weak self] pendingRequests in
                guard let self = self else { return }
                
                for request in pendingRequests {
                    let notificationId = request.identifier
                    if let index = self.alarms.firstIndex(where: { $0.id.uuidString == notificationId }) {
                        if !self.alarms[index].isRecurring {
                            let trigger = request.trigger as? UNCalendarNotificationTrigger
                            let now = Date()
                            let alarmTime = trigger?.nextTriggerDate()
                            
                            if let alarmTime = alarmTime, alarmTime < now {
                                DispatchQueue.main.async {
                                    self.alarms[index].isEnabled = false
                                }
                            }
                        }
                    }
                }
            }
        }
    }


    override init() {
        super.init()
        notificationCenter.delegate = self
        alarms = loadAlarms()
        // Register for the willTerminateNotification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)

    }
    @objc private func appWillTerminate() {
        if hasEnabledAlarms() {
            sendAppTerminationNotification()
        }
    }
    func hasEnabledAlarms() -> Bool {
           return alarms.contains { $0.isEnabled }
       }
       
    func sendAppTerminationNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Oops, you terminated Alarmer!"
        content.subtitle = "Your alarm may not ring. Please leave Alarmer running in the background so that your alarm can ring with sound."
        content.sound = .default
        let randomDelay = TimeInterval(Int.random(in: 1...5))
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1 + randomDelay, repeats: false)
        let request = UNNotificationRequest(identifier: "AppTerminationNotification", content: content, trigger: trigger)
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling termination notification: \(error)")
            }
        }
    }
    func requestAuthorization() async throws {
        try await notificationCenter
            .requestAuthorization(options: [
                .sound, .badge, .alert
            ])
        await getCurrentSettings()
    }
    
    func getCurrentSettings() async {
        let currentSettings = await notificationCenter.notificationSettings()
        
        isAuthorized = currentSettings.authorizationStatus == .authorized
    }
    
    func scheduleNotification(alarm: Alarm) {
        let content = UNMutableNotificationContent()
        content.title = "Alarm"
        content.body = alarm.message
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "Alarm sound effect.mp3"))
        let alarmHourMinute = Calendar.current.dateComponents([.hour, .minute], from: alarm.time)

        let triggerDate = Calendar.current.date(bySettingHour: alarmHourMinute.hour!, minute: alarmHourMinute.minute!, second: 0, of: alarm.time)
        let triggerComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: triggerDate!)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: alarm.isRecurring)

        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)

        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
        safeAppendOrUpdate(alarm: alarm)
    }

    func disableAlarm(id: UUID) {
        if let index = alarms.firstIndex(where: { $0.id == id }) {
            alarms[index].isEnabled = false
        }
    }

    func updateAlarmList() {
        DispatchQueue.main.async {
            self.alarms = self.alarms
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let notificationId = response.notification.request.identifier

        if let index = alarms.firstIndex(where: { $0.id.uuidString == notificationId }) {
            if !alarms[index].isRecurring {
                DispatchQueue.main.async {
                    self.alarms[index].isEnabled = false
                    self.updateAlarmList()
                    self.saveAlarms()
                    print("Updated alarm status: \(self.alarms[index])")

                }
            }
        }
        completionHandler()
    }



    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
    
    func alarmsToJSONString(alarms: [Alarm]) -> String? {
        let encoder = JSONEncoder()
        do {
            let jsonData = try encoder.encode(alarms)
            return String(data: jsonData, encoding: .utf8)
        } catch {
            print("Error encoding alarms: \(error)")
            return nil
        }
    }
    
    func alarmsFromJSONString(jsonString: String) -> [Alarm]? {
        let decoder = JSONDecoder()
        if let jsonData = jsonString.data(using: .utf8) {
            do {
                let alarms = try decoder.decode([Alarm].self, from: jsonData)
                return alarms
            } catch {
                print("Error decoding alarms: \(error)")
                return nil
            }
        }
        return nil
    }
    
    func saveAlarms() {
        if let jsonString = alarmsToJSONString(alarms: alarms) {
            UserDefaults.standard.set(jsonString, forKey: "alarms")
            print("Alarms saved to UserDefaults: \(jsonString)")

        }
    }
    func loadAlarms() -> [Alarm] {
        if let jsonString = UserDefaults.standard.string(forKey: "alarms"), let alarms = alarmsFromJSONString(jsonString: jsonString) {
            print("Alarms loaded from UserDefaults: \(jsonString)")
            return alarms
        }
        print("No alarms found in UserDefaults")
        return []
    }
    
    func safeAppendOrUpdate(alarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
            alarms[index] = alarm
        } else {
            alarms.append(alarm)
        }
        
        // Sort alarms based on their scheduled time
        alarms = alarms.sorted(by: { $0.time < $1.time })
    }
}
