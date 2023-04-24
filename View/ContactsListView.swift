//
//  ContactsListView.swift
//  Alarmer Test
//
//  Created by user234695 on 4/26/23.
//

import SwiftUI
import Contacts

struct ContactsListView: View {
    let contacts: [CNContact]
    let onSelect: (CNContact) -> Void
    
    init(contacts: [CNContact], onSelect: @escaping (CNContact) -> Void) {
        self.contacts = contacts
        self.onSelect = onSelect
    }

    var body: some View {
        NavigationView {
            List(contacts, id: \.identifier) { contact in
                HStack {
                    Text(contact.givenName)
                    Text(contact.familyName)
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    onSelect(contact)
                }
            }
            .navigationTitle("Contacts")
        }
    }
}
