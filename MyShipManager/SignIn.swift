//
//  SignIn.swift
//  MyShipManager
//
//  Created by Matt on 4/24/21.
//

import SwiftUI

fileprivate enum SubmitResult {
    case none, fail, success
}

struct SignIn: View {
    @State var user = ""
    @State var pass = ""
    
    @State var submitting = false
    @State var failureMessage = ""
    @State fileprivate var result = SubmitResult.none
        

    var body: some View {
        ZStack {
            VStack {
                Form {
                    Section(header: Text("Credentials")) {
                        TextField("Username", text: $user)
                            .textContentType(.username)
                            .autocapitalization(.none)
                        SecureField("Password", text: $pass)
                            .textContentType(.password)
                            .autocapitalization(.none)
                    }
                    
                }
                NavigationLink("Forgot your password?", destination: ForgotPassword())
                /*
                Spacer()
                Button("Dont have an account yet?") {
                    UIApplication.shared.open(URL(string:"https://myshipmanager.com/custom/register.php")!)
                }
                .padding()
                */
                Spacer()
            }
            if submitting {
                VStack {
                    Image(systemName: "arrow.up.arrow.down.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150, alignment: .center)
                        .foregroundColor(.brandPrimary)
                        .padding()
                    Text("Signing in...")
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
                        .multilineTextAlignment(.center)
                }
            }
            
        }
        .background(Color(UIColor.systemGray6).ignoresSafeArea())
        .navigationBarItems(trailing: Button("Sign In") {signIn()})
        .navigationBarTitle("Sign In")
    }
    
    func signIn() {
        guard !submitting else { return }
        submitting = true
        
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        
        let req = API.shared.loginRequest(reqUser: user, reqPass: pass)!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                showError(message: "Issue signing in")
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
                                    submitting = false
                                    result = .success
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                        API.shared.saveSession(cookie: sessionCookie, newUser: self.user, newPass: self.pass)
                                    }
                                }
                                return
                            }
                        }
                    }
                }
                
                print("bad credentials")
                showError(message: "Couldn't sign in with those credentials")
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
}

struct SignIn_Previews: PreviewProvider {
    static var previews: some View {
        SignIn()
    }
}
