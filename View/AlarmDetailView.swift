//This is the current AlarmDetailView
import SwiftUI
import UIKit
import Contacts

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
    @State private var showingContactListView = false
    @State private var contacts: [CNContact] = []
    
    let smsManager = SMSManager()
    
    
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
    
    // Format phone number to E.164 format
    func formatPhoneNumber(_ phoneNumber: String) -> String {
        let formattedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
        return "+\(formattedNumber)"
    }
    
    func sendSMSTapped() {
        let accountSid = "ACcfae9a643457577632b828e0c493ac75"
        let authToken = "37720610f8cf2f3059110f33d43c18cb"
        let fromPhoneNumber = "+18447397884"
        let toPhoneNumber = phoneNumber
        let message = message
        
        smsManager.sendSMS(accountSid: accountSid, authToken: authToken, fromPhoneNumber: fromPhoneNumber, toPhoneNumber: toPhoneNumber, message: message) { result in
            switch result {
            case .success(let sent):
                if sent {
                    print("SMS sent successfully")
                }
            case .failure(let error):
                print("Error sending SMS: \(error)")
            }
        }
    }
    
    
    func testVerificationTapped() {
        let toPhoneNumber = formatPhoneNumber(phoneNumber)
        sendVerificationToken(toPhoneNumber: toPhoneNumber) { success in
            if success {
                print("Verification message sent successfully")
            } else {
                print("Error sending verification message")
            }
        }
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

                            TextField("Label", text: $message)

                            TextField("Phone Number", text: $phoneNumber)
                                .keyboardType(.phonePad)
                            Toggle("Enabled", isOn: $isEnabled)
                            Toggle("Recurring", isOn: $isRecurring)
                            Toggle("Location Based", isOn: $isLocationBased)
                        }
                        // New section for the Send Test SMS button
                                            Section {
                                                Button(action: testVerificationTapped) {
                                                                            Text("Test Verification")
                                                                                .foregroundColor(.blue)
                                                };                Button(action: sendSMSTapped) {
                                                    Text("Send Test SMS")
                                                        .foregroundColor(.blue)
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
                    // Function to send an SMS when the button is tapped
                       func sendSMSTapped() {
                           let accountSid = "ACcfae9a643457577632b828e0c493ac75"
                           let authToken = "79f444133772a97856863b1385d0a13b"
                           let fromPhoneNumber = "+18447397884"
                           let toPhoneNumber = phoneNumber
                           let message = message
                           
                           smsManager.sendSMS(accountSid: accountSid, authToken: authToken, fromPhoneNumber: fromPhoneNumber, toPhoneNumber: toPhoneNumber, message: message) { result in
                               switch result {
                               case .success(let sent):
                                   if sent {
                                       print("SMS sent successfully")
                                   }
                               case .failure(let error):
                                   print("Error sending SMS: \(error)")
                               }
                           }
                       }
                       
                       // Format phone number to E.164 format
                       func formatPhoneNumber(_ phoneNumber: String) -> String {
                           let formattedNumber = phoneNumber.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                           return "+\(formattedNumber)"
                       }
                       
                       func testVerificationTapped() {
                           let toPhoneNumber = formatPhoneNumber(phoneNumber)
                           sendVerificationToken(toPhoneNumber: toPhoneNumber) { success in
                               if success {
                                   print("Verification message sent successfully")
                               } else {
                                   print("Error sending verification message")
                               }
                           }
                       }
                   }

                        presentationMode.wrappedValue.dismiss()
                    }.foregroundColor(Color(red: 1, green: 0.72, blue: 0))
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
