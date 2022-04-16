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
 //       defaults.removeObject(forKey: "currentVariants")
        print("VARIANTA")
        print(self.variants)
    }
    
    func save() {
        print("VARIANTS \(self.variants)")
        let jsonData = try! JSONEncoder().encode(self.variants);
 //       let jsonString = String(data: jsonData, encoding: .utf8)!
        defaults.set(jsonData, forKey: "currentVariants")
    }
    
    
}


struct VariantsListView: View {
    @Binding var showVariants: Bool
    @Binding var variantsSaved: Bool
    @StateObject fileprivate var viewModel = VariantsViewModel()


    var body: some View {
        HStack {
            Button("Reset", action: {
                showVariants = false
                variantsSaved = false
                defaults.removeObject(forKey: "currentVariants")
            })
            Spacer()
            Button("Save", action: {
                viewModel.save()
                showVariants = false
                variantsSaved = true
            })
        }.padding()
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
                    .foregroundColor(Color.red)
                HStack {
                  Text("SKU: ")
                    TextField("sku", text: $variant.sku)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Cost: ")
                    TextField("Enter Cost", text: $variant.costText) { editing in
                        if !editing {
                            variant.costText = variant.costText.trimmingCharacters(in: .whitespacesAndNewlines)
                            variant.cost = fabs(Double(variant.costText) ?? 0)
                            variant.costText = String(format: "%.2f", variant.cost)
                            variant.cost = Double(variant.costText) ?? 0
                        }
                    } onCommit: {}
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                    Text("Retail Price: ")
                    TextField("Enter Retail Price", text: $variant.priceText) { editing in
                        if !editing {
                            variant.priceText = variant.priceText.trimmingCharacters(in: .whitespacesAndNewlines)
                            variant.price = fabs(Double(variant.priceText) ?? 0)
                            variant.priceText = String(format: "%.2f", variant.price)
                            variant.price = Double(variant.priceText) ?? 0
                        }
                    } onCommit: {}
                        .keyboardType(.decimalPad)
                        .textFieldStyle(.roundedBorder)
                }
                HStack {
                  Text("Quantity: ")
                    TextField("Enter Quantity", text: $variant.qtyText)
                    .keyboardType(.numberPad)
                    .textFieldStyle(.roundedBorder)
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
