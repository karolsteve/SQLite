//
//  PrepareStatement.swift
//  Kiwoti
//
//  Created by Tchatchouang steve on 17/10/2018.
//  Copyright © 2018 Tchatchouang steve. All rights reserved.
//

import Foundation
import SQLite3

class PrepareStatement {
    
    var statement : OpaquePointer?
    
    init(statement : OpaquePointer?) {
        self.statement = statement
    }
    
    private var errorMessage : String{
        if let error = sqlite3_errmsg(statement){
            return String.init(cString : error)
        }
        else {
            return "Empty error from sqlite"
        }
    }
    
    func bind (args : [Any?]?) throws{
        if let args = args {
            guard Int(sqlite3_bind_parameter_count(statement)) == args.count else {
                fatalError("\(sqlite3_bind_parameter_count(statement)) params expected, \(args.count) passed")
            }
            for (index, any) in args.enumerated(){
                let ind = Int32(index + 1)
                if let bind = any {
                    if let value = bind as? Int{
                        guard sqlite3_bind_int(statement, ind, Int32(value)) == SQLITE_OK else {
                            throw SQLiteError.Bind(message: errorMessage)
                        }
                    }
                    else if let value = bind as? String{
                        guard sqlite3_bind_text(statement, ind, value, -1, nil) == SQLITE_OK else {
                            throw SQLiteError.Bind(message: errorMessage)
                        }
                    }
                    else if let value = bind as? Double{
                        guard sqlite3_bind_double(statement, ind, value) == SQLITE_OK else {
                            throw SQLiteError.Bind(message: errorMessage)
                        }
                    }
                    else if let value = bind as? Bool{
                        guard sqlite3_bind_int(statement, ind, value ? 1 : 0) == SQLITE_OK else {
                            throw SQLiteError.Bind(message: errorMessage)
                        }
                    }
                    else {
                        fatalError("Unsupported type")
                    }
                }
                else {
                    guard sqlite3_bind_null(statement, ind) == SQLITE_OK else {
                        throw SQLiteError.Bind(message: errorMessage)
                    }
                }
            }
        }
    }
    
    deinit {
        sqlite3_finalize(statement)
    }
}
