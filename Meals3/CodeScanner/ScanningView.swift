//
//  ScanningView.swift
//  Meals3
//
//  Created by Uwe Petersen on 04.08.21.
//  Copyright © 2021 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct ScanningView: View {
    @EnvironmentObject var offManager: OffManager
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>

    @State private var isPresentingFouncdABarcodeAlert: Bool = false

    
    var body: some View {
        
        NavigationView {
            
            VStack {
                if offManager.offManagerState == .isScanning {
                    CodeScannerView(
                        codeTypes: [.ean13, .ean8],
                        completion: { result in
                            if case let .success(code) = result {
                                self.offManager.scannedBarcode = code
                                self.offManager.offManagerState = .scanningCompleted
                                self.offManager.fetch()
//                                self.isPresentingFouncdABarcodeAlert = true
                                print("scanner found code \(code)")
                            } else {
                                self.offManager.scannedBarcode = nil
                                self.offManager.offManagerState = .idle
                                print("scanner did not find any code")
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
                if offManager.offManagerState == .isFetching {
                    Spacer()
                    Text("Fetching food data for EAN \(offManager.scannedBarcode ?? "kein Barcod gefunden").").padding()
                    ProgressView()
                    Spacer()
                }
                if offManager.offManagerState == .fetchingCompleted, let product = offManager.product  {
                    Spacer()
                    Text(product.description).padding()
                    Spacer()
                }

                
                Text("Status: \(self.offManager.offManagerState.rawValue)")
                    .padding()
                    
            }
            .onDisappear(perform: {
                print("Scanning view onDisappear")
                self.offManager.reset()
            })
//            .alert(isPresented: $isPresentingFouncdABarcodeAlert, content: self.foundABarcodeAlert)

            .navigationBarTitle("Scan Barcode")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(leading:
                                    Button("Cancel") { self.presentationMode.wrappedValue.dismiss() }
            )

        }
        .onAppear() {
            print("Scanning view onAppear")
            self.offManager.scan()
        }

    }

//    func foundABarcodeAlert() -> Alert {
//
//        return Alert(title: Text("Barcode gefunden."),
//                     message: Text("\(self.offManager.scannedBarcode ?? "oops")\n Soll ich die zugehörigen Daten laden?"),
//                     primaryButton: .default(Text("Nee danke Du.")) {
//                        self.presentationMode.wrappedValue.dismiss()
//                     },
//                     secondaryButton: .default(Text("ja bitte, leg endlich los.")) {
//                        self.offManager.fetch()
//                     }
//        )
//    }


}






struct ScanningView_Previews: PreviewProvider {
    static var previews: some View {
        ScanningView()
    }
}

