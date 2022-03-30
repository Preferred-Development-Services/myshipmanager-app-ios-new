//
//  ContentView.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import SwiftUI

struct BarcodeInfoView: View {
    @EnvironmentObject var appState: AppState
    @State var showModal = false
    @State var checked = false
    @State var loading = false
    
    var body: some View {
        ScrollView {
            ZStack {
                Text("here")
            LazyVStack {
            }
            if loading {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .foregroundColor(.brandPrimary)
                            .padding()
                        Text("Loading...")
                            .bold()
                            .padding()
                            .foregroundColor(.brandPrimary)
                            .background(Color.brandWhite)
                    }
                }
   
            }
        }
        .navigationBarItems(
            trailing: Button("Retrieve Information") { GetInfo() }
        )
    }


    func GetInfo() {

        let url = "include/m-get-barcode-info.php?barcode=" + appState.currentBarcode;


        print("url: \(url)")
        
        let req = API.shared.get(proc: url)!
        
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("dataString: \(dataString)")
            }
        }
        
        task.resume()
    }
    
    func checkSession() {
        guard !checked else { return }
        checked = true
        
        let req = API.shared.sessionRefreshRequest()!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            
            guard data != nil else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            let jsonDict = json as! [String: Any]
            let success = jsonDict["sessionValid"] as? Bool
            if (success == nil) || (success! != true) {
                print("session dead!")
                refreshSession()
            } else {
                print("session good!")
            }
        }
        
        task.resume()
    }
    
    func refreshSession() {
        let req = API.shared.loginRequest()!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                // TODO: ui show error
                print(err)
                return
            }

            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonDict = json as! [String: Any]
                if let success = jsonDict["loginsuccess"] as? String {
                    if success == "1" {
                        if let r = resp as? HTTPURLResponse {
                            let sessionCookie = (r.value(forHTTPHeaderField: "Set-Cookie") ?? "").components(separatedBy: ";").first ?? ""
                            if sessionCookie != "" {
                                DispatchQueue.main.async {
                                    API.shared.saveSession(cookie: sessionCookie)
                                }
                                return
                            }
                        }
                    }
                }
                print("bad credentials")
                
                DispatchQueue.main.async {
                    API.shared.clearSession()
                }
            }
        }
        
        task.resume()
    }
    
}

struct BarcodeInfoView_Previews: PreviewProvider {
    static var previews: some View {
        BarcodeInfoView()
    }
}
