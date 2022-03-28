//
//  BarcodeScannerView.swift
//  MyShipManager
//
//  Created by Matt on 3/14/22.
//

import SwiftUI
import UIKit
import AVFoundation


public struct BarcodeScannerView: UIViewControllerRepresentable {
    @Environment(\.presentationMode) private var presentationMode

    public init() {
    }

    public func makeUIViewController(context: Context) -> UIViewController {
        return ScannerVC()
    }

    public func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    public func makeCoordinator() -> Coordinator {
        Coordinator(
            onDismiss: { self.presentationMode.wrappedValue.dismiss() }
        )
    }
    
    final public class ScannerVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
        public override func viewDidLoad() {
            super.viewDidLoad()
            
            view.backgroundColor = .black
            
            // TODO: nil checking and throw checking
            let session = AVCaptureSession()
            let device = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
            let input = try! AVCaptureDeviceInput(device: device!)
            
            if (session.canAddInput(input)) {
                session.addInput(input)
            } else {
                // TODO: make nice UI failure message for these fatalErrors
                fatalError("couldn't add input")
            }
            
            let output = AVCaptureMetadataOutput()
            
            if (session.canAddOutput(output)) {
                session.addOutput(output)
                
                output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                output.metadataObjectTypes = [.ean8, .ean13, .pdf417]
            } else {
                fatalError("couldn't add output")
            }
            
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.frame = view.layer.bounds
            previewLayer.videoGravity = .resizeAspectFill
            view.layer.addSublayer(previewLayer)
            
            session.startRunning()
        }
        
        public func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            print(output)
            // TODO: once Xcode update downloads, go through and test on real device with real barcodes
        }
    }

    final public class Coordinator: NSObject, UINavigationControllerDelegate {
        private let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }
    }
}
