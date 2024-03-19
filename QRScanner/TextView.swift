//
//  TextView.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 19.03.2024.
//

import SwiftUI
import SwiftUIContacts
import Contacts

struct TextView: View {
    
    @State var showSheet = false
    @State var selectedProperty: CNContact?
    
    var body: some View {
        VStack {
            Button("Click me") {
                showSheet.toggle()
            }
        }
        .sheet(isPresented: $showSheet, onDismiss: printDetails) {
            ContactPicker(selection: $selectedProperty)
        }
    }
    
    func printDetails() {
        print(selectedProperty?.givenName as Any)
    }
}

#Preview {
    TextView()
}
