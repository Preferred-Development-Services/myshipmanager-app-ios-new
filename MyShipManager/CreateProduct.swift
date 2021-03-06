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
    @Environment(\.colorScheme) var colorScheme: ColorScheme
    @AppStorage("lastScan") var lastScan: String = ""
    
    @State var allColors: [VariantColor] = [
//        VarietyColor(name: "Red"),
//        VarietyColor(name: "Blue"),
//        VarietyColor(name: "Yellow")
    ]
    
    @State var allSizes: [VariantSize] = [
//        VarietySize(name: "S"),
//        VarietySize(name: "M"),
//        VarietySize(name: "L")
    ]
    
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
    @State var cost: Double = 0.00
    @State var qty: Int = 0
    @State var qtyText: String = ""
    @State var costText:String = ""
    @State var price: Double = 0.00
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
    @State var showAddColor = false
    @State var showAddSize = false
    @State var variantsSaved = false
    @State var selectedColors: Set<VariantColor> = []
    @State var selectedSizes: Set<VariantSize> = []
    @State var shipDate: Date = Date()
    @ObservedObject var recognizedContent = RecognizedContent()
    @State private var isRecognizing = false
    

    

    var body: some View {
            ZStack {
                VStack {
                    Form {
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
                        Section(header: Text("Scans")) {
                            Button("Scan Tags", action:{
                                lastScan = ""
                                self.showScanner=true
                            })
                            TextEditor(text:$lastScan)
                        }
                        Group {
                            Section(header: Text("Title")) {
                                VStack {
                                    TextField("Enter title", text: $title)
                                }
                            }
                            Section(header: Text("Description")) {
                                VStack {
                                    TextEditor(text: $description)
                                }
                            }
                            Section(header: Text("Estimated Ship Date:")) {
                                VStack {
                                    DatePicker("Date",selection: $shipDate,in: Date()..., displayedComponents: .date
                                        )
                                }
                            }
                            Section(header: Text("Tax")) {
                                VStack {
                                    Picker("Charge tax on this product", selection: $tax, content: {
                                            Text("No").tag("N")
                                            Text("Yes").tag("Y")
                                        }
                                    )
                                }
                            }
                            Section(header: Text("Category")) {
                                VStack {
                                    Picker("Pick Category", selection: $categoryId, content: {
                                        ForEach(availableCategories, id: \.code) { Text($0.name) }
                                    })
                                }
                            }
                        }
                        Section(header: Button("Create New Color",action: {
                            self.showAddColor = true
                        })) {
                            MultiSelector(
                                label: Text("Colors"),
                                options: allColors,
                                optionToString: { $0.name },
                                selected: $selectedColors,
                                selectedStr: $colors
                            ).disabled(variantsSaved == true)
                        }
  /*                      Section(header: Text("Colors (comma  separated)")) {
                            VStack {
                                TextField("Enter colors", text: $colors).disabled(variantsSaved == true)
                                    .foregroundColor(variantsSaved ? Color.gray : colorScheme == .dark ? .white : .black)
                            }
                        }
   */
                        Group {
                            Section(header: Button("Create New Size",action: {
                                self.showAddSize = true
                            })
                            ) {
                                MultiSelector(
                                    label: Text("Sizes") ,
                                    options: allSizes,
                                    optionToString: { $0.name },
                                    selected: $selectedSizes,
                                    selectedStr: $sizes
                                )
                            }.disabled(variantsSaved == true)
/*
                            Section(header: Text("Sizes (comma separated)")) {
                                VStack {
                                    TextField("Enter sizes", text: $sizes).disabled(variantsSaved == true)
                                        .foregroundColor(variantsSaved ? Color.gray : colorScheme == .dark ? .white : .black)
                                }
                            }
*/
                        }
                        Section(header: Text("Tags")) {
                            VStack {
                              TextField("Enter tags", text: $tags)
                            }
                        }
                        
                        Section(header: Text("SKU prefix")) {
                            VStack {
                                TextField("Enter string to prefix SKUS", text: $sku)
                            }
                        }
   
                        
                        
                        Group {
                            Section(header: Text("Cost")) {
                                VStack {
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
                            }
                            Section(header: Text("Retail Price")) {
                                VStack {
                                    TextField("Enter Retail Price", text: $priceText) { editing in
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
                                VStack {
                                    TextField("Enter quantity", text: $qtyText)
                                        .keyboardType(.numberPad)
                                }
                            }
                        }
                        Section(header: Text("Variants")) {
                            Button("Edit Variants", action:{
                                if generateVariants() {
                                  self.showVariants=true
                                }
                            })
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
                  print("notloaded")
                  loadListData()
                  print("dataloaded")
                  initializeFormVars()
                  print("initformvars")
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
                VariantsListView(showVariants: $showVariants,variantsSaved: $variantsSaved)
        })
        .sheet(isPresented: $showAddColor, content: {
            AddColorView(showAddColor: $showAddColor,colors: $allColors)
        })
        .sheet(isPresented: $showAddSize, content: {
            AddSizeView(showAddSize: $showAddSize,sizes: $allSizes)
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
 //       print(UserDefaults.standard.dictionaryRepresentation())
        self.cost = 0.0
        self.costText = ""
        self.price = 0.0
        self.qty = 0
        self.qtyText = ""
        self.priceText = ""
        self.lastScan = ""
        self.title = ""
        self.description = ""
        self.defaults.removeObject(forKey: "currentVariants")
        self.defaults.set("", forKey: "lastScan")
        self.tax = defaults.object(forKey: "defaultTax") as? String ?? "N"
        self.sku = defaults.object(forKey: "defaultSku") as? String ?? ""
        self.categoryId = defaults.object(forKey: "defaultCategoryId") as? Int ?? 0
        self.tags = defaults.object(forKey: "defaultTags") as? String ?? ""
        self.tax = defaults.object(forKey: "defaultTax") as? String ?? "N"
        self.sku = defaults.object(forKey: "defaultSku") as? String ?? ""
        print(defaults.object(forKey:"defaultColors") as Any)
        if defaults.object(forKey: "defaultMobileStr") == nil {
            defaults.set(randomString(of:50), forKey: "defaultMobileStr")
        }
        self.mobileStr =  defaults.object(forKey: "defaultMobileStr") as? String ?? ""  // random string to keep products and images linked
        if defaults.object(forKey: "productsAdded") == nil {
            defaults.set(false, forKey: "productsAdded")
        }
    }
    
    func generateVariants() -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for:  nil)
        print(variants)
        let errorMsg:String = requiredVariantFieldsEntered()
        print(errorMsg)
        if errorMsg != "" {
            alertTitle = "Missing Field"
            alertMessage = errorMsg
            showingSuccessAlert = true
            return false
        }
        else {
            let check = defaults.object(forKey: "currentVariants")
            if variants.count == 0 || check == nil {
                variants = [Variant]()
                var oneVariant = Variant()
                self.sku = self.sku.trimmingCharacters(in: .whitespacesAndNewlines)
                if self.sku == "" {
                    self.sku = "SKU"
                }
                colorArray = colors.components(separatedBy: ",")
                sizeArray = sizes.components(separatedBy: ",")
                var skucnt = 1
                for oneSize in 0...sizeArray.count-1 {
                    for oneColor in 0...colorArray.count-1 {
                        oneVariant = Variant()
                        oneVariant.color = self.colorArray[oneColor]
                        oneVariant.size = self.sizeArray[oneSize]
                        oneVariant.qty = Int(self.qtyText) ?? 0
                        oneVariant.qtyText = self.qtyText
                        oneVariant.costText = String(format: "%.2f", oneVariant.cost)
                        oneVariant.cost = self.cost
                        oneVariant.costText = String(format: "%.2f", oneVariant.cost)
                        oneVariant.price = self.price
                        oneVariant.priceText = String(format: "%.2f", oneVariant.price)
                        oneVariant.sku = self.sku + String(skucnt)
                        skucnt = skucnt + 1
                        variants.append(oneVariant)
                    }
                }
                let jsonData = try! JSONEncoder().encode(variants);
     //       let jsonString = String(data: jsonData, encoding: .utf8)!
                defaults.set(jsonData, forKey: "currentVariants")
                print("JSON! \(jsonData)")
                print(defaults.object(forKey: "currentVariants") ?? [])
            }
        }
        return true
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
  //              let responseStr: String = String(data:data, encoding: .utf8) ?? ""
  //              print("RESPONSE: \(responseStr)")
                let jsonDict = json as! [String: Any]

                if let vd = jsonDict["vendors"] as? [[String: Any]] {
                    let v = vendors(json: vd)
 //                   print("vendors:  \(v)")
                    availableVendors = v
                }
                
                if let vd = jsonDict["categories"] as? [[String: Any]] {
                    let v = categories(json: vd)
 //                   print("categories:  \(v)")
                    availableCategories = v
                }
                
                if let vd = jsonDict["variantColors"]  as? [[String:Any]] {
                    for  oneColor in vd {
                        let tmp = oneColor["color"] as! String;
                        let acolor = VariantColor(name: tmp)
                        self.allColors.append(acolor)
                    }
                }
                
                if let vd = jsonDict["variantSizes"]  as? [[String:Any]] {
                    for  oneSize in vd {
                        let tmp = oneSize["size"] as! String;
                        let asize = VariantSize(name: tmp)
                        self.allSizes.append(asize)
                    }
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

        return msg
    }
    
    func requiredVariantFieldsEntered() -> String {
        var msg: String = ""
        if cost == 0 {
            msg = "Please select a default cost"
        }
        if price == 0 {
            msg = "Please select a default retail price"
        }
        if colors == "" && sizes == "" {
            msg = "Please enter colors and/or sizes"
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
        var myVariants = [Variant]()
        var addedVariants = "[]"
        let savedVariants = defaults.object(forKey:
                                                "currentVariants") as? Data
        if savedVariants != nil {
//        print("Variants \(savedVariants)")
          let decoder = JSONDecoder()
          myVariants = try! decoder.decode([Variant].self, from: savedVariants!)
          let jsonData = try! JSONEncoder().encode(myVariants);
          addedVariants = String(data: jsonData, encoding: .utf8)!
        }

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
        let safeCost = costText
        let safePrice = priceText
        let safeQty = qtyText
        let safeShipDate = dateToPHPString(shipDate)
        let payload = "title=\(safeTitle)&description=\(safeDesc)&mobileStr=\(safeMobileStr)&qty=\(safeQty)&colors=\(safeColors)&sizes=\(safeSizes)&cost=\(safeCost)&price=\(safePrice)&shipDate=\(safeShipDate)&taxable=\(safeTax)&sku=\(safeSku)&category=\(safeCategory)&tags=\(safeTags)&addedVariants=\(addedVariants)&scanText=\(defaults.object(forKey: "lastScan") as? String ?? "")"
        
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
                        variantsSaved = false
                        defaults.removeObject(forKey: "currentVariants")
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
