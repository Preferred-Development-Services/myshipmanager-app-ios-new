//
//  ContentView.swift
//  BarcodeScanner
//
//  Created by Tobias Wissmüller on 26.05.21.
//

import SwiftUI

struct BarcodeContentView: View {
    @EnvironmentObject var appState: AppState
    @State var scanResult = ""

    func assignBarcodeFound(value: Bool) -> some View {
        appState.barcodeFound = value
        return Text("assigned")
    }
    
    func assignCurrentBarcode(value: String) -> some View {
        appState.currentBarcode = value
        return Text("assigned")
    }
    
    var body: some View {
        VStack (spacing: 20){
  //          BarcodeInfoView()
            
            ScannerView(result: $scanResult)
            
            if (scanResult != "") {
                assignBarcodeFound(value: true)
                assignCurrentBarcode(value: scanResult)
  //              GetInfo(barcode: scanResult)
 //               BarcodeInfoView(barcode: scanResult)
 //               Text("\(scanResult) barcode found")
  //              .frame(height: 200)
   //             .font(.system(size: 30))
            }
  //          if scanResult != "" {
  //            Button("Get Information") { BarcodeInfoView(barcode: scanResult)
  //              }
  //            BarcodeInfoView(barcode: scanResult)

            }
  //          BarcodeInfoView(barcode: scanResult)
        }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeContentView()
    }
}
