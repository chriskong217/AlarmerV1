import SwiftUI
import Foundation
struct HiddenModifier: ViewModifier {
    var isHidden: Bool
    @ViewBuilder
    func body(content: Content) -> some View {
        if !isHidden {
            content
        } else {
            content.hidden()
        }
    }
}
extension View {
    func conditionallyHidden(_ isHidden: Bool) -> some View {
        self.modifier(HiddenModifier(isHidden: isHidden))
    }
}
struct Alarm: Identifiable, Codable {
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
        formatter.dateFormat = "h:mm a"
        return formatter
    }()
}
