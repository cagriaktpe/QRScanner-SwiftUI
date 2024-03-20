//
//  ContactDetailView.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 20.03.2024.
//

import SwiftUI
import Contacts

struct ContactDetailView: View {
    
    @Binding var scannedContact: CNContact?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                HStack {
                    Text("Name: ")
                    Spacer()
                    Text(scannedContact?.givenName ?? "")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Surname: ")
                    Spacer()
                    Text(scannedContact?.phoneNumbers.first?.value.stringValue ?? "")
                        .foregroundStyle(.secondary)
                }
                
                HStack {
                    Text("Email: ")
                    Spacer()
                    Text(scannedContact?.emailAddresses.first?.value as String? ?? "")
                        .foregroundStyle(.secondary)
                }
                
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        ContactManager.saveContact(contact: scannedContact!)
                        dismiss()
                    }
                }
            }
        }
        
    }
}

#Preview {
    @State var scannedContact: CNContact?
    return ContactDetailView(scannedContact: $scannedContact)
}
