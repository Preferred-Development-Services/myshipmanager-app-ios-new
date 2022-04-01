//
//  Models.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import UIKit


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




struct ShipmentListingPHP: Decodable {
    let title: String
    let start: String
    let backgroundColor: String
    let url: String
}


struct ShipmentListing: Hashable, Identifiable {
    let id: Int
    let title: String
    let start: Date
    let backgroundColor: UIColor
    let url: String
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





func convertShipmentListings(_ from: [ShipmentListingPHP]) -> [ShipmentListing] {
    return from.map {
        let id = Int($0.url.split(separator: "=").last ?? "") ?? 0
        let color = UIColor(hex: $0.backgroundColor) ?? UIColor.black
        return ShipmentListing(id: id, title: $0.title, start: phpStringToDate($0.start), backgroundColor: color, url: $0.url)
    }
}


