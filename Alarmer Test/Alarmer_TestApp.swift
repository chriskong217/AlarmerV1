import SwiftUI
import UserNotifications
@main
struct Alarmer_TestApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            AlarmListView()
                .environmentObject(LocalNotificationManager.shared)
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        if LocalNotificationManager.shared.hasEnabledAlarms() {
            LocalNotificationManager.shared.sendAppTerminationNotification()
        }
    }
}
