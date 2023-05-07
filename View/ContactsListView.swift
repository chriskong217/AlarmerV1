//
//  ContactsListView.swift
//  Alarmer Test
//
//  Created by user234695 on 4/26/23.
//

import SwiftUI
import Contacts

extension CNContact: Identifiable {
    public var id: String {
        return self.identifier
    }
}

struct ContactsListView: View {
    var contacts: [CNContact]
    var onSelect: (CNContact) -> Void
    
    var body: some View {
        List(contacts) { contact in
            Button(action: {
                onSelect(contact)
            }) {
                VStack(alignment: .leading) {
                    Text("\(contact.givenName) \(contact.familyName)")
                    if let number = contact.phoneNumbers.first?.value.stringValue {
                        Text(number)
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
   
}

