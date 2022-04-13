//
//  VarietiesView.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 4/12/22.
//

import SwiftUI

struct VarietiesView: View {
    @Binding var varieties: [Variety]
    var body: some View {
        NavigationView {
            VStack {
                List {
                    ForEach($varieties) { $variety in
                        TextField("Color", text: $variety.color)
                        TextField("Size", text: $variety.size)
  //                      TextField("Cost", text: $variety.cost)
  //                      TextField("Price", text: $variety.price)
                        TextField("SKU", text: $variety.sku)
                    }
                }
                Text("HERE")
            }
            Spacer()
        }
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

//struct VarietiesView_Previews: PreviewProvider {
//    static var previews: some View {
//        VarietiesView(varieties: [])
//    }
//}
