//
//  SQLiteDatabase.swift
//  Kiwoti
//
//  Created by Tchatchouang steve on 16/10/2018.
//  Copyright © 2018 Tchatchouang steve. All rights reserved.
//

import Foundation
import SQLite3

class SQLiteDatabase {
    private var dbPointer : OpaquePointer?
    
    private var errorMessage : String{
        if let error = sqlite3_errmsg(dbPointer){
            return String.init(cString : error)
        }
        else {
            return "Empty error from sqlite"
        }
    }
    
    private init(dbPointer : OpaquePointer?){
        self.dbPointer = dbPointer
    }
    
    static func open(dbPath : String) throws -> SQLiteDatabase{
        var db : OpaquePointer? = nil
        if sqlite3_open(dbPath, &db) == SQLITE_OK {
            print(dbPath)
            return SQLiteDatabase(dbPointer: db)
        }
        else {
            defer {
                if db != nil{
                    sqlite3_close(db)
                }
            }
            if let error = sqlite3_errmsg(db){
                throw SQLiteError.OpenDatabase(message: String(cString: error))
            }
            else {
                throw SQLiteError.OpenDatabase(message: "Failed to open database")
            }
        }
    }
    
    func transaction(block : ()throws->()) throws{
        do{
            try exec(sql: "BEGIN TRANSACTION")
            try block()
            try exec(sql: "COMMIT TRANSACTION")
        }catch let error {
            try exec(sql: "ROLLBACK TRANSACTION")
            print(error)
        }
    }
    
    private func prepare(sql : String) throws -> PrepareStatement{
        var statement : OpaquePointer?
        guard sqlite3_prepare_v2(dbPointer, sql, -1, &statement, nil) == SQLITE_OK else {
            throw SQLiteError.Prepare(message: errorMessage)
        }
        return PrepareStatement(statement: statement)
    }
    
    func exec(sql : String, selectionArgs : [Any?]? = nil) throws {
        let statement = try prepare(sql: sql)
        try statement.bind(args : selectionArgs)
        guard sqlite3_step(statement.statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
    }
    
    func setVersion(version : Int) throws {
        try exec(sql: "PRAGMA user_version = \(version)")
    }
    
    func getVersion() throws -> Int {
        let cursor = try rawQuery(sql: "PRAGMA user_version")
        guard cursor.moveToFirst() else {
            throw SQLiteError.Step(message: errorMessage)
        }
        let version = cursor.getInt(columnIndex: 0)
        return version
    }
    
    deinit {
        sqlite3_close(dbPointer)
    }
}

//MARK : insertion
extension SQLiteDatabase {
    
    func insert(in tableName : String, values : [String: Any?], algo : ConflictAlgo = .NONE) throws -> Int {
        var sql = "INSERT\(algo.rawValue)INTO \(tableName) ("
        var toBind = [Any?]()
        for (index, key) in values.keys.enumerated() {
            sql.append(key)
            toBind.append(values[key]!)
            if index != values.count - 1 {
                sql.append(", ")
            }
            else{
                sql.append(") VALUES (")
            }
        }
        
        for _ in 0..<values.keys.count - 1{
            sql.append("?,")
        }
        sql.append("?);")
        
        let statement = try prepare(sql: sql)
        
        try statement.bind(args: toBind)
        
        guard sqlite3_step(statement.statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        return Int(sqlite3_last_insert_rowid(statement.statement))
    }
}

//MARK : update
extension SQLiteDatabase {
    
    func update(_ tableName : String,values : [String: Any?], whereClause : String?, whereArgs : [Any?]? = nil, algo : ConflictAlgo = .NONE ) throws -> Int {
        var sql = "UPDATE\(algo.rawValue)\(tableName) SET "
        var toBind = [Any?]()
        for (index, key) in values.keys.enumerated() {
            sql.append(key)
            toBind.append(values[key]!)
            if index != values.count - 1 {
                sql.append(" = ?, ")
            }
            else{
                sql.append(" = ?")
            }
        }
        if let whereClause = whereClause {
            sql.append(" WHERE \(whereClause)")
        }
        
        let statement = try prepare(sql: sql)
        
        try statement.bind(args: toBind)
        try statement.bind(args: whereArgs)
        
        guard sqlite3_step(statement.statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        return Int(sqlite3_changes(statement.statement))
    }
}


//MARK - test
extension SQLiteDatabase {
    
    func delete(_ tableName : String, whereClause : String?, whereArgs : [Any?]? = nil) throws -> Int {
        var sql = "DELETE FROM \(tableName)"
        if let whereClause = whereClause {
            sql.append(" WHERE \(whereClause)")
        }
        
        let statement = try prepare(sql: sql)
        try statement.bind(args: whereArgs)
        
        guard sqlite3_step(statement.statement) == SQLITE_DONE else {
            throw SQLiteError.Step(message: errorMessage)
        }
        
        return Int(sqlite3_changes(statement.statement))
    }
}

//:Query
extension SQLiteDatabase {
    func query (distinct : Bool = false, table : String, columns : [String]?, selection : String?, selectionArgs : [Any?]?, groupBy : String? = nil, having : String? = nil, orderBy : String? = nil, limit : String? = nil) throws -> Cursor {
        
        var sql = "SELECT"
        sql.append(distinct ? " DISTINCT " : " ")
        if let columns = columns {
            sql.append(columns.joined(separator: ","))
        }
        else {
            sql.append("*")
        }
        sql.append(" FROM \(table)")
        if let selection = selection {
            sql.append(" WHERE \(selection)")
        }
        if let groupBy = groupBy {
            sql.append(" GROUP BY \(groupBy)")
        }
        if let having = having {
            sql.append(" HAVING \(having)")
        }
        if let orderBy = orderBy {
            sql.append(" ORDER BY \(orderBy)")
        }
        
        if let limit = limit {
            sql.append(" LIMIT \(limit)")
        }
        
        let statement = try prepare(sql: sql)
        try statement.bind(args: selectionArgs)
        
        return Cursor(statement: statement)
    }
}

//MARK: - Raw query
extension SQLiteDatabase {
    func rawQuery (sql : String, selectionArgs : [Any?]? = nil) throws -> Cursor {
        
        let statement = try prepare(sql: sql)
        
        try statement.bind(args: selectionArgs)
        return Cursor(statement: statement)
    }
}
