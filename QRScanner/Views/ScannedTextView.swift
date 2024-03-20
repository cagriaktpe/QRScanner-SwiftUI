//
//  ScannedTextView.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 20.03.2024.
//

import SwiftUI

struct ScannedTextView: View {
    let text: String

    var body: some View {
        ScrollView {
            Text(text)
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .frame(maxHeight: .infinity, alignment: .top)
                .textSelection(.enabled)
        }
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Copy") {
                    UIPasteboard.general.string = text
                }
            }
        }
    }
}

#Preview {
    let text = "Lorem Ipsum Dolor Sit Amet, Lorem Ipsum Dolor Sit Amet, Lorem Ipsum Dolor Sit Amet"
    return (
        NavigationStack {
            ScannedTextView(text: text)
        }
    )
}
