//
//  Welcome.swift
//  MyShipManager
//
//  Created by Matt on 4/24/21.
//

import SwiftUI

struct Welcome: View {
    var body: some View {
        NavigationView {
            VStack {
                Image("LogoFull")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .padding(.horizontal)
                NavigationLink(destination: SignIn()) {
                    Text("Sign In")
                        .padding()
                        .background(Color.brandBlack)
                        .accentColor(.white)
                    
                }
                Spacer()
            }
        }
    }
}

struct Welcome_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            Welcome()
        }
    }
}
