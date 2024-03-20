//
//  ContactManager.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 20.03.2024.
//

import Foundation
import Contacts

class ContactManager {
    static func saveContact(contact: CNContact) {
        let store = CNContactStore()
        let saveRequest = CNSaveRequest()
        
        if let mutableContact = contact.mutableCopy() as? CNMutableContact {
            saveRequest.add(mutableContact, toContainerWithIdentifier: nil)
        }
        
        do {
            try store.execute(saveRequest)
        } catch {
            print("Error saving contact: \(error)")
        }
    }
}
