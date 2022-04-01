//
//  Defaults.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 3/27/22.
//

import SwiftUI

fileprivate enum SubmitResult {
    case none, fail, success
}

struct CreateProduct: View {

    let defaults = UserDefaults.standard
    
    @State var showPicker = false
    @State var pickerSource = UIImagePickerController.SourceType.camera
    @State var images = [UIImage]()
    
    @State var pendingImages = 0
    @State var submitting = false
    @State var failureMessage = ""
    @State fileprivate var result = SubmitResult.none
    

    @State var availableCategories = [Category]()
    @State var vendorId: Int
    @State var title: String = ""
    @State var description: String = ""
    @State var categoryId: Int
    @State var source: String
    @State var tags: String
    @State var sizes: String
    @State var colors: String
    @State var tax: String
    @State var qty: Int = 0
    @State var cost: Double = 0.0
    @State var costText:String = ""
    @State var price: Double = 0
    @State var priceText:String = ""
    @State var sku: String
    @State private var showingAlert = false
   
    
    init () {
        self.vendorId = defaults.object(forKey: "defaultVendorId") as? Int ?? 0
        self.categoryId = defaults.object(forKey: "defaultCategoryId") as? Int ?? 0
        self.source = defaults.object(forKey: "defaultSource") as? String ?? ""
        self.tags = defaults.object(forKey: "defaultTags") as? String ?? ""
        self.colors = defaults.object(forKey: "defaultColors") as? String ?? ""
        self.sizes = defaults.object(forKey: "defaultSizes") as? String ?? ""
        self.tax = defaults.object(forKey: "defaultTax") as? String ?? "N"
        self.sku = defaults.object(forKey: "defaultSku") as? String ?? ""
        self.vendorId = defaults.object(forKey: "defaultVendorId") as? Int ?? 0
    }

    var body: some View {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Title")) {
                            TextField("Enter Title", text: $title) 
                        }
                        
                        Section(header: Text("Description")) {
                            TextEditor(text: $description)
                        }
    
                        Section(header: Text("Tax")) {
                            Picker("Charge tax on this product", selection: $tax, content: {
                                    Text("No").tag(1)
                                    Text("Yes").tag(2)
                                }
                            )
                        }
                        Section(header: Text("Category")) {
                            Picker("Pick Category", selection: $categoryId, content: {
                                ForEach(availableCategories, id: \.code) { Text($0.name) }
                            })
                        }
                        Section(header: Text("Tags")) {
                            TextField("Enter tags", text: $tags)
                        }
                        
                        Group {
                            Section(header: Text("Colors")) {
                                    TextField("Enter colors (comma separated)", text: $colors)
                            }
                            Section(header: Text("Sizes")) {
                                    TextField("Enter sizes (comman separated)", text: $sizes)
                            }
                        }
                        
                        Section(header: Text("SKU prefix")) {
                                TextField("Enter string to prefix SKUS", text: $sku)
                        }
   
                        
                        
                        Group {
                            Section(header: Text("Cost")) {
                                TextField("Enter Cost", text: $costText) { editing in
                                    if !editing {
                                        costText = costText.trimmingCharacters(in: .whitespacesAndNewlines)
                                        cost = fabs(Double(costText) ?? 0)
                                        costText = String(format: "%.2f", cost)
                                        cost = Double(costText) ?? 0
                                    }
                                } onCommit: {}
                                    .keyboardType(.decimalPad)
                            }
                            Section(header: Text("Price")) {
                                TextField("Enter Price", text: $priceText) { editing in
                                    if !editing {
                                        priceText = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
                                        price = fabs(Double(priceText) ?? 0)
                                        priceText = String(format: "%.2f", price)
                                        price = Double(priceText) ?? 0
                                    }
                                } onCommit: {}
                                    .keyboardType(.decimalPad)
                            }
                        }

                        Section(header: Text("Quantity")) {
                            HStack{
                                TextField("Enter Quantity", text: Binding(
                                    get: { String(qty)},
                                    set: { qty = abs(Int($0) ?? 0) }
                                ))
                                    .keyboardType(.numberPad)
                            }
                        }

                        Section(header: Text("Images")) {
                            ForEach(0..<images.count, id: \.self) {
                                Image(uiImage: images[$0])
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(alignment: .center)
                                    .padding()
                            }
                            HStack {
                                Image(systemName: "photo.fill.on.rectangle.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.brandPrimary)
                                    .frame(height: 100)
                                    .padding()
                                    .onTapGesture {
                                        pickerSource = .photoLibrary
                                        showPicker = true
                                    }
                                Image(systemName: "camera.fill")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .foregroundColor(.brandPrimary)
                                    .frame(height: 100)
                                    .padding()
                                    .onTapGesture {
                                        pickerSource = .camera
                                        showPicker = true
                                    }
                            }
                        }

                    }
                    
                }

                if submitting {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .foregroundColor(.brandPrimary)
                            .padding()
                        Text("Adding new queued shipment...")
                            .bold()
                            .padding()
                            .foregroundColor(.brandPrimary)
                    }
                }
                if result == .success {
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .frame(width: 150, height: 150, alignment: .center)
                    .foregroundColor(.brandPrimary)
                } else if result == .fail {
                    VStack {
                    Image(systemName: "xmark.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150, alignment: .center)
                        .foregroundColor(.red)
                    Text(self.failureMessage)
                        .bold()
                        .padding()
                        .foregroundColor(.red)
                        //.background(Color.white)
                    }
                    }
            }
        .onAppear() {
            print("onAppear")
            loadVendorsAndCategories()
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerView(sourceType: $pickerSource) { image in
                images.append(image)
            }
        }
        .navigationBarItems(
            trailing: Button("Add") {
                startSubmit()
                showingAlert = true
            }
                .alert(isPresented: $showingAlert) {
                    Alert(title: Text("Product Added"), message: Text("This product has been added"), dismissButton: .default(Text("OK")))
                }
        )
 
    }

    
    func loadVendorsAndCategories() {
        let req = API.shared.get(proc: "include/m-vendors-cats-get.php")!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonDict = json as! [String: Any]
                
                
                if let vd = jsonDict["categories"] as? [[String: Any]] {
                    let v = categories(json: vd)
                    print("categories:  \(v)")
                    availableCategories = v
                }
            }
        }
        
        task.resume()
    }
    
    
    /* because of iOS callbacks: startSubmit -> createVendor -> uploadImages -> createProduct */
    
    func startSubmit() {
        guard !submitting else {
            return
        }
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        submitting = true
        

        let req = API.shared.get(proc: "queued-order.php")!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                submitting = false
                return
            }
            
            if data != nil {
                self.uploadImages(initial: true)
            }
        }
        
        task.resume()
    }
    
    func uploadImages(initial: Bool) {
        if vendorId == 0 {
            showError(message: "Please pick a vendor")
            return
        }
        if categoryId == 0 {
            showError(message: "Please pick a category")
            return
        }
        if title == "" {
            showError(message: "Please pick a title")
            return
        }
        
        if initial {
            pendingImages = images.count
        }
        
        if pendingImages == 0 {
            createProduct()
            return
        }

        print("uploading image \(pendingImages-1)")
        let image = images[pendingImages-1]
        
        var req = API.shared.post(proc: "include/a-shipment-upload.php", bodyStr: "")!
        
        let boundary = UUID().uuidString
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        data.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"file\"; filename=\"\(pendingImages).jpeg\"\r\n".data(using: .utf8)!)
        //data.append("Content-Type: image/png\r\n\r\n".data(using: .utf8)!)
        //data.append(image.pngData()!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(image.jpegData(compressionQuality: 0.95)!)
        data.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        
        let task = URLSession.shared.uploadTask(with: req, from: data, completionHandler: { responseData, response, error in
            if error == nil {
                pendingImages -= 1
                uploadImages(initial: false)
            }
        })
        
        task.resume()
    }
    
        
            
    func createProduct() {
 /*       print("createProduct")
        /*TODO: make backend accept JSON instead*/
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        
        let safeSource = source.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeNotes = notes.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeCost = cost
        let payload = "vendor=\(vendorId)&source=\(safeSource)&numStyles=\(styles)&numPacks=\(pieces)&cost=\(safeCost)&notes=\(safeNotes)"
        
        print("payload: \(payload)")
        
        let req = API.shared.post(proc: "include/a-queued-order-save.php", bodyStr: payload)!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonDict = json as! [String: Any]
                // TODO: check success == String("1")
                print(jsonDict)
                showSuccess()
            }
        }
        
        task.resume()
  */
    }

    func showError(message: String) {
        DispatchQueue.main.async {
            submitting = false
            failureMessage = message
            result = .fail
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                result = .none
            }
        }
    }
    
    func showSuccess() {
        DispatchQueue.main.async {
            submitting = false
            result = .success
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            }
        }
    }
}

struct CreateProduct_Previews: PreviewProvider {
    @State static var f = false
    static var previews: some View {
        CreateProduct()
    }
}