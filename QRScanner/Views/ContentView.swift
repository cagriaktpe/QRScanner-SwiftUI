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
    @State var scannedText: String?
 
    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                
                QRScanner(result: $scanResult, scannedCodes: $scannedCodes, scannedContact: $scannedContact, scannedEvent: $event, scannedText: $scannedText)
                    
     
                Text(scanResult)
                    .padding()
                    .background(.black)
                    .foregroundColor(.white)
                    .padding(.bottom)
            }
            .navigationDestination(item: $scannedText) { text in
                ScannedTextView(text: text)
            }
            .navigationDestination(item: $scannedContact) { contact in
                ContactDetailView(scannedContact: $scannedContact)
            }
            .navigationDestination(item: $event) { event in
                AddEvent(scannedEvent: $event)
            }
        }
        
        
    }
}

#Preview {
    ContentView()
}
