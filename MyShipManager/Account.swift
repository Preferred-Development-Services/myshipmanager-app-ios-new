//
//  Account.swift
//  MyShipManager
//
//  Created by Matt on 4/24/21.
//

import SwiftUI

struct Account: View {
    @State var username = ""
    var body: some View {
        VStack {
        Text(username)
            .foregroundColor(.brandPrimary)
            .font(.title2)
            .padding()
        Button("Logout") { logout() }
            .padding()
            .background(Color.brandBlack)
            .accentColor(.white)
            .navigationTitle("Account")
        Spacer()
        Text("Version 2.1#26")
            .font(.footnote)
            .foregroundColor(Color(UIColor.lightGray))
            .padding()
            
        }
        .onAppear() {
            username = API.shared.displayUsername()
        }
    }
    
    func logout() {
        let req = API.shared.logoutRequest()!
        let task = URLSession.shared.dataTask(with: req) { _, _, _ in }
        task.resume()
    }
}

struct Account_Previews: PreviewProvider {
    static var previews: some View {
        Account()
    }
}
