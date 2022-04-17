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
    @State var title:String = "No information given";
    @State var description:String = "No information given";
    @State var brand:String = "No information given";
    @State var manufacturer:String = "No information given";
    @State var cost:String = "0.00";
    @State var size:String = "No information given";
    @State var color:String = "No information given";
    @State var barcodeInfo = [BarcodeInfo]()
    var body: some View {
        ScrollView {
            ZStack {
            LazyVStack {
                HStack {
                    Text("Title:")
                    TextEditor(text: $title)
                }
                HStack {
                    Text("Description:")
                    TextEditor(text: $description)
                }
                HStack {
                    Text("Brand:")
                    TextField("brand",text: $brand)
                }
                HStack {
                    Text("Manufacturer:")
                    TextField("manufacturer",text: $manufacturer)
                }
                HStack {
                    Text("Cost:")
                    TextField("cost",text: $cost)
                }
                HStack {
                    Text("Size(s):")
                    TextField("size",text: $size)
                }
                HStack {
                    Text("Color(s):")
                    TextField("color",text: $color)
                }
            }
            .padding()
            .onAppear() {
 //               checkSession()
                GetInfo()
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
            trailing: Button("Scan Another") {
                appState.currentBarcode = ""
                appState.barcodeFound = false
            }
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
                let barcodeInfo = try! JSONDecoder().decode([BarcodeInfo].self, from: data)
                DispatchQueue.main.async {
                    loading = false
                    title = barcodeInfo[0].title
                    description = barcodeInfo[0].description
                    brand = barcodeInfo[0].brand
                    manufacturer = barcodeInfo[0].manufacturer
                    cost = barcodeInfo[0].cost
                    size = barcodeInfo[0].size
                    color = barcodeInfo[0].color
                }
            }
            print("data: \(String(describing: data))")
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
