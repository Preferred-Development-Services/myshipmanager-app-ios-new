//
//  AddSizeView.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 5/22/22.
//


import SwiftUI

struct AddSizeView: View {
    @Binding var showAddSize: Bool
    @Binding var sizes: [VariantSize]
    @State var sizeToAdd: String = ""
    var body: some View {
        VStack {
            HStack {
                Button("Cancel", action: {
                    showAddSize = false
                })
                Spacer()
                Button("Save", action: {
                    saveSize();
                    showAddSize = false
                })
            }.padding()
            Section(header: Text("Size To Add")) {
                HStack {
                    Text("Size: ")
                    TextField("Enter Size: ", text: $sizeToAdd)
                }
            }.padding()
        }
        Spacer()
        .navigationBarItems(
            trailing: Button("Save") {
                showAddSize = false
            }
        )
    }
    
    func saveSize() {
        if (sizeToAdd.trimmingCharacters(in: .whitespacesAndNewlines) != "") {
                /*TODO: make backend accept JSON instead*/
                var allowed = CharacterSet.alphanumerics
                allowed.insert(charactersIn: "-._~")
                
                let safeSize = sizeToAdd.addingPercentEncoding(withAllowedCharacters: allowed)!

                let payload = "size=\(safeSize)"
                
                let req = API.shared.post(proc: "include/m-variant-size-save.php", bodyStr: payload)!
            
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
                    
                    if let vd = jsonDict["variantSizes"]  as? [[String:Any]] {
                        sizes = []
                        for  oneSize in vd {
                            let tmp = oneSize["size"] as! String;
                            let asize = VariantSize(name: tmp)
                            sizes.append(asize)
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

