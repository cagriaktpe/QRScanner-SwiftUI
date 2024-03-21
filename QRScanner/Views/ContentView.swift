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
    @State var scannedCodes: [String] = []
    
    @State var image: Data?
    @State var selectedPhoto: PhotosPickerItem?
    @State var qrCodeHandler: QRCodeHandler?

    // for navigations
    @State var scannedEvent: IdentifiableEKEvent?
    @State var scannedContact: CNContact?
    @State var scannedText: String?

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack(alignment: .bottom) {
                    QRScanner(result: $scanResult, scannedCodes: $scannedCodes, scannedContact: $scannedContact, scannedEvent: $scannedEvent, scannedText: $scannedText)

                    buttonsLayer

                }
                .navigationDestination(item: $scannedText) { text in
                    ScannedTextView(text: text)
                }
                .navigationDestination(item: $scannedContact) { _ in
                    ContactDetailView(scannedContact: $scannedContact)
                }
                .navigationDestination(item: $scannedEvent) { _ in
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
                .ignoresSafeArea()
            }
        }
    }
    
    var buttonsLayer: some View {
        VStack(spacing: 20) {
            scannedQRLayer
            photoPickerLayer
        }
        .frame(maxWidth: .infinity, alignment: .trailing)
        .frame(maxHeight: .infinity, alignment: .bottom)
        .padding()
    }

    var photoPickerLayer: some View {
        PhotosPicker(selection: $selectedPhoto,
                     matching: .images,
                     photoLibrary: .shared()) {
            Image(systemName: "photo.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding()
                
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(30)
        .shadow(radius: 10)
    }
    
    var scannedQRLayer: some View {
        Button {
            if let code = scannedCodes.last {
                qrCodeHandler?.handleQRCode(code)
            }
        } label: {
            Image(systemName: "qrcode")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .padding()
        }
        .background(Color(UIColor.secondarySystemBackground))
        .cornerRadius(30)
        .shadow(radius: 10)
        .disabled(scannedCodes.isEmpty)
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
            scannedCodes.append(contentsOf: features?.compactMap { ($0 as? CIQRCodeFeature)?.messageString } ?? [])
            return features
        }
        return nil
    }
}

#Preview {
    ContentView()
}
