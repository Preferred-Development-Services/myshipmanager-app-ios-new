//
//  AddColorView.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 5/21/22.
//

import SwiftUI

struct AddColorView: View {
    @Binding var showAddColor: Bool
    @Binding var colors: [VarietyColor]
    @State var colorToAdd: String = ""
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", action: {
                    showAddColor = false
                })
                Spacer()
                Button("Save", action: {
                    saveColor();
                    showAddColor = false
                })
            }.padding()
            Section(header: Text("Color To Add")) {
                HStack {
                    Text("Color: ")
                    TextField("Enter Color Name", text: $colorToAdd)
                }
            }.padding()
        }
        Spacer()
        .navigationBarItems(
            trailing: Button("Save") {
 //               saveDefaults()
                showAddColor = false
            }
        )
    }
    
    func saveColor() {
        if (colorToAdd.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                print("createProduct")
                /*TODO: make backend accept JSON instead*/
                var allowed = CharacterSet.alphanumerics
                allowed.insert(charactersIn: "-._~")
                
                let safeColor = colorToAdd.addingPercentEncoding(withAllowedCharacters: allowed)!

                let payload = "color=\(safeColor)"
                
                let req = API.shared.post(proc: "include/m-variant-color-save.php", bodyStr: payload)!
            
                let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
                if let err = err {
                    print(err)
                    return
                }
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
      //              let responseStr: String = String(data:data, encoding: .utf8) ?? ""
      //              print("RESPONSE: \(responseStr)")
                    let jsonDict = json as! [String: Any]
                    
                    if let vd = jsonDict["variantColors"]  as? [[String:Any]] {
                        colors = []
                        for  oneColor in vd {
                            let tmp = oneColor["color"] as! String;
                            let acolor = VarietyColor(name: tmp)
                            colors.append(acolor)
                        }
                    }
                    
                }
            }
            task.resume()

                }
        print("DONE")
 //               task.resume()
        
    }

}

