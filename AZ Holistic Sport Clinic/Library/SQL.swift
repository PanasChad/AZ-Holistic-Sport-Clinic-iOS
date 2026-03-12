//
//  SQL.swift
//  myKAPOS
//
//  Created by Μανώλης Γεωργίου on 18/08/16.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//

import Foundation

class SQLite  {
    let database : FMDatabase!
    
    init() {
        // perform some initialization here
        let fileURL = try! FileManager.default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
            .appendingPathComponent("test.sqlite")
        
        database = FMDatabase(path: fileURL.path)
        
        if !database.open() {
            print("Unable to open database")
            return
        }
        
        do {
            try database.executeUpdate("create table test(x text, y text, z text)", values: nil)
            try database.executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["a", "b", "c"])
            try database.executeUpdate("insert into test (x, y, z) values (?, ?, ?)", values: ["e", "f", "g"])
            
            let rs = try database.executeQuery("select x, y, z from test", values: nil)
            while rs.next() {
                let x = rs.string(forColumn: "x")
                let y = rs.string(forColumn: "y")
                let z = rs.string(forColumn: "z")
                print("x = \(x); y = \(y); z = \(z)")
            }
        } catch let error as NSError {
            print("failed: \(error.localizedDescription)")
        }
        
        database.close()
    }
    
    func copyDatabase() -> Bool
    {
        var error: NSError?
        
        //let copySuccessful = NSFileManager.defaultManager().copyItemAtPath(backupDbPath, toPath:dbFilePath, error: &error)
        
        //if !copySuccessful {
        //    print("copy failed: \(error?.localizedDescription)")
        //    return false
        //}
        
        return true
    }
}
