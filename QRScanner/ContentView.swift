//
//  ContentView.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 18.03.2024.
//

import SwiftUI

struct ContentView: View {
    @State var scanResult = "No QR code detected"
    @State var scannedCodes = [String]()
 
    var body: some View {
        ZStack(alignment: .bottom) {
            
            QRScanner(result: $scanResult, scannedCodes: $scannedCodes)
 
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
