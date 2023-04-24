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
    var onSave: ((Alarm) -> Void)?
    
    @State private var selectedTime: Date
    @State private var message: String
    @State private var phoneNumber: String
    @State private var isEnabled: Bool
    @State private var isRecurring: Bool
    @State private var isLocationBased: Bool
    @State private var userInputMessage: String = "" // New state property for user input message
    @State private var showingContactListView = false
    @State private var contacts: [CNContact] = []
    
    // Create an instance of SMSManager
    let smsManager = SMSManager()
    
    init(alarm: Binding<Alarm>, onSave: ((Alarm) -> Void)? = nil) {
        _alarm = alarm
        _selectedTime = State(initialValue: alarm.wrappedValue.time)
        _message = State(initialValue: alarm.wrappedValue.message)
        _phoneNumber = State(initialValue: alarm.wrappedValue.phoneNumber)
        _isEnabled = State(initialValue: alarm.wrappedValue.isEnabled)
        _isRecurring = State(initialValue: alarm.wrappedValue.isRecurring)
        _isLocationBased = State(initialValue: false)
        self.onSave = onSave
    }
    
    var body: some View {
        NavigationView {
            VStack {
                DatePicker("", selection: $selectedTime, displayedComponents: [.hourAndMinute])
                    .datePickerStyle(WheelDatePickerStyle())
                    .labelsHidden()
                    .padding()

                List {
                    Section {
                                       TextField("Message", text: $message)
                                       TextField("Phone Number", text: $phoneNumber)
                                           .keyboardType(.phonePad)
                                       
                                       Button(action: {
                                           requestContactsAccess { granted in
                                               if granted {
                                                   contacts = fetchContacts()
                                                   showingContactListView.toggle()
                                               }
                                           }
                                       }) {
                                           Text("Access Contacts")
                                       }
                                       .sheet(isPresented: $showingContactListView) {
                                           ContactsListView(contacts: contacts, onSelect: { selectedContact in
                                               phoneNumber = selectedContact.phoneNumbers.first?.value.stringValue ?? ""
                                               showingContactListView.toggle()
                                           })
                                       }
                                   }
                    Toggle("Enabled", isOn: $isEnabled)
                    Toggle("Recurring", isOn: $isRecurring)
                    Toggle("Location Based", isOn: $isLocationBased)

                    // New section for the Send Test SMS button
                    Section {
                        TextField("Input SMS Text", text: $userInputMessage)
                            .autocapitalization(.sentences)
                        Button(action: sendSMSTapped) {
                            Text("Send Test SMS")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Alarm Details")
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
                        onSave?(updatedAlarm)
                        presentationMode.wrappedValue.dismiss()
                    }.foregroundColor(Color(red: 1, green: 0.72, blue: 0))
                }
            }
        }
    }

    // Function to send an SMS when the button is tapped
    func sendSMSTapped() {
        let accountSid = "ACcfae9a643457577632b828e0c493ac75"
        let authToken = "dea24be94ea23cc19faaad863698e53f"
        let fromPhoneNumber = "+18447397884"
        let toPhoneNumber = "+14694016448"
        let message = userInputMessage
        
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
}

struct AlarmDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailView(alarm: .constant(Alarm(time: Date(), message: "Wake up!", phoneNumber: "+1234567890", isEnabled: true, isRecurring: true)), onSave: { _ in })
    }
}


