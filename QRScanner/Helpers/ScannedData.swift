//
//  ScannedData.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 22.03.2024.
//

import Foundation
import Contacts

class ScannedData: ObservableObject {
    @Published var scannedContact: CNContact?
    @Published var scannedEvent: IdentifiableEKEvent?
    @Published var scannedText: String?
    @Published var lastScanned: String?
    @Published var scanResult = "No QR code detected"
}
