//
//  Extension.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 20.03.2024.
//

import Foundation

extension String {
    // convert "20240315" to a Date
    func toDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        return dateFormatter.date(from: self)
    }
}
