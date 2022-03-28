//
//  Utils.swift
//  MyShipManager
//
//  Created by Matt on 5/26/21.
//

import UIKit


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
