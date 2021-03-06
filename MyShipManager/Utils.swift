//
//  Utils.swift
//  MyShipManager
//
//  Created by Matt on 5/26/21.
//

import UIKit
import SwiftUI


func phpDateFormatter() -> DateFormatter {
    let df = DateFormatter()
    df.locale = Locale(identifier: "en_US_POSIX")
    df.dateFormat = "yyyy-MM-dd"
    return df
}

func phpStringToDate(_ s: String) -> Date {
    return phpDateFormatter().date(from: s) ?? Date()
}

func dateToPHPString(_ d: Date) -> String {
    return phpDateFormatter().string(from: d)
}

func dateToHuman(_ d: Date) -> String {
    let df = DateFormatter()
    df.dateStyle = .medium
    return df.string(from: d)
}

func randomString(of length: Int) -> String {
    let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
    var s = ""
    for _ in 0 ..< length {
        s.append(letters.randomElement()!)
    }
    return s
}

func ArraytoJson(arrayObject: [Any]) -> String? {
    do {
        let jsonData: Data = try JSONSerialization.data(withJSONObject: arrayObject, options: [])
        if let jsonString = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
            return jsonString as String
        }
    } catch let error as NSError {
        print ("Array convertIntoJson - \(error.description)")
    }
    return nil
}

// HWS below:
extension UIColor {
    convenience init?(hex: String, alpha: CGFloat = 1) {
        var chars = Array(hex.hasPrefix("#") ? hex.dropFirst() : hex[...])
        switch chars.count {
        case 3: chars = chars.flatMap { [$0, $0] }
        case 6: break
        default: return nil
        }
        self.init(red: .init(strtoul(String(chars[0...1]), nil, 16)) / 255,
                green: .init(strtoul(String(chars[2...3]), nil, 16)) / 255,
                 blue: .init(strtoul(String(chars[4...5]), nil, 16)) / 255,
                alpha: alpha)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

