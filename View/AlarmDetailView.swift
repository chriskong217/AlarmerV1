//This is the current AlarmDetailView
import SwiftUI
import UIKit
extension Date {
    var hour12: Bool {
        let hour = Calendar.current.component(.hour, from: self)
        return hour >= 12
    }
}
struct AlarmDetailView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var alarm: Alarm
    @Binding var showDeleteButton: Bool
    var onSave: ((Alarm) -> Void)?
    var onDelete: (() -> Void)?
    
    @State private var selectedTime: Date
    @State private var message: String
    @State private var phoneNumber: String
    @State private var isEnabled: Bool
    @State private var isRecurring: Bool
    @State private var isLocationBased: Bool
    
    
    init(alarm: Binding<Alarm>, showDeleteButton: Binding<Bool>, onSave: ((Alarm) -> Void)? = nil, onDelete: (() -> Void)? = nil) {
        _alarm = alarm
        _selectedTime = State(initialValue: alarm.wrappedValue.time)
        _message = State(initialValue: alarm.wrappedValue.message)
        _phoneNumber = State(initialValue: alarm.wrappedValue.phoneNumber)
        _isEnabled = State(initialValue: alarm.wrappedValue.isEnabled)
        _isRecurring = State(initialValue: alarm.wrappedValue.isRecurring)
        _isLocationBased = State(initialValue: false)
        _showDeleteButton = showDeleteButton
        self.onSave = onSave
        self.onDelete = onDelete
    }
    
    var body: some View {
            ZStack {
                NavigationView {
                    VStack {
                        DatePicker("", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                            .datePickerStyle(WheelDatePickerStyle())
                            .labelsHidden()
                            .padding()
                        Form {
                            TextField("Message", text: $message)
                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                            Toggle("Enabled", isOn: $isEnabled)
                            Toggle("Recurring", isOn: $isRecurring)
                            Toggle("Location Based", isOn: $isLocationBased)
                        }
                    }
                    .padding(.bottom, onDelete != nil ? 60 : 0)
                    .navigationTitle("Alarm Details")
                    // Hide the navigation bar
                    .navigationBarBackButtonHidden(true)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button("Cancel") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .foregroundColor(Color(red: 1, green: 0.72, blue: 0))
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Save") {
                                let updatedAlarm = Alarm(id: alarm.id, time: selectedTime, message: message, phoneNumber: phoneNumber, isEnabled: isEnabled, isRecurring: isRecurring)
                                if let onSave = onSave {
                                    onSave(updatedAlarm)
                                }
                                presentationMode.wrappedValue.dismiss()
                            }.foregroundColor(Color(red: 1, green: 0.72, blue: 0))
                        }
                    }
                }
                if showDeleteButton {
                    VStack {
                            Spacer()
                            Button(action: {
                                onDelete?()
                                presentationMode.wrappedValue.dismiss()
                            }) {
                                Text("Delete")
                                    .foregroundColor(.white)
                                    .font(.system(size: 20, weight: .bold))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 130)
                                    .background(Color.red)
                                    .cornerRadius(25)
                            }
                            .padding(.bottom, 20)
                    }
                }
            }
        }
    }
struct AlarmDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailView(alarm: .constant(Alarm(time: Date(), message: "Wake up!", phoneNumber: "+1234567890", isEnabled: true, isRecurring: true)), showDeleteButton: .constant(true), onSave: { _ in })
    }
}
