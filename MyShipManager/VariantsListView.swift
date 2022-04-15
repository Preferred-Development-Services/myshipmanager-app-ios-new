//
//  VariantsListView.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 4/14/22.
//

import SwiftUI

private class VariantsViewModel: ObservableObject{

    @Published var variants: [Variant]
    
    init() {
        let savedVariants = defaults.object(forKey: "currentVariants") as? Data
        let decoder = JSONDecoder()
        self.variants = try! decoder.decode([Variant].self, from: savedVariants!)
        defaults.removeObject(forKey: "currentVariants")
        print("VARIANTA")
        print(self.variants)
    }
    func save() {
        print("VARIANTS \(self.variants)")
        let jsonData = try! JSONEncoder().encode(self.variants);
        let jsonString = String(data: jsonData, encoding: .utf8)!
        print("JSONDATA \(jsonString)")
        defaults.set(jsonString, forKey: "currentVariants")
        print(defaults.object(forKey: "currentVariants"))
    }
}


struct VariantsListView: View {
    @Binding var showVariants: Bool
    @StateObject fileprivate var viewModel = VariantsViewModel()


    var body: some View {
        Button("Save", action: {
            viewModel.save()
            showVariants = false
        })
        List($viewModel.variants) { $variant in
            EditableVariantRowView(variant: $variant)
        }
    }
}



private struct EditableVariantRowView: View {
    @Binding var variant: Variant
    
    var body: some View {
        VStack {
            Group {
                Text("\(variant.color) / \(variant.size)")
                HStack {
                  Text("SKU: ")
                  TextField("sku", text: $variant.sku)
                }
                HStack {
                  Text("Cost: ")
                      TextField("Enter Cost", text: $variant.costText)
                      .keyboardType(.decimalPad)
                }
                HStack {
                  Text("Retail Price: ")
                    TextField("Enter Retail Price", text: $variant.priceText)
                    .keyboardType(.decimalPad)
                }
                HStack {
                  Text("Quantity: ")
                    TextField("Enter Quantity", text: $variant.qtyText)
                    .keyboardType(.numberPad)
                }

            }
        }
    }
}

//struct VariantsListView_Previews: PreviewProvider {
//    static var previews: some View {
//        VariantsListView($showVariants)
//  }
//}
