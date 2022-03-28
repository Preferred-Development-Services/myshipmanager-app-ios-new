//
//  ForgotPassword.swift
//  MyShipManager
//
//  Created by Matt on 5/7/21.
//

import SwiftUI

struct ForgotPassword: View {
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var email = ""
    
    var body: some View {
        VStack {
            TextField("email", text: $email) { _ in } onCommit: {
                submit()
            }
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding()
            Spacer()
        }
            .background(Color(UIColor.systemGray6).ignoresSafeArea())
            .navigationTitle("Forgot Password")
            .navigationBarItems(trailing: Button("Submit") { submit() })
    }
    
    func submit() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let safeEmail = email.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        let req = API.shared.post(proc: "include/a-recover_password.php", bodyStr: "email=\(safeEmail)")!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            print("TODO: handle error/success")
            DispatchQueue.main.async {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
        
        task.resume()
        
    }
}

struct ForgotPassword_Previews: PreviewProvider {
    static var previews: some View {
        ForgotPassword()
    }
}
