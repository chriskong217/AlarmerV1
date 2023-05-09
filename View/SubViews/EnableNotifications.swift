import SwiftUI
struct EnableNotifications: View {
    @EnvironmentObject var lnManager: LocalNotificationManager
    @Binding var showEnableNotifications: Bool // Add this property
    var onProceedAnyway: () -> Void
    
    var body: some View {
        VStack {
            Image(notificationperson)
                .resizable()
                .scaledToFit()
                .padding(.horizontal)
                .opacity(0.9)
            Spacer()
            Text("Alarmer does not work without notifications on. Please enable notifications.")
                .font(.system(size: 38))
                .multilineTextAlignment(.center)
                .padding()
            Spacer()
            Button(action: {
                lnManager.openSettings()
            }, label: {
                Text("Go to settings")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 100)
                    .background(Color.yellow)
                    .cornerRadius(15)
            })
            Spacer()
            Button(action: {
                onProceedAnyway()
                showEnableNotifications = false // Add this line
            }, label: {
                Text("Proceed Anyway")
                    .foregroundColor(.white)
                    .font(.system(size: 20, weight: .bold))
                    .padding(.vertical, 10)
                    .padding(.horizontal, 85)
                    .background(Color.gray)
                    .cornerRadius(15)
            })
        }
    }
}
struct EnableNotifications_Previews: PreviewProvider {
    @State static private var showEnableNotifications = true
    
    static var previews: some View {
        EnableNotifications(showEnableNotifications: $showEnableNotifications, onProceedAnyway: {})
            .environmentObject(LocalNotificationManager())
    }
}
