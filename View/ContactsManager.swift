//
//  ContactsManager.swift
//  Alarmer Test
//
//  Created by user234695 on 4/26/23.
//

import Contacts

func requestContactsAccess(completion: @escaping (Bool) -> Void) {
    CNContactStore().requestAccess(for: .contacts) { granted, error in
        DispatchQueue.main.async {
            completion(granted)
        }
    }
}

func fetchContacts() -> [CNContact] {
    let store = CNContactStore()
    let keysToFetch: [CNKeyDescriptor] = [CNContactGivenNameKey as CNKeyDescriptor, CNContactFamilyNameKey as CNKeyDescriptor, CNContactPhoneNumbersKey as CNKeyDescriptor]
    let fetchRequest = CNContactFetchRequest(keysToFetch: keysToFetch)
    
    var contacts: [CNContact] = []
    do {
        try store.enumerateContacts(with: fetchRequest) { contact, _ in
            contacts.append(contact)
        }
    } catch {
        print("Error fetching contacts: \(error)")
    }
    
    return contacts
}
