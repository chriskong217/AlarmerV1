//This is the current AlarmListView
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
        
    ]
    
    @State private var isPresentingAlarmDetailView = false
    @State private var selectedAlarm: Alarm?
    @State private var showDeleteButton: Bool = false
    
    var body: some View {
            NavigationView {
                ZStack {
                    ScrollView {
                        VStack(spacing: 0) { // Adjust spacing as needed
                            ForEach(alarms.indices, id: \.self) { index in
                                Button(action: {
                                    selectedAlarm = alarms[index]
                                    isPresentingAlarmDetailView.toggle()
                                }) {
                                    AlarmRow(alarm: $alarms[index], onToggle: {
                                        toggleAlarmEnabled(index)
                                    })
                                }
                            }
                            .padding(.vertical, 15) // Add this line for top and bottom padding
                        }
                        .padding(.bottom, 120)
                        .navigationTitle("Alarmers")
                    }

                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {
                                selectedAlarm = nil
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
                            .padding(.bottom, 20)
                            .padding(.trailing, 25)
                        }
                    }
                }
                .sheet(isPresented: $isPresentingAlarmDetailView) {
                    if let selectedAlarm = selectedAlarm,
                       let index = alarms.firstIndex(where: { $0.id == selectedAlarm.id }) {
                        AlarmDetailView(alarm: .constant(alarms[index]), showDeleteButton: .constant(true), onSave: { updatedAlarm in
                            updateAlarm(updatedAlarm)
                            isPresentingAlarmDetailView.toggle()
                        }, onDelete: {
                            alarms.remove(at: index)
                            isPresentingAlarmDetailView.toggle()
                        })
                    } else {
                        AlarmDetailView(alarm: .constant(Alarm(time: Date(), message: "", phoneNumber: "", isEnabled: false, isRecurring: false)),showDeleteButton: .constant(false), onSave: { newAlarm in
                            alarms.append(newAlarm)
                            isPresentingAlarmDetailView.toggle()
                        })
                    }
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
                        VStack(alignment: .leading, spacing: 6) {
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
    
    func updateAlarm(_ updatedAlarm: Alarm) {
        if let index = alarms.firstIndex(where: { $0.id == updatedAlarm.id }) {
            alarms[index] = updatedAlarm
        }
    }
    
    struct AlarmListView_Previews: PreviewProvider {
        static var previews: some View {
            AlarmListView()
        }
    }}
