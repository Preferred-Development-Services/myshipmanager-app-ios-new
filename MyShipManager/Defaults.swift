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

struct SetDefaults: View {
    @Binding var isPresented: Bool
    
    @State var showPicker = false
    @State var pickerSource = UIImagePickerController.SourceType.camera
    @State var images = [UIImage]()
    
    @State var pendingImages = 0
    @State var submitting = false
    @State var failureMessage = ""
    @State fileprivate var result = SubmitResult.none
    
    @State var availableVendors = [Vendor]()
    @State var newVendor = ""
    @State var vendorId = 0
    @State var source = ""
    @State var styles = 0
    @State var pieces = 0
    @State var costText = ""
    @State var cost = 0.0
    @State var notes = ""

    var body: some View {
        NavigationView {
            ZStack {
                VStack {
                    Form {
                        Section(header: Text("Vendor")) {
                            Picker("Pick Vendor", selection: $vendorId, content: {
                                ForEach(availableVendors, id: \.code) { Text($0.name) }
                            })
                            TextField("or Quick Create Vendor", text: $newVendor)
                        }
                        
                        Section(header: Text("Source")) {
                            TextField("Enter Source", text: $source)
                        }
                        
                        Section(header: Text("Styles")) {
                            HStack{
                                TextField("Enter Number", text: Binding(
                                    get: { String(styles)},
                                    set: { styles = abs(Int($0) ?? 0) }
                                ))
                                    .keyboardType(.numberPad)
                                Stepper("", value: Binding(get: {styles}, set: {styles = max($0, 0)}))
                            }
                        }
                        
                        Section(header: Text("Packs/Pieces")) {
                            HStack {
                                TextField("Enter Number", text: Binding(
                                        get: { String(pieces)},
                                        set: { pieces = abs(Int($0) ?? 0) }
                                ))
                                .keyboardType(.numberPad)
                                    Stepper("", value: Binding(get: {pieces}, set: {pieces = max($0, 0)}))
                            }
                        }
                        
                        Section(header: Text("Cost")) {
                            TextField("Enter Number", text: $costText) { editing in
                                if !editing {
                                    costText = costText.trimmingCharacters(in: .whitespacesAndNewlines)
                                    cost = fabs(Double(costText) ?? 0)
                                    costText = String(format: "%.2f", cost)
                                    cost = Double(costText) ?? 0
                                }
                            } onCommit: {}
                                .keyboardType(.numbersAndPunctuation)
                        }
                        
                        Section(header: Text("Notes")) {
                            TextEditor(text: $notes)
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
            .navigationBarItems( trailing: Button("Set") { startSubmit() })
        }
        .onAppear() {
            print("onAppear")
            loadVendors()
        }
        .sheet(isPresented: $showPicker) {
            ImagePickerView(sourceType: $pickerSource) { image in
                images.append(image)
            }
        }
    }
    
    func loadVendors() {
        let req = API.shared.get(proc: "include/a-manageVendors-get.php")!
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
            }
        }
        
        task.resume()
    }
    
    
    /* because of iOS callbacks: startSubmit -> createVendor -> uploadImages -> createOrder */
    
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
                self.createVendor()
            }
        }
        
        task.resume()
    }
    
    func createVendor() {
        newVendor = newVendor.trimmingCharacters(in: .whitespacesAndNewlines)
        if newVendor != "" {
            var allowed = CharacterSet.alphanumerics
            allowed.insert(charactersIn: "-._~")
            let safeName = newVendor.addingPercentEncoding(withAllowedCharacters: allowed)!
            let payload = "vendorName=\(safeName)&vendor="
            
            print("payload: \(payload)")
            
            let req = API.shared.post(proc: "include/a-queued-order-vendor-save.php", bodyStr: payload)!
            let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
                if let err = err {
                    print(err)
                    showError(message: "Failed to create vendor")
                    return
                }
                
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    let jsonDict = json as! [String: Any]
                    
                    if let vendorCode = jsonDict["vendorCode"]  as? Int {
                        if vendorCode != 0 {
                            vendorId = vendorCode
                            uploadImages(initial: true)
                            return
                        }
                    }
                    
                    showError(message: "Failed to create vendor")
                }
            }
            
            task.resume()
            return
        }
        
        if vendorId == 0 {
            showError(message: "Please pick a vendor!")
            return
        }
        
        uploadImages(initial: true)
    }
        
            
    
    func uploadImages(initial: Bool) {
        if initial {
            pendingImages = images.count
        }
        
        if pendingImages == 0 {
            createOrder()
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
    
    func createOrder() {
        print("createOrder")
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
                isPresented = false
            }
        }
    }
}

struct SetDefaults_Previews: PreviewProvider {
    @State static var f = false
    static var previews: some View {
        SetDefaults(isPresented: $f)
    }
}
