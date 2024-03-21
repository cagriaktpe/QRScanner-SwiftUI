//
//  QRScanner.swift
//  QRScanner
//
//  Created by Samet Çağrı Aktepe on 18.03.2024.
//

import AVFoundation
import SwiftUI
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
        captureMetadataOutput.metadataObjectTypes = [.qr]

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
    @Binding var scannedCodes: [String]
    @Binding var scannedContact: CNContact?
    @Binding var scannedEvent: IdentifiableEKEvent?
    @Binding var scannedText: String?

    func makeUIViewController(context: Context) -> QRScannerController {
        let controller = QRScannerController()
        controller.delegate = context.coordinator

        return controller
    }

    func updateUIViewController(_ uiViewController: QRScannerController, context: Context) {
    }

    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate {
        @Binding var scanResult: String
        @Binding var scannedCodes: [String]
        @Binding var scannedContact: CNContact?
        @Binding var scannedEvent: IdentifiableEKEvent?
        @Binding var scannedText: String?
        var qrCodeHandler: QRCodeHandler
        

        init(_ scanResult: Binding<String>, scannedCodes: Binding<[String]>, scannedContact: Binding<CNContact?>, scannedEvent: Binding<IdentifiableEKEvent?>, scannedText: Binding<String?>) {
            _scanResult = scanResult
            _scannedCodes = scannedCodes
            _scannedContact = scannedContact
            _scannedEvent = scannedEvent
            _scannedText = scannedText
            qrCodeHandler = QRCodeHandler(scannedContact: scannedContact, scannedEvent: scannedEvent, scannedText: scannedText)
        }

        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if metadataObjects.count == 0 {
                scanResult = "No QR code detected"
                return
            }

            // Get the metadata object.
            let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject

            if metadataObj.type == AVMetadataObject.ObjectType.qr,
               let result = metadataObj.stringValue {
                scanResult = result
                
                if scannedCodes.contains(scanResult) {
                    return
                }
                
                scannedCodes.append(result)
                qrCodeHandler.handleQRCode(result)
            }
        }

        
    }

    func makeCoordinator() -> Coordinator {
        Coordinator($result, scannedCodes: $scannedCodes, scannedContact: $scannedContact, scannedEvent: $scannedEvent, scannedText: $scannedText)
    }
}
