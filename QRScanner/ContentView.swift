//
//  ContentView.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 18.03.2024.
//

import SwiftUI
import Contacts
import EventKit

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State var scanResult = "No QR code detected"
    @State var scannedCodes = [String]()
    @State var event: IdentifiableEKEvent?
    
    @State var scannedContact: CNContact?
 
    var body: some View {
        ZStack(alignment: .bottom) {
            
            QRScanner(result: $scanResult, scannedCodes: $scannedCodes, scannedContact: $scannedContact, scannedEvent: $event)
                .sheet(item: $scannedContact) { contact in
                    ContactDetailView(scannedContact: $scannedContact)
                }
                .sheet(item: $event) { event in
                    AddEvent(scannedEvent: $event)
                }
 
            Text(scanResult)
                .padding()
                .background(.black)
                .foregroundColor(.white)
                .padding(.bottom)
        }
        
    }
}

#Preview {
    ContentView()
}
