//
//  StringExtensions.swift
//  plaster
//
//  Created by Quinn McHenry on 2/6/17.
//
//

import Foundation

extension String {
    var colorCode: String? {
        var (r,g,b,a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 1.0)
        if hasPrefix("#") {
            let substring = self.substring(from: characters.index(startIndex, offsetBy: 1))
            var hexNumber:UInt32 = 0;
            let _ = Scanner(string: substring).scanHexInt32(&hexNumber)
            switch substring.characters.count {
            case 8:
                r = CGFloat((hexNumber & 0xFF000000) >> 24) / 255.0
                g = CGFloat((hexNumber & 0x00FF0000) >> 16) / 255.0
                b = CGFloat((hexNumber & 0x0000FF00) >> 8) / 255.0
                a = CGFloat(hexNumber & 0x000000FF) / 255.0
            case 6:
                r = CGFloat((hexNumber & 0xFF0000) >> 16) / 255.0
                g = CGFloat((hexNumber & 0x00FF00) >> 8) / 255.0
                b = CGFloat(hexNumber & 0x0000FF) / 255.0
            default: return nil
            }
            return "UIColor(red: \(r), green:\(g), blue:\(b), alpha:\(a))"
        }
        return nil
    }

    var isNumeric: Bool {
        return Double(self) != nil
    }
    var isInteger: Bool {
        return Int(self) != nil
    }
    var isColor: Bool {
        return colorCode != nil
    }
}
