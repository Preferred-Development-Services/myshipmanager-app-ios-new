//
//  CameraView.swift
//  BarcodeScanner
//
//  Created by Tobias Wissmüller on 26.05.21.
//

import AVFoundation
import Foundation
import UIKit

class CameraView: UIView {
    
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        if let previewLayer = self.previewLayer  {
            previewLayer.frame = self.bounds
        }
    }
}
