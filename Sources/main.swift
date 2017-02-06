//
//  main.swift
//  plaster
//
//  Created by Quinn McHenry on 12/15/15.
//  Copyright © 2015 Quinn McHenry. All rights reserved.
//

import Foundation
import CommandLineKit
import FileKit

// todo - option to change name of outer struct, default Config
// indent options


let cli = CommandLine()
let inputPath = StringOption(shortFlag: "i", longFlag: "input", required: true, helpMessage: "Input plist dictionary file")
let outputPath = StringOption(shortFlag: "o", longFlag: "output", required: false, helpMessage: "Output file path, otherwise stdout")
cli.setOptions(inputPath, outputPath)

do {
    try cli.parse()
} catch {
    cli.printUsage(error)
    exit(EX_USAGE)
}

let input = inputPath.value.map { Path($0) }

guard let input = input else {
    print("Error: input path could not be opened")
    exit(-1)
}

let output = outputPath.value.map { Path($0) }
let outputExists = output?.exists ?? false
let outputEmpty = output?.fileSize ?? 0 == 0

let outputNewer: Bool
if let inputModDate = input.modificationDate, let outputModDate = output?.modificationDate {
    outputNewer = outputModDate > inputModDate
} else {
    outputNewer = false
}

// should we perform the conversion?
if !outputEmpty && outputNewer {
    print("Plaster skipping conversion")
    exit(0)
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
    
    if let output = output {
        let outputFile = TextFile(path: output)
        try out |> outputFile
    } else {
        print(out)
    }
    exit(0)
}

print("Error: unable to process file")
exit(-1)
