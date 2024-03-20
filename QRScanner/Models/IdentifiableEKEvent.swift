//
//  IdentifiableEKEvent.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 20.03.2024.
//

import Foundation
import EventKit

struct IdentifiableEKEvent: Identifiable, Hashable {
    var id: String = UUID().uuidString
    let event: EKEvent
}

