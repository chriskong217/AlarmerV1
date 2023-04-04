import SwiftUI
import UserNotifications
struct AlarmListView: View {
    @EnvironmentObject var lnManager: LocalNotificationManager
    @State private var alarms: [Alarm] = []
    @State private var isPresentingAlarmDetailView = false
    @State private var selectedAlarm: Alarm?
    @State private var showDeleteButton: Bool = false
    @State private var showEnableNotificationsView = false
    @State private var proceedWithoutAuth: Bool = false
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false
    private func loadSavedAlarms() {
        alarms = lnManager.loadAlarms()
    }
    func refreshNotificationAuthorizationStatus() {
        Task {
            do {
                try await lnManager.requestAuthorization()
            } catch {
                print("Error requesting authorization: \(error)")
            }
            showEnableNotificationsView = !lnManager.isAuthorized
        }
    }
    func updateAlarm(_ updatedAlarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == updatedAlarm.id }) {
            let wasEnabled = alarms[index].isEnabled
            alarms[index] = updatedAlarm
            if wasEnabled != updatedAlarm.isEnabled {
                if updatedAlarm.isEnabled {
                    lnManager.scheduleNotification(alarm: updatedAlarm)
                } else {
                    lnManager.notificationCenter.removePendingNotificationRequests(withIdentifiers: [updatedAlarm.id.uuidString])
                }
            } else if updatedAlarm.isEnabled {
                lnManager.notificationCenter.removePendingNotificationRequests(withIdentifiers: [updatedAlarm.id.uuidString])
                lnManager.scheduleNotification(alarm: updatedAlarm)
            }
        }
        lnManager.alarms = alarms
    }
    func toggleAlarmEnabled(_ index: Int) {
        alarms[index].isEnabled.toggle()
        if alarms[index].isEnabled {
            lnManager.scheduleNotification(alarm: alarms[index])
        } else {
            lnManager.notificationCenter.removePendingNotificationRequests(withIdentifiers: [alarms[index].id.uuidString])
        }
        lnManager.alarms = alarms
    }
    var body: some View {
        Group {
            if proceedWithoutAuth {
                authorizedView
            } else {
                if showEnableNotificationsView {
                    EnableNotifications(showEnableNotifications: $showEnableNotificationsView, onProceedAnyway: {
                        proceedWithoutAuth = true
                    })
                } else {
                    authorizedView
                }
            }
        }
        .onAppear {
            refreshNotificationAuthorizationStatus()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIScene.willEnterForegroundNotification)) { _ in
            refreshNotificationAuthorizationStatus()
        }
    }
    var authorizedView: some View {
        NavigationView {
            ZStack {
                ScrollView {
                    VStack(spacing: 0) {
                        ForEach(alarms.indices, id: \.self) { index in
                            Button(action: {
                                selectedAlarm = alarms[index]
                            }) {
                                AlarmRow(alarm: $alarms[index], onToggle: {
                                    toggleAlarmEnabled(index)
                                })
                            }
                            .padding(.vertical, 15)
                        }
                    }
                }
                .navigationTitle("Alarmers")
                .onAppear(perform: loadSavedAlarms)
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            selectedAlarm = Alarm(time: Date(), message: "", phoneNumber: "", isEnabled: false, isRecurring: false)
                        }) {
                            ZStack {
                                Circle()
                                    .frame(width: 80, height: 80)
                                    .foregroundColor(Color(red: 1, green: 0.72, blue: 0)).shadow(radius: 4, y: 4)
                                Image(systemName: "plus")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40, weight: .bold))
                            }
                        }
                        .padding(.bottom, 20)
                        .padding(.trailing, 25)
                    }
                }
                .sheet(item: $selectedAlarm) { alarm in
                    if let index = alarms.firstIndex(where: { $0.id == alarm.id }) {
                        AlarmDetailView(alarm: .constant(alarms[index]), showDeleteButton: .constant(true), onSave: { updatedAlarm in
                            updateAlarm(updatedAlarm)
                            selectedAlarm = nil
                        }, onDelete: {
                            alarms.remove(at: index)
                            lnManager.alarms = alarms
                            selectedAlarm = nil
                        })
                    } else {
                        AlarmDetailView(alarm: .constant(alarm), showDeleteButton: .constant(false), onSave: { newAlarm in
                            alarms.append(newAlarm)
                            lnManager.alarms = alarms
                            selectedAlarm = nil
                        })
                    }
                }
                .accentColor(Color(red: 1, green: 0.72, blue: 0))
            }
        }
    }
}
struct AlarmRow: View {
    @Binding var alarm: Alarm
    var onToggle: () -> Void
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(alarm.isEnabled
                  ? Color(red: 1, green: 0.82, blue: 0.34)
                  : Color(red: 0.89, green: 0.87, blue: 0.84)).frame(width: 326, height: 114).shadow(radius: 4, y: 4)
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(alarm.isRecurring ? "Recurring" : "Not Recurring")
                            .font(.subheadline)
                            .foregroundColor(alarm.isEnabled ? Color.black : Color(red: 0.44, green: 0.43, blue: 0.43))
                        Text(Formatters.timeFormatter.string(from: alarm.time)).font(.system(size: 34))
                            .fontWeight(.bold)
                            .foregroundColor(alarm.isEnabled ? Color.black : Color(red: 0.44, green: 0.43, blue: 0.43))
                    }
                    Spacer()
                    Button(action: {
                        withAnimation {
                            onToggle()
                        }
                    }) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 25)
                                .frame(width: 83, height: 41)
                                .foregroundColor(alarm.isEnabled ? Color(red: 1, green: 0.72, blue: 0) : .gray)
                            Circle()
                                .frame(width: 30, height: 30)
                                .foregroundColor(.white)
                                .offset(x: alarm.isEnabled ? 20 : -20)
                        }
                    }
                    .buttonStyle(BorderlessButtonStyle())
                }
                .padding()
            )
    }
}
struct AlarmListView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmListView()
            .environmentObject(LocalNotificationManager())
    }
}
