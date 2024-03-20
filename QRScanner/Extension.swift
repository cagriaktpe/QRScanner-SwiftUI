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
        // event the time is not important, so we can ignore it
        dateFormatter.dateFormat = "yyyyMMdd"
        if let date = dateFormatter.date(from: self) {
            return date
        } else {
            dateFormatter.dateFormat = "yyyyMMdd'T'HHmmss"
            let date = dateFormatter.date(from: self)
            print(date)
            return dateFormatter.date(from: self)
        }
        
    }
}
