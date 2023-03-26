import SwiftUI

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
            Form {
                DatePicker("Time", selection: $selectedTime, displayedComponents: .hourAndMinute)
                TextField("Message", text: $message)
                TextField("Phone Number", text: $phoneNumber)
                    .keyboardType(.phonePad)
                Toggle("Enabled", isOn: $isEnabled)
                Toggle("Recurring", isOn: $isRecurring)
                Toggle("Location Based", isOn: $isLocationBased)
            }
            .navigationTitle("Alarm Details")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let updatedAlarm = Alarm(id: alarm.id, time: selectedTime, message: message, phoneNumber: phoneNumber, isEnabled: isEnabled, isRecurring: isRecurring)
                        onSave?(updatedAlarm)
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

struct AlarmDetailView_Previews: PreviewProvider {
    static var previews: some View {
        AlarmDetailView(alarm: .constant(Alarm(time: Date(), message: "Wake up!", phoneNumber: "+1234567890", isEnabled: true, isRecurring: true)), onSave: { _ in })
    }
}
