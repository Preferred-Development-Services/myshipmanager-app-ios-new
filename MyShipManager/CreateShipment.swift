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

struct CreateShipment: View {

    let defaults = UserDefaults.standard
    
    @State var showPicker = false
    @State var pickerSource = UIImagePickerController.SourceType.camera
    @State var images = [UIImage]()

    @State var pendingImages = 0
    @State var submitting = false
    @State var failureMessage = ""
    @State fileprivate var result = SubmitResult.none


    @State var availableCategories = [Category]()
    @State var availableStatus = [Status]()
    @State var availableVendors = [Vendor]()
    @State var vendorId: Int = 0
    @State var statusId: Int = 0
    @State var categoryId: Int = 0
    @State var source: String = ""
    @State var estDate: Date = Date()
    @State var showingSuccessAlert = false
    @State var showingErrorAlert = false
    @State var alertTitle = ""
    @State var alertMessage = ""
    @State var newVendor = ""
    @State var loaded = false
    @State var disableCreate = false
    
 
    var body: some View {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Vendor")) {
                            Picker("Pick Vendor", selection: $vendorId, content: {
                                ForEach(availableVendors, id: \.code) { Text($0.name) }
                            })
                            TextField("or Quick Create Vendor", text: $newVendor)
                        }
                        
                        Section(header: Text("Status")) {
                            Picker("Pick Status", selection: $statusId, content: {
                                ForEach(availableStatus, id: \.code) { Text($0.name) }
                            })
                        }
                        Section(header: Text("Source")) {
                            TextField("Enter Source", text: $source)
                        }
                        
                        Section(header: Text("Estimated Ship Date:")) {
                            DatePicker("Date",selection: $estDate,in: Date()..., displayedComponents: .date
                                )
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
                        HStack{
                            Spacer()
                        }
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .foregroundColor(.brandPrimary)
                            .padding()
                       Text("Creating shipment...")
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
                if defaults.object(forKey: "productsCreated") as! String == "Y" {
                    disableCreate = false
                }
                else {
                    disableCreate = true;
                }
                print("disablecreate \(disableCreate)")
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
            trailing: Button("Create") {
                startSubmit()
            }
            .disabled(disableCreate)
 //               .disabled((defaults.object(forKey: "defaultStatusId") as! String == "N" ))
        )
        .alert(isPresented: $showingSuccessAlert) {
            Alert(title: Text(alertTitle), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: finishCreate)
            )
        }
    }
    
    func finishCreate()  {
        defaults.set("N", forKey: "productsCreated")
        disableCreate = true;
    }

    func deleteShipment() {
        
    }
    
    
    func initializeFormVars() {
        
        vendorId = defaults.object(forKey: "defaultVendorId") as? Int ?? 0
        categoryId = defaults.object(forKey: "defaultCategoryId") as? Int ?? 0
        statusId = defaults.object(forKey: "defaultStatusId") as? Int ?? 0
        source = defaults.object(forKey: "defaultSource") as! String 
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
                
                if let vd = jsonDict["status"] as? [[String: Any]] {
                    let v = status(json: vd)
                    print("status:  \(v)")
                    availableStatus = v
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
        if vendorId == 0 {
            msg = "Please select a vendor"
        }
        if categoryId == 0 {
            msg = "Please select a category"
        }
        if statusId == 0 {
            msg = "Please select a status"
        }
        return msg
    }

    func uploadImages(initial: Bool) {
        
        if initial {
            pendingImages = images.count
        }
        
        if pendingImages == 0 {
            createShipment()
            return
        }
        print("uploading image \(pendingImages-1)")
        let image = images[pendingImages-1]
        
        var req = API.shared.post(proc: "include/a-shipment-upload.php?filearraycode=10", bodyStr: "")!
        
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
    
 
 
    func createShipment() {

        print("createProduct")
        /*TODO: make backend accept JSON instead*/
        var allowed = CharacterSet.alphanumerics
        allowed.insert(charactersIn: "-._~")
        


        let safeCategory = categoryId
        let safeVendor = vendorId
        let safeStatus = statusId
        let safeEst = dateToPHPString(estDate)
        let safeSource = source.addingPercentEncoding(withAllowedCharacters: allowed)!

        let payload = "category=\(safeCategory)&vendor=\(safeVendor)&estDate=\(safeEst)&status=\(safeStatus)&source=\(safeSource)"
        
        print("payload: \(payload)")
        
        let req = API.shared.post(proc: "include/m-pending-shipment-save.php", bodyStr: payload)!
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

                if let rd = jsonDict["result"] as? Int {
                    submitting = false
                    if rd == 1 {
                        initializeFormVars()
                        images = [UIImage]()
                        alertTitle = "Shipment created"
                        alertMessage = "This shipment has been created"
                        showingSuccessAlert = true
//                        ShipmentList()
                        
                    }
                    else {
                        alertTitle = "Error creating shipment"
                        alertMessage = "There was a problem creating this shipment"
                        showingSuccessAlert = true
                   }
                }
                else {
                    submitting = false
                    alertTitle = "Error creating shipment"
                    alertMessage = "There was a problem creating this shipment"
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

struct CreateShipment_Previews: PreviewProvider {
    @State static var f = false
    static var previews: some View {
        CreateShipment()
    }
}
