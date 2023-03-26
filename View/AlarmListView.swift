//
//  AlarmListView.swift
//  Alarmer Test
//
//  Created by user234729 on 3/26/23.
//

import SwiftUI

struct Alarm: Identifiable {
    var id = UUID()
    var time: Date
    var message: String
    var phoneNumber: String
    var isEnabled: Bool
    var isRecurring: Bool}

struct AlarmListView: View {
    @State private var alarms: [Alarm] = [
        // Example alarms
        Alarm(time: Date(), message: "Wake up!", phoneNumber: "+1234567890", isEnabled: true, isRecurring: true),
        Alarm(time: Date().addingTimeInterval(3600), message: "Get ready for work", phoneNumber: "+0987654321", isEnabled: false, isRecurring: false)    ]
    
    @State private var isPresentingAlarmDetailView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                           VStack(spacing: 40) { // Adjust spacing as needed
                               ForEach($alarms) { alarm in
                                   AlarmRow(alarm: alarm)
                               }
                           }
                           .padding(.vertical, 60) // Add this line for top and bottom padding
                       }.navigationTitle("Alarmers")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        isPresentingAlarmDetailView.toggle()
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $isPresentingAlarmDetailView) {
                AlarmDetailView { alarm in
                    addAlarm(alarm)
                    isPresentingAlarmDetailView.toggle()
                }
            }
        }
    }
    
    func addAlarm(_ alarm: Alarm) {
        alarms.append(alarm)
    }
    
    func deleteAlarm(at offsets: IndexSet) {
        alarms.remove(atOffsets: offsets)
    }
}

struct AlarmRow: View {
    @Binding var alarm: Alarm
    
    var body: some View {
        RoundedRectangle(cornerRadius: 20)
            .fill(alarm.isEnabled
                ? Color(red: 1, green: 0.82, blue: 0.34)
                : Color(red: 0.89, green: 0.87, blue: 0.84)).frame(width: 326, height: 114).shadow(radius: 4, y: 4)
            .overlay(
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(alarm.isRecurring ? "Recurring" : "Not Recurring")
                            .font(.subheadline)
                            .foregroundColor(alarm.isEnabled ? Color.black : Color(red: 0.44, green: 0.43, blue: 0.43))
                                             
                        Text(alarm.time, style: .time)
                            .font(.system(size: 34)) // Adjust font size as needed
                            .fontWeight(.bold)
                            .foregroundColor(alarm.isEnabled ? Color.black : Color(red: 0.44, green: 0.43, blue: 0.43))
                    }
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            alarm.isEnabled.toggle()
                        }
                    }){
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
    }
}
