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
    @AppStorage("lastScan") var lastScan: String = ""
    @State var showPicker = false
    @State var pickerSource = UIImagePickerController.SourceType.camera
    @State var images = [UIImage]()
    @State var colorArray = [String]()
    @State var sizeArray = [String]()

    @State var pendingImages = 0
    @State var submitting = false
    @State var colors = ""
    @State var sizes = ""
    @State var failureMessage = ""
    @State var title = ""
    @State var description = ""
    @State fileprivate var result = SubmitResult.none

//    @State var lastScan = ""
    @State var availableCategories = [Category]()
    @State var availableVendors = [Vendor]()
    @State var variants =  [Variant]()
    @State var categoryId: Int = 0
    @State var scannedText: String = ""
    @State var tags: String = ""
    @State var tax: String = "N"
    @State var cost: Double = 0.0
    @State var qty: String = ""
    @State var costText:String = ""
    @State var price: Double = 0.0
    @State var priceText:String = ""
    @State var sku: String = ""
    @State var mobileStr: String = ""
    @State var showingSuccessAlert = false
    @State var showingErrorAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var loaded = false;
    @State var showScanner = false
    @State var showVariants = false
    @ObservedObject var recognizedContent = RecognizedContent()
    @State private var isRecognizing = false
    

    var body: some View {
            ZStack {
                VStack {
                    Form {
                        Group {
                            Section(header: Text("Title")) {
                                TextField("Enter title", text: $title)
                            }
                            Section(header: Text("Description")) {
                                TextEditor(text: $description)
                                                 }
                            Section(header: Text("Tax")) {
                                Picker("Charge tax on this product", selection: $tax, content: {
                                        Text("No").tag("N")
                                        Text("Yes").tag("Y")
                                    }
                                )
                            }
                            Section(header: Text("Category")) {
                                Picker("Pick Category", selection: $categoryId, content: {
                                    ForEach(availableCategories, id: \.code) { Text($0.name) }
                                })
                            }
                        }
                        Section(header: Text("Colors (comma  separated)")) {
                            TextField("Enter colors", text: $colors)
                        }
                        Section(header: Text("Sizes (comma separated)")) {
                            TextField("Enter sizes", text: $sizes)
                        }
                        Section(header: Text("Tags")) {
                            TextField("Enter tags", text: $tags)
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
                            Section(header: Text("Retail Price")) {
                                TextField("Enter Retail Price", text: $priceText) { editing in
                                    if !editing {
                                        priceText = priceText.trimmingCharacters(in: .whitespacesAndNewlines)
                                        price = fabs(Double(priceText) ?? 0)
                                        priceText = String(format: "%.2f", cost)
                                        price = Double(priceText) ?? 0
                                    }
                                } onCommit: {}
                                    .keyboardType(.decimalPad)
                            }
                            TextField("Enter quantity", text: $qty).keyboardType(.numberPad)
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
                        Button("Create Variants", action:{
                            generateVariants()
                            print(self.colors)
                            print(self.sizes)
                            self.showVariants=true
                        })
                        Button("Scan Tags", action:{
                            lastScan = ""
                            self.showScanner=true
                        })

                        Section(header: Text("Scanned Label Text")) {
                            TextEditor(text:$lastScan)
                        }

                    }
/*                    .toolbar {
                        ToolbarItem (placement: .keyboard) {
                            Button("Done") {
                                hideKeyboard()
                            }
                        }
                    }
*/
                }


                if submitting {
                    VStack {
                        HStack{
                            Spacer()
                        }
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .foregroundColor(.brandPrimary)
                            .padding()
                       Text("Saving product information...")
                            .bold()
                            .padding()
                            .foregroundColor(.brandPrimary)
                        Spacer()
                    }
                    .background(Color.white)
                }

            }
            .onAppear() {
                print("onAppear")
                if !loaded {
                  loadListData()
                  initializeFormVars()
                  loaded = true
              }
            }
        .sheet(isPresented: $showPicker) {
            ImagePickerView(sourceType: $pickerSource) { image in
                images.append(image)
            }
        }
        .navigationBarItems(
            leading: Button("Hide keyboard") {
                hideKeyboard()
            },
            trailing: Button("Add") {
                startSubmit()
            }
        )
        .alert(isPresented: $showingSuccessAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
        .sheet(isPresented: $showVariants, content: {
            VStack{
                List {
                    ForEach($variants) { $variant in
                        TextField("Color", text: $variant.color)
                    }
                }
            }
        })
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
 

    
    func initializeFormVars() {
        print("Initialize")
        self.cost = 0.0
        self.costText = ""
        self.price = 0.0
        self.qty = ""
        self.priceText = ""
        self.lastScan = ""
        self.title = ""
        self.description = ""
        self.defaults.set("", forKey: "lastScan")
        self.tax = defaults.object(forKey: "defaultTax") as? String ?? "N"
        self.sku = defaults.object(forKey: "defaultSku") as? String ?? ""
        self.categoryId = defaults.object(forKey: "defaultCategoryId") as? Int ?? 0
        self.tags = defaults.object(forKey: "defaultTags") as? String ?? ""
        self.tax = defaults.object(forKey: "defaultTax") as? String ?? "N"
        self.sku = defaults.object(forKey: "defaultSku") as? String ?? ""
        self.colors = defaults.object(forKey: "defaultColors") as? String ?? ""
        self.sizes = defaults.object(forKey: "defaultSizes") as? String ?? ""
        if defaults.object(forKey: "defaultMobileStr") == nil {
            defaults.set(randomString(of:50), forKey: "defaultMobileStr")
        }
        self.mobileStr =  defaults.object(forKey: "defaultMobileStr") as? String ?? ""  // random string to keep products and images linked
        if defaults.object(forKey: "productsAdded") == nil {
            defaults.set(false, forKey: "productsAdded")
        }
    }
    
    func generateVariants() {
        variants = [Variant]()
        var oneVariant = Variant()
        colorArray = colors.components(separatedBy: ",")
        sizeArray = sizes.components(separatedBy: ",")
        print("COLORARAY - \(colorArray)")
        print("SIZEARRAY - \(sizeArray)")
        for oneSize in 0...sizeArray.count-1 {
            for oneColor in 0...colorArray.count-1 {
                oneVariant.color = self.colorArray[oneColor]
                oneVariant.size = self.sizeArray[oneSize]
                oneVariant.qty = Int(self.qty) ?? 0
                oneVariant.cost = self.cost
                oneVariant.price = self.price
                oneVariant.sku = self.sku
                variants.append(oneVariant)
            }
        }
    }
    
    func loadListData() {

        let req = API.shared.get(proc: "include/m-list-data-get.php")!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let responseStr: String = String(data:data, encoding: .utf8) ?? ""
                print("RESPONSE: \(responseStr)")
                let jsonDict = json as! [String: Any]
                
                if let vd = jsonDict["vendors"] as? [[String: Any]] {
                    let v = vendors(json: vd)
                    print("vendors:  \(v)")
                    availableVendors = v
                }
                
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
        let errorMsg:String = requiredFieldsEntered()
        print(errorMsg)
        if errorMsg != "" {
            alertTitle = "Missing Field"
            alertMessage = errorMsg
            showingSuccessAlert = true
            return
        }

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
    
    
    func requiredFieldsEntered() -> String {
        var msg: String = ""
        if categoryId == 0 {
            msg = "Please select a category"
        }
        if cost == 0 {
            msg = "Please select a default cost"
        }
        if price == 0 {
            msg = "Please select a default retail price"
        }
        if title == "" {
            msg = "Please enter a title"
        }
        if images.count == 0 {
            msg = "Please upload an image"
        }
        return msg
    }

    func uploadImages(initial: Bool) {
        
        if initial {
            pendingImages = images.count
        }
        
        if pendingImages == 0 {
            createProduct()
            return
        }
        print("uploading image \(pendingImages-1)")
        let image = images[pendingImages-1]
        
        var req = API.shared.post(proc: "include/a-shipment-product-image-upload.php", bodyStr: "")!
        
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
        print("createProduct")
        /*TODO: make backend accept JSON instead*/
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        

        let safeMobileStr = mobileStr.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeTax = tax
        let safeTitle = title.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeDesc = description.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeSizes = sizes.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeColors = colors.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeTags = tags.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeSku = sku.addingPercentEncoding(withAllowedCharacters: allowed)!
        let safeCategory = categoryId
        let safeCost = cost
        let safePrice = price
        let safeQty = qty
        let payload = "title=\(safeTitle)&description=\(safeDesc)&mobileStr=\(safeMobileStr)&qty=\(safeQty)&colors=\(safeColors)&sizes=\(safeSizes)&cost=\(safeCost)&price=\(safePrice)&taxable=\(safeTax)&sku=\(safeSku)&category=\(safeCategory)&tags=\(safeTags)&scanText=\(defaults.object(forKey: "lastScan") as? String ?? "")"
        
        print("payload: \(payload)")
        
        let req = API.shared.post(proc: "include/m-pending-product-save.php", bodyStr: payload)!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonDict = json as! [String: Any]

                if let rd = jsonDict["result"] as? Int {
                    submitting = false
                    if rd == 1 {
                        defaults.set(randomString(of:50), forKey: "defaultMobileStr")
                        initializeFormVars()
                        images = [UIImage]()
                        defaults.set("Y", forKey: "productsCreated")
                        alertTitle = "Product Added"
                        alertMessage = "This product has been added"
                        showingSuccessAlert = true
                        
                    }
                    else {
                        alertTitle = "Error adding product"
                        alertMessage = "There was a problem adding this product"
                        showingSuccessAlert = true
                   }
                }
                else {
                    submitting = false
                    alertTitle = "Error adding product"
                    alertMessage = "There was a problem adding this product"
                    showingSuccessAlert = true
                }
            }
        }
        task.resume()
        
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
