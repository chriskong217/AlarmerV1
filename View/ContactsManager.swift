//
//  ContactsManager.swift
//  Alarmer Test
//
//  Created by user234695 on 4/26/23.
//
//requests access to user contacts then fetches said contacts
import Contacts
import ContactsUI

func requestContactsAccess(completion: @escaping (Bool) -> Void) {
    let contactStore = CNContactStore()
    contactStore.requestAccess(for: .contacts) { granted, error in
        if let error = error {
            print("Error requesting contacts access: \(error.localizedDescription)")
        }
        completion(granted)
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
