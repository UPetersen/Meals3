//
//  TorchView.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Taken from https://stackoverflow.com/questions/27207278/how-to-turn-flashlight-on-and-off-in-swift#27334447
//  All credits go to https://stackoverflow.com/users/3013992/peter-kreinz
//  Enhanced by putting a circle aroung the icon.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

/// Displays a torch (flashlight) in a semi opaque circle.
struct TorchView: View {
    @StateObject var torchState = TorchState()
    
    var body: some View {
        
        ZStack(alignment: .center) {
            Circle()
                .fill(Color.white)
                .opacity(0.5)
                .frame(width: 70, height: 70)

            Button(action: { torchState.isOn.toggle() }) {
                Image(systemName: torchState.isOn ? "flashlight.on.fill" : "flashlight.off.fill")
            }
            .scaleEffect(2.5)
        }
    }
}

struct TorchView_Previews: PreviewProvider {
    static var previews: some View {
        TorchView()
    }
}
