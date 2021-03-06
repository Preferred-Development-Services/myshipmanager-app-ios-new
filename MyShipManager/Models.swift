//
//  Models.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import UIKit
import Foundation
import Combine
import SwiftUI

class TextItem: Identifiable {
    var id: String
    var text: String = ""
    
    init() {
        id = UUID().uuidString
    }
}



class RecognizedContent: ObservableObject {
    @Published var items = [TextItem]()
}


struct Vendor: Decodable {
    let code: Int
    let name: String
    
    init(json: [String: Any]) {
        code = (json["code"] as? Int) ?? 0
        name = (json["name"] as? String) ?? ""
    }
}

func vendors(json: [[String: Any]]) -> [Vendor] {
    return json.map { Vendor(json: $0) }
}

struct Category: Decodable {
    let code: Int
    let name: String
    
    init(json: [String: Any]) {
        code = (json["code"] as? Int) ?? 0
        name = (json["name"] as? String) ?? ""
    }
}

func categories(json: [[String: Any]]) -> [Category] {
    return json.map { Category(json: $0) }
}

struct Status: Decodable {
    let code: Int
    let name: String
    
    init(json: [String: Any]) {
        code = (json["code"] as? Int) ?? 0
        name = (json["name"] as? String) ?? ""
    }
}

func status(json: [[String: Any]]) -> [Status] {
    return json.map { Status(json: $0) }
}




struct ShipmentListingPHP: Decodable {
    let title: String
    let start: String
    let backgroundColor: String
    let url: String
    let status: String
}


struct ShipmentListing: Hashable, Identifiable {
    let id: Int
    let title: String
    let start: Date
    let backgroundColor: UIColor
    let url: String
    let status: String
}

struct BudgetLine: Hashable, Identifiable {
    let id: String
    let category: String
    let budget: String
    let actual: String
    let diff: String
    let diffVal: Double
    let monthStr: String
    
    init(json: [String: Any]) {
        id = UUID().uuidString
        category = (json["category"] as? String) ?? ""
        budget = (json["budget"] as? String) ?? ""
        actual = (json["actual"] as? String) ?? ""
        diff = (json["diff"] as? String) ?? ""
        diffVal = (json["diff"] as? Double) ?? 0
        monthStr = (json["monthStr"] as? String) ?? ""
    }
}

func budgetline(json: [[String: Any]]) -> [BudgetLine] {
    return json.map { BudgetLine(json: $0) }
}

struct BarcodeInfo: Hashable, Decodable {
    let title: String
    let description: String
    let brand: String
    let manufacturer: String
    let cost: String
    let size: String
    let color: String
}

struct BarcodeInfoPHP: Decodable {
    let title: String
    let description: String
    let brand: String
    let manufacturer: String
    let cost: Double
    let size: String
    let color: String
}

struct Variant: Identifiable, Codable {
    var id: UUID
    var color: String = ""
    var size: String = ""
    var qty: Int = 0
    var qtyText: String = ""
    var cost: Double = 0.00
    var costText = ""
    var price: Double = 0.00
    var priceText = ""
    var sku: String = ""
    
    init() {
        self.id = UUID()
    }
}


//extension Variant {
//    static let samples = [
//        Variant(color: "Red", size: "small", qty: 1, cost: 4.50, price: 6.50,sku: "sku10")
//    ]
//}


func convertShipmentListings(_ from: [ShipmentListingPHP]) -> [ShipmentListing] {
    return from.map {
        let id = Int($0.url.split(separator: "=").last ?? "") ?? 0
        let color = UIColor(hex: $0.backgroundColor) ?? UIColor.black
        return ShipmentListing(id: id, title: $0.title, start: phpStringToDate($0.start), backgroundColor: color, url: $0.url, status: $0.status)
    }
}

extension UIApplication {
    static var release: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String? ?? "x.x"
    }
    static var build: String {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as! String? ?? "x"
    }
    static var version: String {
        return "\(release)#\(build)"
    }
}

struct VariantColor: Hashable, Identifiable {
    var name: String = ""
    var id: String { name }
}

struct VariantSize: Hashable, Identifiable {
    var name: String
    var id: String { name }
}

struct MultiSelector<LabelView: View, Selectable: Identifiable & Hashable>: View {
    let label: LabelView
    let options: [Selectable]
    let optionToString: (Selectable) -> String
    var selected: Binding<Set<Selectable>>
    var selectedStr: Binding<String>

    private var formattedSelectedListString: String {
        ListFormatter.localizedString(byJoining: selected.wrappedValue.map { optionToString($0) })
    }

    var body: some View {
        NavigationLink(destination: multiSelectionView()) {
            HStack {
                label
                Spacer()
                Text(formattedSelectedListString)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.trailing)
            }
        }
    }

    private func multiSelectionView() -> some View {
        MultiSelectionView(
            options: options,
            optionToString: optionToString,
            selected: selected,
            selectedStr: selectedStr
        )
    }
}

