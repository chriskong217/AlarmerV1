//
//  TestView.swift
//  Alarmer Test
//
//  Created by user232951 on 3/27/23.
//


import SwiftUI

struct TestView: View {
    @State private var date = Date()
    @State private var alarm: Alarm?

    var body: some View {
        VStack(spacing: 20) {
            DatePicker("Alarm Time", selection: $date, displayedComponents: .hourAndMinute)
                .labelsHidden()

            Button(action: {
                let newAlarm = Alarm(id: UUID(), time: date, message: "Test message", phoneNumber: "1234567890", isEnabled: true, isRecurring: false)
                if let alarm = alarm {
                    AlarmScheduler.shared.updateAlarm(oldAlarm: alarm, newAlarm: newAlarm)
                } else {
                    AlarmScheduler.shared.scheduleAlarm(alarm: newAlarm)
                }
                self.alarm = newAlarm
            }) {
                Text("Schedule/Update Alarm")
            }

            if alarm != nil {
                Button(action: {
                    if let alarm = alarm {
                        AlarmScheduler.shared.cancelAlarm(alarm: alarm)
                        self.alarm = nil
                    }
                }) {
                    Text("Cancel Alarm")
                }
            }
        }
        .padding()
    }
}

struct TestView_Previews: PreviewProvider {
    static var previews: some View {
        TestView()
    }
}

