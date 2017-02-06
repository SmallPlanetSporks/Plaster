//
//  main.swift
//  plaster
//
//  Created by Quinn McHenry on 12/15/15.
//  Copyright © 2015 Quinn McHenry. All rights reserved.
//

import Foundation
import CommandLineKit

// todo - option to change name of outer struct, default Config
// indent options


let cli = CommandLine()
let inputPath = StringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input plist dictionary file")
cli.setOptions(inputPath)


do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

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
}

extension String {
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

let indent = "  "

func process(_ dictionary: NSDictionary) -> String {
    var output = ""
    var depth = 0

    func processLevel(_ dictionary: NSDictionary) {
        
        func indention(_ depth: Int) -> String {
            return ([String](repeating: indent, count: depth)).reduce(""){ $0 + $1 }
        }
        
        func cleanName(_ key: String) -> String {
            if String(key.characters.first!).isNumeric {
                return "_\(key)"
            }
            return key
        }
        
        func valueCode(_ value: AnyObject) -> String {
            if let value = value as? Int {
                return String(value)
            }
            if let value = value as? Double {
                return String(value)
            }
            guard let value = value as? String else { return "" }
            if value.isNumeric {
                return value
            }
            if let colorCode = value.colorCode {
                return colorCode
            }
            let cleaned = value.replacingOccurrences(of: "\"", with: "\\\"")
            return "\"\(cleaned)\""
        }
        
        func processValue(_ value: AnyObject, forKey key: String) {
            output += indention(depth) + "static let \(cleanName(key)) = \(valueCode(value)) \n"
        }
        
        depth += 1
        for (key, value) in dictionary {
            if let value = value as? NSDictionary {
                output += indention(depth) + "struct \(cleanName(key as! String)) {\n"
                processLevel(value)
                output += indention(depth) + "}\n"
            } else {
                processValue(value as AnyObject, forKey: key as! String)
            }
        }
        depth -= 1
    }
    
    output = "import Foundation\nimport UIKit\n\n" +
    "struct Config {\n\n"
    processLevel(dictionary)
    output += "\n}\n"
    return output
}

if let path = inputPath.value, let dictionary = NSDictionary(contentsOfFile: path) {
    let out = process(dictionary)
    print(out)
}
