//
//  TorchState.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import Foundation
import SwiftUI
import AVFoundation

class TorchState: ObservableObject {
    
    @Published var isOn: Bool = false {
        didSet {
            toggleTorch(isOn)
        }
    }
    
    private func toggleTorch(_ isOn: Bool) {
        guard let device = AVCaptureDevice.default(for: .video), device.hasTorch else { return }
        
        do {
            try device.lockForConfiguration()
            
            device.torchMode = isOn ? .on : .off
            
            if isOn {
                try device.setTorchModeOn(level: AVCaptureDevice.maxAvailableTorchLevel)
            }
            
            device.unlockForConfiguration()
        } catch {
            print("Error: \(error)")
        }
    }
}
