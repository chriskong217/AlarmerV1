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
    
    override init() {
        super.init()
        notificationCenter.delegate = self
        alarms = loadAlarms()
        // Register for the willTerminateNotification
        NotificationCenter.default.addObserver(self, selector: #selector(appWillTerminate), name: UIApplication.willTerminateNotification, object: nil)
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
        content.sound = .default
        
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: alarm.time)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: alarm.isRecurring)
        
        let request = UNNotificationRequest(identifier: alarm.id.uuidString, content: content, trigger: trigger)
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
        safeAppendOrUpdate(alarm: alarm)
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        let notificationId = notification.request.identifier
            
        if let index = alarms.firstIndex(where: { $0.id.uuidString == notificationId }) {
            alarms[index].isEnabled = false
        }
        
        // Check if the app is in the background
        if UIApplication.shared.applicationState == .background {
            return []
        }
        return [.sound, .banner]
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
        }
    }
    func loadAlarms() -> [Alarm] {
        if let jsonString = UserDefaults.standard.string(forKey: "alarms"), let alarms = alarmsFromJSONString(jsonString: jsonString) {
            return alarms
        }
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
