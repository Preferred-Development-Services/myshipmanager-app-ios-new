//
//  API.swift
//  MyShipManager
//
//  Created by Matt on 4/24/21.
//

import Foundation
import Security

class API: ObservableObject {
    static let shared = API()
    
    private let serverKeychain = "myshipmanager.com"
    private let base = "https://myshipmanager.com/custom/"
    private let udKeyCookie = "session_cookie"
    
    private var user = ""
    private var pass = ""
    private var sessionCookie = ""
    
    @Published var isAuthed: Bool
    
    init() {
        sessionCookie = UserDefaults.standard.string(forKey: udKeyCookie) ?? ""
        isAuthed = sessionCookie != ""
        
        if isAuthed {
            readKeychain()
        }
        
        print("API.sessionCookie: \(sessionCookie)")
        print("API.isAuthed: \(isAuthed)")
        print("user: \(user)")
        print("pass == '': \(pass == "")")
    }
    
    func saveSession(cookie: String, newUser: String? = nil, newPass: String? = nil) {
        sessionCookie = cookie
        isAuthed = true
        
        if (newUser != nil) && (newPass != nil) {
            user = newUser!
            pass = newPass!
            
            if (user == "") || (pass == "") {
                print("session in invalid state with cookie but without credentials")
            }
        }
        
        UserDefaults.standard.set(sessionCookie, forKey: udKeyCookie)
        
        writeKeychain()
    }
    
    func clearSession() {
        clearKeychain()
        
        UserDefaults.standard.removeObject(forKey: udKeyCookie)
        
        sessionCookie = ""
        user = ""
        pass = ""
        isAuthed = false
    }
    
    func readKeychain() {
        let query = [
          kSecClass: kSecClassInternetPassword,
          kSecAttrServer: serverKeychain,
          kSecReturnAttributes: true,
          kSecReturnData: true
        ] as CFDictionary
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query, &result)
        print("read status: \(status)")
        
        if let dict = result as? NSDictionary {
            if let passData = dict[kSecValueData] as? Data {
                pass = String(data: passData, encoding: .utf8) ?? ""
            }
                
            user = (dict[kSecAttrAccount] as? String) ?? ""
            
            print("dict parsed")
            print("user: \(user)")
            print("pass: \(pass)")
        }
    }
    
    func writeKeychain() {
        let query = [kSecClass: kSecClassInternetPassword,
                     kSecAttrServer: serverKeychain,
                     kSecAttrAccount: user,
                     kSecValueData: pass.data(using: .utf8)!] as CFDictionary
        let status = SecItemAdd(query, nil)
        if status != errSecSuccess {
            let s2 = SecItemUpdate(query, [kSecValueData: pass.data(using: .utf8)!] as CFDictionary)
            if s2 != errSecSuccess {
                print("couldn't add or update!")
            } else {
                print("updated session!")
            }
        }
    }
    
    func clearKeychain() {
        let query = [kSecClass: kSecClassInternetPassword,
                     kSecAttrServer: serverKeychain,
                     kSecAttrAccount: user] as CFDictionary
        let status = SecItemDelete(query)
        if status != errSecSuccess {
            print("SecItemDelete failed: \(status)")
        }
    }
    
    func displayUsername() -> String {
        return user
    }
    
    func logoutRequest() -> URLRequest? {
        let url = URL(string: "https://myshipmanager.com/custom/logout.php")!
        
        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        
        clearSession()

        return req
    }
    
    func sessionRefreshRequest() -> URLRequest? {
        let urlUser = user.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlPass = pass.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let proc = "include/m-session-valid.php?email=\(urlUser)&password=\(urlPass)"
        return API.shared.get(proc: proc)
    }
    
    func loginRequest(reqUser: String? = nil, reqPass: String? = nil) -> URLRequest? {
            let urlUser = (reqUser ?? user).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let urlPass = (reqPass ?? pass).addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
            let proc = "include/m-login.php?email=\(urlUser)&password=\(urlPass)&remember=0&app=1"
                     
        
            guard let url = URL(string: base + proc) else { return nil }
            
            var req = URLRequest(url: url)
            req.httpMethod = "GET"
            req.setValue("application/json", forHTTPHeaderField: "Accept")
            req.setValue("", forHTTPHeaderField: "Cookie")
            
            return req
        }

    func get(proc: String) -> URLRequest? {
        let urlUser = user.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
       let urlPass = pass.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: base + proc + "?email=\(urlUser)&password=\(urlPass)&remember=0&app=1") else { return nil }
//        guard let url = URL(string: base + proc) else { return nil }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if sessionCookie != "" {
            req.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        }
        
        return req
    }
    
    func getAppendAuth(proc: String) -> URLRequest? {
        let urlUser = user.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlPass = pass.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        guard let url = URL(string: base + proc + "&email=\(urlUser)&password=\(urlPass)&remember=0&app=1") else { return nil }
 //       print("FINAL URL - \(url)")
//        guard let url = URL(string: base + proc) else { return nil }

        var req = URLRequest(url: url)
        req.httpMethod = "GET"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if sessionCookie != "" {
            req.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        }
        
        return req
    }
    
    func post(proc: String, bodyStr: String) -> URLRequest? {
        let urlUser = user.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        let urlPass = pass.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
        
        
        guard let url = URL(string: base + proc + "?email=\(urlUser)&password=\(urlPass)&remember=0&app=1") else { return nil }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        if sessionCookie != "" {
            req.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        }
        
        if bodyStr != "" {
            req.httpBody = bodyStr.data(using: .utf8)
        }
        
        return req
    }
    
    func postNoAuth(proc: String, bodyStr: String) -> URLRequest? {

        guard let url = URL(string: base + proc) else { return nil }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "Accept")
        req.setValue("application/x-www-form-urlencoded; charset=UTF-8", forHTTPHeaderField: "Content-Type")
        
        if sessionCookie != "" {
            req.setValue(sessionCookie, forHTTPHeaderField: "Cookie")
        }
        
        if bodyStr != "" {
            req.httpBody = bodyStr.data(using: .utf8)
        }
        
        return req
    }
}
