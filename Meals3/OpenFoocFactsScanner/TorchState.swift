//
//  TorchState.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Taken from https://stackoverflow.com/questions/27207278/how-to-turn-flashlight-on-and-off-in-swift#27334447
//  All credits go to https://stackoverflow.com/users/3013992/peter-kreinz
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
