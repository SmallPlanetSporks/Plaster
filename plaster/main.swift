//
//  main.swift
//  plaster
//
//  Created by Quinn McHenry on 12/15/15.
//  Copyright © 2015 Quinn McHenry. All rights reserved.
//

import Foundation

// todo - option to change name of outer struct, default Config
// indent options


let cli = CommandLine()
let inputPath = StringOption(shortFlag: "i", longFlag: "input", required: true,
    helpMessage: "Input plist dictionary file")
//let output = EnumOption<Operation>(shortFlag: "o", longFlag: "output", required: false,
//    helpMessage: "File operation - c for create, x for extract, l for list, or v for verify.")
cli.setOptions(inputPath)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let dictionary = NSDictionary(contentsOfFile: inputPath.value!)

extension String {
    var colorCode: String? {
        var (r,g,b,a): (CGFloat, CGFloat, CGFloat, CGFloat) = (0.0, 0.0, 0.0, 1.0)
        if hasPrefix("#") {
            let substring = substringFromIndex(startIndex.advancedBy(1))
            var hexNumber:UInt32 = 0;
            let _ = NSScanner(string: substring).scanHexInt(&hexNumber)
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

func process(dictionary: NSDictionary) -> String {
    var output = ""
    var depth = 0

    func processLevel(dictionary: NSDictionary) {
        depth += 1
        func indention(depth: Int) -> String {
            return ([String](count:depth, repeatedValue: indent)).reduce(""){ $0 + $1 }
        }
        func cleanName(key: String) -> String {
            if String(key.characters.first!).isNumeric {
                return "_\(key)"
            }
            return key
        }
        func valueCode(value: AnyObject) -> String {
            if let value = value as? Int {
                return String(value)
            }
            if let value = value as? Double {
                return String(value)
            }
            guard let value = value as? String else { assertionFailure("not a string"); return "" }
            if value.isNumeric {
                return value
            }
            if let colorCode = value.colorCode {
                return colorCode
            }
            let cleaned = value.stringByReplacingOccurrencesOfString("\"", withString: "\\\"")
            return "\"\(cleaned)\""
        }
        func processValue(value: AnyObject, forKey key: String) {
            output += indention(depth) + "static let \(cleanName(key)) = \(valueCode(value)) \n"
        }
        for (key, value) in dictionary {
            if let value = value as? NSDictionary {
                output += indention(depth) + "struct \(cleanName(key as! String)) {\n"
                processLevel(value)
                output += indention(depth) + "}\n"
            } else {
                processValue(value, forKey: key as! String)
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

let out = process(dictionary!)

print(out)
