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
    
    @State var image: Data?
    @State var selectedPhoto: PhotosPickerItem?
    @State var qrCodeHandler: QRCodeHandler?

    // for navigations
    @StateObject var scannedData = ScannedDataManager()
    @State private var showAlert = false

    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                ZStack(alignment: .bottom) {
                    QRScanner(scannedData: scannedData)

                    buttonsLayer
                    
                    // text layer begins
                    Text($scannedData.scanResult.wrappedValue)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.black.opacity(0.5))
                        .cornerRadius(10)
                        .padding()
                        .frame(width: geo.size.width, height: 50, alignment: .center)
                    // text layer ends

                }
                .navigationDestination(item: $scannedData.scannedText) { text in
                    ScannedTextView(text: text)
                }
                .navigationDestination(item: $scannedData.scannedContact) { _ in
                    ContactDetailView(scannedContact: $scannedData.scannedContact)
                }
                .navigationDestination(item: $scannedData.scannedEvent) { _ in
                    EventEditView(scannedEvent: $scannedData.scannedEvent, showAlert: $showAlert)
                        .toolbar(.hidden)
                }
                .task(id: selectedPhoto) {
                    if let data = try? await selectedPhoto?.loadTransferable(type: Data.self) {
                        image = data
                        qrCodeHandler?.detectQRCode(UIImage(data: data))?.forEach { feature in
                            if let qrFeature = feature as? CIQRCodeFeature {
                                if let scanResult = qrFeature.messageString {
                                    qrCodeHandler?.handleQRCode(scanResult)
                                }
                            }
                        }
                    }
                }
                .onAppear {
                    self.qrCodeHandler = QRCodeHandler(scannedData: scannedData)
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Success"), message: Text("Event has been saved."), dismissButton: .default(Text("OK")))
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
            if let code = scannedData.lastScanned {
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
        .disabled(scannedData.lastScanned == nil)
    }
}

#Preview {
    ContentView()
}
