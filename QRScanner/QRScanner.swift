//
//  QRScanner.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 18.03.2024.
//

import SwiftUI
import AVFoundation
import MapKit
import Contacts

class QRScannerController: UIViewController {
    var captureSession = AVCaptureSession()
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
 
    var delegate: AVCaptureMetadataOutputObjectsDelegate?
 
    override func viewDidLoad() {
        super.viewDidLoad()
 
        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("Failed to get the camera device")
            return
        }
 
        let videoInput: AVCaptureDeviceInput
 
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            videoInput = try AVCaptureDeviceInput(device: captureDevice)
 
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
 
        // Set the input device on the capture session.
        captureSession.addInput(videoInput)
 
        // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
        let captureMetadataOutput = AVCaptureMetadataOutput()
        captureSession.addOutput(captureMetadataOutput)
 
        // Set delegate and use the default dispatch queue to execute the call back
        captureMetadataOutput.setMetadataObjectsDelegate(delegate, queue: DispatchQueue.main)
        captureMetadataOutput.metadataObjectTypes = [ .qr ]
 
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
 
        // Start video capture.
        DispatchQueue.global(qos: .background).async {
            self.captureSession.startRunning()
        }
 
    }
 
}

struct QRScanner: UIViewControllerRepresentable {
    
    @Binding var result: String
 
    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.delegate = context.coordinator
     
        return controller
    }
 
    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
     
        @Binding var scanResult: String
     
        init(_ scanResult: Binding<String>) {
            self._scanResult = scanResult
        }
     
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
     
            // Check if the metadataObjects array is not nil and it contains at least one object.
            if metadataObjects.count == 0 {
                scanResult = "No QR code detected"
                return
            }
     
            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
     
            if metadataObj.type == AVMetadataObject.ObjectType.qr,
               let result = metadataObj.stringValue {
     
                scanResult = result
                
                // handle QR Code
                handleQRCode(result)
            }
        }
        
        /*
         text
         URL ✅
         Contact ✅
         location ✅
         wifi ✅
         sms ✅
         email ✅
         call ✅
         event ✅
         */
        
        func handleQRCode(_ code: String) {
            let scannedCode = code.lowercased()
            // TODO: IMPLEMENT
            if scannedCode.hasPrefix("http") || scannedCode.hasPrefix("www") || scannedCode.hasSuffix(".com") {
                handleURL(code)
            } else if scannedCode.hasPrefix("geo") {
                handleLocation(code)
            } else if scannedCode.hasPrefix("begin:vcard") {
                handleContact(code)
            } else if scannedCode.hasPrefix("wifi") {
                print("THIS IS A WIFI")
            } else if scannedCode.hasPrefix("smsto") {
                print("THIS IS A SMS")
            } else if scannedCode.hasPrefix("mailto") {
                print("THIS IS AN EMAIL")
            } 
            // if scannedCodes containts only numbers and +
            else if scannedCode.hasPrefix("tel") || (scannedCode.hasPrefix("+") && scannedCode.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil) || scannedCode.rangeOfCharacter(from: CharacterSet.decimalDigits.inverted) == nil   {
                // TODO: FIX
                print("THIS IS A CALL")
            } else if scannedCode.hasPrefix("begin:vevent") {
                print("THIS IS AN EVENT")
            } else {
                print("THIS IS AN TEXT")
            }
        }
        
        func handleURL(_ url: String) {
            // if url has no prefix add http:// give it
            if !url.hasPrefix("http") {
                let formattedURL = "http://\(url)"
                print(formattedURL)
            }
            
            // open it
            if let urlToOpen = URL(string: url) {
                UIApplication.shared.open(urlToOpen)
            }
        }
        
        func handleLocation(_ location: String) {
            print("THIS IS A LOCATION")
        }
        
        func handleContact(_ contact: String) {
            print("THIS IS A CONTACT")
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator($result)
    }
    
    

}
