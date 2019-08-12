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

class FilterCommand: Command {
    override var description: Command.Description {
        return Description(
            name: "filter",
            help: "Filter a command file",
            usage: ["<file> <event> [--after=<after>]"],
            arguments: [
                "file": "The file to filter",
                "event": "The event type to keep"
            ],
            options: [
                "after": "Only keep events after this date"
            ]
        )
    }

    fileprivate func filter(file url: URL, shell: Shell) -> Result {
        let name = url.deletingPathExtension().lastPathComponent
        shell.log("Filtering '\(name)'.")

        let filter = shell.arguments.argument("event")
        
        let after: Date?
        if let afterString = shell.arguments.option("after") {
            let formatter = ISO8601DateFormatter()
            after = formatter.date(from:afterString)
        } else {
            after = nil
        }
        
        Localization.registerLocalizationBundle(Bundle.main)
        let outputURL = url.deletingLastPathComponent().appendingPathComponent("Filtered \(name).json")

        let jsonData = try! Data(contentsOf: url)
        let decoder = JSONDecoder()
        do {
            var filtered: [ActionItemSpec] = []
            let actions = try decoder.decode([ActionItemSpec].self, from: jsonData)
            for action in actions {
                let date = Date(timeIntervalSinceReferenceDate: action.time)
                print(date)
                if action.action.action == filter {
                    if after == nil || after! <= date {
                        filtered.append(action)
                    }
                }
            }
            
            let file = ActionFile(actions: filtered)
            let encoder = JSONEncoder()
            encoder.outputFormatting = .prettyPrinted
            let data = try encoder.encode(file)
            try data.write(to: outputURL)
        } catch DecodingError.dataCorrupted(let context) {
            print(context.detailedDescription(for: jsonData))
            
        } catch {
            print(error)
        }
        
        return .ok
    }

    override func run(shell: Shell) throws -> Result {
        let file = shell.arguments.argument("file")
        let url = URL(fileURLWithPath: file)
        if FileManager.default.fileExists(atPath: url.path) {
            return filter(file: url, shell: shell)
        }
        return .badArguments
    }
}
