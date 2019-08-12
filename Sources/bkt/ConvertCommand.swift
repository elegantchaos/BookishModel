// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
//  Created by Developer on 12/08/2019.
//  All code (c) 2019 - present day, Elegant Chaos Limited.
// -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-

import Foundation
import Actions
import BookishModel
import CoreData
import CommandShell
import Localization

class ConvertCommand: Command {
    override var description: Command.Description {
        return Description(
            name: "convert",
            help: "Convert an old config file",
            usage: ["<names>"],
            arguments: ["names": "Comma-separated list of names of the files to convert"]
        )
    }

    fileprivate func convert(name: String, shell: Shell) {
        shell.log("Converting '\(name)'.")

        let rootURL = URL(fileURLWithPath: #file).deletingLastPathComponent()
        let jsonURL = rootURL.appendingPathComponent("Build \(name).json")
        
        Localization.registerLocalizationBundle(Bundle.main)
        
        let resourceURL = rootURL.appendingPathComponent("../../Tests/BookishModelTests/Resources/")
        let outputDirectory = rootURL.appendingPathComponent("../BookishModel/Resources/").appendingPathComponent(name)
        try? FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)
        let outputURL = rootURL.appendingPathComponent("Converted \(name).json")

        let jsonData = try! Data(contentsOf: jsonURL)
        let decoder = JSONDecoder()
        do {
            var converted: [NuItemSpec] = []
            let oldActions = try decoder.decode(ActionFile.self, from: jsonData)
            for oldAction in oldActions.actions {
                let time = Date().timeIntervalSinceReferenceDate
                var info: [String:AnyCodable] = [:]
                if let params = oldAction.params {
                    for (key, value) in params {
                        info[key] = AnyCodable(value)
                    }
                }
                if let selection = oldAction.people {
                    info["selectionIds"] = AnyCodable(selection)
                } else if let selection = oldAction.books {
                    info["selectionIds"] = AnyCodable(selection)
                }
                let action = NuActionSpec(action: oldAction.action, info: info)
                converted.append(NuItemSpec(time: time, action: action))
            }
            
            let file = NuActionFile(actions: converted)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(file)
            try data.write(to: outputURL)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.detailedDescription(for: jsonData))
            
        } catch {
            print(error)
        }
    }

    override func run(shell: Shell) throws -> Result {
        let names = shell.arguments.argument("names").split(separator: ",")
        for name in names {
            convert(name: String(name), shell: shell)
        }
        return .running
    }
}
