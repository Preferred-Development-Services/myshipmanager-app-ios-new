//
//  ContentView.swift
//  BarcodeScanner
//
//  Created by Tobias Wissmüller on 26.05.21.
//

import SwiftUI

struct ContentView: View {
    @State var scanResult = "n/a"
    var body: some View {
        VStack {
            ScannerView(result: $scanResult)
            Text("\(scanResult)")
                .frame(height: 200)
                .font(.system(size: 30))
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
