//
//  Cursor.swift
//  Kiwoti
//
//  Created by Tchatchouang steve on 16/10/2018.
//  Copyright © 2018 Tchatchouang steve. All rights reserved.
//

import Foundation
import SQLite3

class Cursor {
    private var prepareStatement : PrepareStatement?
    private var statement : OpaquePointer?
    
    init(statement : PrepareStatement) {
        self.prepareStatement = statement
        self.statement = statement.statement
    }
    
    func moveToNext() -> Bool{
        guard sqlite3_step(statement) == SQLITE_ROW else {
            return false
        }
        return true
    }
    
    func moveToFirst() -> Bool{
        guard sqlite3_reset(statement) == SQLITE_OK, sqlite3_step(statement) == SQLITE_ROW else {
            return false
        }
        return true
    }
    
    func rowCount()-> Int {
        var count = 0
        defer{
            sqlite3_reset(statement)
        }
        if moveToFirst(){
            count += 1
            while moveToNext(){
                count += 1
            }
        }
        return count
    }
    
    func getInt(columnIndex : Int) -> Int{
        return Int(sqlite3_column_int(statement, Int32(columnIndex)))
    }
    
    func getDouble(columnIndex : Int) -> Double{
        return Double(sqlite3_column_double(statement, Int32(columnIndex)))
    }
    
    func getString(columnIndex : Int) -> String{
        return String(cString : sqlite3_column_text(statement, Int32(columnIndex)))
    }
    
    deinit {
        print("Closing cursor")
    }
}
