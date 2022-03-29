//
//  ScannerView.swift
//  BarcodeScanner
//
//  Created by Tobias Wissmüller on 26.05.21.
//

import AVFoundation
import Foundation 
import SwiftUI
import Vision

struct ScannerView: UIViewRepresentable {
    typealias UIViewType = CameraView
    
    @Binding var result: String
    
    func makeUIView(context: Context) -> UIViewType {
        return UIViewType()
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        context.coordinator.setupDetection(uiView)
    }
    
    func makeCoordinator() -> ScannerView.Coordinator {
        return Coordinator(self)
    }
}

