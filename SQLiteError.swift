//
//  SQLiteError.swift
//  Kiwoti
//
//  Created by Tchatchouang steve on 16/10/2018.
//  Copyright © 2018 Tchatchouang steve. All rights reserved.
//

import Foundation

enum SQLiteError : Error {
    case OpenDatabase(message : String)
    case Prepare(message : String)
    case Step(message : String)
    case Bind(message : String)
}
