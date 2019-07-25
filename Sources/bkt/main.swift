//
//  main.swift
//  bkt
//
//  Created by Sam Deane on 18/02/2019.
//  Copyright © 2019 Elegant Chaos Limited. All rights reserved.
//

import Foundation
import CommandShell
import BookishModel

BookishModel.registerLocalizations()

let shell = Shell(commands: [
    MakeCommand()
    ]
)

shell.run()
