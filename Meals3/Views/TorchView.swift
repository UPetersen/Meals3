//
//  TorchView.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct TorchView: View {
    @StateObject var torchState = TorchState()
    
    var body: some View {
        if torchState.isOn {
            Button(action: { torchState.isOn.toggle() }) {
                Image(systemName: "flashlight.on.fill").padding()
            }
        } else {
            Button(action: { torchState.isOn.toggle() }) {
                Image(systemName: "flashlight.off.fill").padding()
            }
        }
    }}

struct TorchView_Previews: PreviewProvider {
    static var previews: some View {
        TorchView()
    }
}
