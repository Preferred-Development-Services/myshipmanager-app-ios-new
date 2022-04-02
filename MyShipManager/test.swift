//
//  test.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 4/1/22.
//

import SwiftUI

struct test: View {
    let defaults = UserDefaults.standard
    @State var sku: String = ""
    @State var estDate:Date = Date()
    

    var body: some View {
        VStack {
            Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
        }
        .onAppear() {
            sku = defaults.object(forKey: "defaultSku") as? String ?? ""
        }
    }


}

struct test_Previews: PreviewProvider {
    static var previews: some View {
        test()
    }
}
