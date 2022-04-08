//
//  ContentView.swift
//  ScanAndRecognizeText
//
//  Created by Gabriel Theodoropoulos.
//

import SwiftUI

struct TextScanView: View {
    @ObservedObject var recognizedContent = RecognizedContent()
    @State private var showScanner = false
    @State private var isRecognizing = false
    
    var body: some View {
            ZStack(alignment: .bottom) {
                
                List(recognizedContent.items, id: \.id) { textItem in
 //                   NavigationLink(destination: TextPreviewView(text: textItem.text)) {
 //                       Text(String(textItem.text.prefix(50)).appending("..."))
                    Text(String(textItem.text))
 //                   }
                }
                
                
                if isRecognizing {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: Color(UIColor.systemIndigo)))
                        .padding(.bottom, 20)
                }
                
            }
            .navigationTitle("Tag Scanner")
            .navigationBarItems(trailing: Button(action: {
                guard !isRecognizing else { return }
                showScanner = true
            }, label: {
                HStack {
                    Image(systemName: "doc.text.viewfinder")
                        .renderingMode(.template)
                        .foregroundColor(.white)
                    Text("Scan Next Product")
                        .foregroundColor(.white)
                }
                .padding(.horizontal, 16)
                .frame(height: 36)
                .background(Color(UIColor.systemIndigo))
                .cornerRadius(18)
            }))

        .sheet(isPresented: $showScanner, content: {
            TextScannerView { result in
                switch result {
                    case .success(let scannedImages):
                        isRecognizing = true
                        
                        TextRecognition(scannedImages: scannedImages,
                                        recognizedContent: recognizedContent) {
                            // Text recognition is finished, hide the progress indicator.
                            isRecognizing = false
                        }
                        .recognizeText()
                        
                    case .failure(let error):
                        print(error.localizedDescription)
                }
                
                showScanner = false
                
            } didCancelScanning: {
                // Dismiss the scanner controller and the sheet.
                showScanner = false
            }
        })
    }
}

struct TextScan_Previews: PreviewProvider {
    static var previews: some View {
        TextScanView()
    }
}
