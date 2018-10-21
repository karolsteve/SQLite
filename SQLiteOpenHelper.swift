//
//  SQLiteOpenHelper.swift
//  Kiwoti
//
//  Created by Tchatchouang steve on 16/10/2018.
//  Copyright © 2018 Tchatchouang steve. All rights reserved.
//

import Foundation

class SQLiteOpenHelper {
    private static let documentDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
    
    private var database : SQLiteDatabase?
    private var name : String
    private var newVersion : Int
    
    init(name : String, version :Int) {
        self.name = name
        self.newVersion = version
    }
    
    func getDatabase() -> SQLiteDatabase{
        if database != nil {
            return database!
        }
        let path = URL(fileURLWithPath: SQLiteOpenHelper.documentDir).appendingPathComponent(name).path
        database = try! SQLiteDatabase.open(dbPath:  path)
        let version = try! database!.getVersion()
        if(version != newVersion){
            if version == 0{
                onCreate(database!)
            }
            else {
                if version > newVersion{
                    onDowngrade(database!, version, newVersion)
                }
                else {
                    onUpgrade(database!, version, newVersion)
                }
            }
            try! database!.setVersion(version: newVersion)
        }
        onOpen(database!)
        return database!
    }
    
    func onOpen(_ database : SQLiteDatabase){}
    
    func onCreate(_ database : SQLiteDatabase){}
    
    func onUpgrade(_ database : SQLiteDatabase, _ oldVersion : Int, _ newVersion : Int){}
    
    func onDowngrade(_ database : SQLiteDatabase, _ oldVersion : Int, _ newVersion : Int){
        fatalError("Downgrade not supported")
    }
}
