//
//  ContentView.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 18.03.2024.
//

import Contacts
import EventKit
import PhotosUI
import SwiftUI

struct ContentView: View {
    @Environment(\.dismiss) var dismiss
    @State var scanResult = "No QR code detected"
    @State var image: Data?
    @State var selectedPhoto: PhotosPickerItem?
    @State var qrCodeHandler: QRCodeHandler?

    // for navigations
    @State var scannedEvent: IdentifiableEKEvent?
    @State var scannedContact: CNContact?
    @State var scannedText: String?

    var body: some View {
        NavigationStack {
            ZStack(alignment: .bottom) {
                QRScanner(result: $scanResult, scannedContact: $scannedContact, scannedEvent: $scannedEvent, scannedText: $scannedText)

                Rectangle()
                    .ignoresSafeArea()
                    .foregroundStyle(.ultraThinMaterial)
                    .frame(height: 100)
                    .overlay {
                        // put the overLay right corner
                        VStack {
                            overlayLayer
                                .overlay {
                                    Rectangle()
                                        .fill(.thinMaterial)
                                        .mask(overlayLayer)
                                        .allowsHitTesting(false)
                                }
                        }
                        .frame(maxWidth: .infinity, alignment: .trailing)
                        .padding(.trailing)
                        .padding(.top)
                    }
            }
            .navigationDestination(item: $scannedText) { text in
                ScannedTextView(text: text)
            }
            .navigationDestination(item: $scannedContact) { _ in
                ContactDetailView(scannedContact: $scannedContact)
            }
            .navigationDestination(item: $scannedEvent) { event in
                AddEvent(scannedEvent: $scannedEvent)
            }
            .task(id: selectedPhoto) {
                if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                    image = data
                    detectQRCode(UIImage(data: data))?.forEach { feature in
                        if let qrFeature = feature as? CIQRCodeFeature {
                            if let scanResult = qrFeature.messageString {
                                qrCodeHandler?.handleQRCode(scanResult)
                            }
                        }
                    }
                }
            }
            .onAppear {
                self.qrCodeHandler = QRCodeHandler(scannedContact: $scannedContact, scannedEvent: $scannedEvent, scannedText: $scannedText)
            }
        }
    }

    var overlayLayer: some View {
        PhotosPicker(selection: $selectedPhoto,
                     matching: .images,
                     photoLibrary: .shared()) {
            Image(systemName: "photo.circle.fill")
                .resizable()
                .frame(width: 50, height: 50)
        }
    }
}

extension ContentView {
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        if let image = image, let ciImage = CIImage(image: image) {
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains(kCGImagePropertyOrientation as String) {
                options = [CIDetectorImageOrientation: ciImage.properties[kCGImagePropertyOrientation as String] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
        }
        return nil
    }
}

#Preview {
    ContentView()
}
