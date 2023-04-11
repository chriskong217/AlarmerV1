

//  AlarmListView.swift
//  Alarmer Test
//
//  Created by user234729 on 3/26/23.
//

=======

import SwiftUI

struct Alarm: Identifiable {
    var id = UUID()
    var time: Date
    var message: String
    var phoneNumber: String
    var isEnabled: Bool
    var isRecurring: Bool
}

struct Formatters {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "h:mm a" // Set the format explicitly
        return formatter
    }()
}


struct AlarmListView: View {
    @State private var alarms: [Alarm] = [
        // Example alarms
        Alarm(time: Date(), message: "Wake up!", phoneNumber: "+1234567890", isEnabled: true, isRecurring: true),
        Alarm(time: Date().addingTimeInterval(3600), message: "Get ready for work", phoneNumber: "+0987654321", isEnabled: false, isRecurring: false)
    ]
    
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
                .toolbar {
                    ToolbarItem(placement: .bottomBar) {
                        NavigationLink(destination: CodeScannerView(codeTypes: [.qr]) { result in
                        }) {
                            Image("CameraIcon")
                                .renderingMode(.original)
                                .resizable()
                                .frame(width: 60, height: 60)
                        }
                    }
                    
                    }.sheet(isPresented: $isPresentingAlarmDetailView) {
                            AlarmDetailView { alarm in
                                addAlarm(alarm)
                                isPresentingAlarmDetailView.toggle()
                            }
                        }
                        
                    }
                }
        
=======
            ZStack {
                ScrollView {
                    VStack(spacing: 0) { // Adjust spacing as needed
                        ForEach(alarms.indices, id: \.self) { index in
                            NavigationLink(destination: AlarmDetailView(alarm: $alarms[index], onSave: { updatedAlarm in
                                updateAlarm(updatedAlarm)
                            })) {
                                AlarmRow(alarm: $alarms[index], onToggle: {
                                    toggleAlarmEnabled(index)
                                })
                            }
                        }
                        .padding(.vertical, 20) // Add this line for top and bottom padding
                    }.padding(.bottom, 120)
                    .navigationTitle("Alarmers")
                }
                
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            isPresentingAlarmDetailView.toggle()
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
                        .padding(.bottom, 15)
                        .padding(.trailing, 155)
                    }
                }
            }
            .sheet(isPresented: $isPresentingAlarmDetailView) {
                AlarmDetailView(alarm: .constant(Alarm(time: Date(), message: "", phoneNumber: "", isEnabled: false, isRecurring: false)), onSave: { newAlarm in
                    alarms.append(newAlarm)
                    isPresentingAlarmDetailView.toggle()
                })
            }
        }.accentColor(Color(red: 1, green: 0.72, blue: 0))
        
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
                        VStack(alignment: .leading, spacing: 8) {
                            Text(alarm.isRecurring ? "Recurring" : "Not Recurring")
                                .font(.subheadline)
                                .foregroundColor(alarm.isEnabled ? Color.black : Color(red: 0.44, green: 0.43, blue: 0.43))
                            
                            Text(Formatters.timeFormatter.string(from:alarm.time)).font(.system(size: 34))
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
    
    func toggleAlarmEnabled(_ index: Int) {
        alarms[index].isEnabled.toggle()
    }
    

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
=======
    func updateAlarm(_ updatedAlarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == updatedAlarm.id }) {
            alarms[index] = updatedAlarm
        }
    }
    
    struct AlarmListView_Previews: PreviewProvider {
        static var previews: some View {
            AlarmListView()
        }

    }
}
