//
//  ModelManager.swift
//  DataBaseDemo
//
//  Created by Krupa-iMac on 05/08/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

let sharedInstance = ModelManager()

class ModelManager: NSObject {
    
    var dbQueue: FMDatabaseQueue? = nil
    private let initLock = NSLock()
    
    class func getInstance() -> ModelManager {
        sharedInstance.ensureQueue()
        return sharedInstance
    }
    
    // Properly close the current database queue and clear it.
    func close() {
        dbQueue?.close()
        dbQueue = nil
        print("✅ Database queue closed and cleared.")
    }
    
    // Static convenience for call-sites (e.g., logout)
    class func reset() {
        sharedInstance.close()
    }
    
    // MARK: - Private helpers
    
    private func ensureQueue() {
        if dbQueue == nil {
            initLock.lock()
            defer { initLock.unlock() }
            if dbQueue == nil {
                let path = Util.getPath("az.sqlite")
                dbQueue = FMDatabaseQueue(path: path)
                print("✅ Database queue initialized at: \(path)")
            }
        }
    }
    
    // MARK: - SQL helpers (parameterized and safe)
    
    func insert(_ tableName: String, valuesDictionary: NSDictionary) -> Bool {
        guard valuesDictionary.allKeys.count > 0 else { return false }
        let fieldNames = valuesDictionary.allKeys.compactMap { $0 as? String }
        guard !fieldNames.isEmpty else { return false }
        
        let columns = fieldNames.map { "`\($0)`" }.joined(separator: ",")
        let placeholders = Array(repeating: "?", count: fieldNames.count).joined(separator: ",")
        let sql = "INSERT INTO `\(tableName)` (\(columns)) VALUES (\(placeholders))"
        
        let args: [Any] = fieldNames.map { key in
            if let v = valuesDictionary.object(forKey: key) {
                if let s = v as? String { return s }
                return "\(v)"
            }
            return NSNull()
        }
        
        var ok = false
        ensureQueue()
        dbQueue?.inDatabase { db in
            ok = db.executeUpdate(sql, withArgumentsIn: args)
            if !ok { print("❌ INSERT failed: \(db.lastErrorMessage())") }
        }
        return ok
    }
    
    func updateAll(_ tableName: String, valuesDictionary: NSDictionary) -> Bool {
        guard valuesDictionary.allKeys.count > 0 else { return false }
        let fieldNames = valuesDictionary.allKeys.compactMap { $0 as? String }
        guard !fieldNames.isEmpty else { return false }
        
        let sets = fieldNames.map { "`\($0)`=?" }.joined(separator: ",")
        let sql = "UPDATE `\(tableName)` SET \(sets)"
        
        let args: [Any] = fieldNames.map { key in
            if let v = valuesDictionary.object(forKey: key) {
                if let s = v as? String { return s }
                return "\(v)"
            }
            return NSNull()
        }
        
        var ok = false
        ensureQueue()
        dbQueue?.inDatabase { db in
            ok = db.executeUpdate(sql, withArgumentsIn: args)
            if !ok { print("❌ UPDATE ALL failed: \(db.lastErrorMessage())") }
        }
        return ok
    }
    
    func update(_ tableName: String, valuesDictionary: NSDictionary, whereDictionary: NSDictionary) -> Bool {
        guard valuesDictionary.allKeys.count > 0, whereDictionary.allKeys.count > 0 else { return false }
        let setKeys = valuesDictionary.allKeys.compactMap { $0 as? String }
        let whereKeys = whereDictionary.allKeys.compactMap { $0 as? String }
        guard !setKeys.isEmpty, !whereKeys.isEmpty else { return false }
        
        let sets = setKeys.map { "`\($0)`=?" }.joined(separator: ",")
        let wheres = whereKeys.map { "`\($0)`=?" }.joined(separator: " AND ")
        let sql = "UPDATE `\(tableName)` SET \(sets) WHERE \(wheres)"
        
        var args: [Any] = []
        for key in setKeys {
            if let v = valuesDictionary.object(forKey: key) {
                if let s = v as? String { args.append(s) } else { args.append("\(v)") }
            } else { args.append(NSNull()) }
        }
        for key in whereKeys {
            if let v = whereDictionary.object(forKey: key) {
                if let s = v as? String { args.append(s) } else { args.append("\(v)") }
            } else { args.append(NSNull()) }
        }
        
        var ok = false
        ensureQueue()
        dbQueue?.inDatabase { db in
            ok = db.executeUpdate(sql, withArgumentsIn: args)
            if !ok { print("❌ UPDATE failed: \(db.lastErrorMessage())") }
        }
        return ok
    }
    
    func deleteAll(_ tableName: String) -> Bool {
        let sql = "DELETE FROM `\(tableName)`"
        var ok = false
        ensureQueue()
        dbQueue?.inDatabase { db in
            ok = db.executeUpdate(sql, withArgumentsIn: [])
            if !ok { print("❌ DELETE ALL failed: \(db.lastErrorMessage())") }
        }
        return ok
    }
    
    func delete(_ tableName: String, whereDictionary: NSDictionary) -> Bool {
        let whereKeys = whereDictionary.allKeys.compactMap { $0 as? String }
        guard !whereKeys.isEmpty else { return false }
        
        let wheres = whereKeys.map { "`\($0)`=?" }.joined(separator: " AND ")
        let sql = "DELETE FROM `\(tableName)` WHERE \(wheres)"
        let args: [Any] = whereKeys.map { key in
            if let v = whereDictionary.object(forKey: key) {
                if let s = v as? String { return s }
                return "\(v)"
            }
            return NSNull()
        }
        
        var ok = false
        ensureQueue()
        dbQueue?.inDatabase { db in
            ok = db.executeUpdate(sql, withArgumentsIn: args)
            if !ok { print("❌ DELETE failed: \(db.lastErrorMessage())") }
        }
        return ok
    }
    
    func query(_ stringQuery: String) -> Bool {
        var isSuccess = false
        ensureQueue()
        dbQueue?.inDatabase { db in
            isSuccess = db.executeUpdate(stringQuery, withArgumentsIn: [])
            if !isSuccess { print("❌ QUERY failed: \(db.lastErrorMessage())") }
        }
        return isSuccess
    }
    
    func q(_ stringQuery: String) -> NSMutableArray {
        let dataSet: NSMutableArray = NSMutableArray()
        ensureQueue()
        dbQueue?.inDatabase { db in
            if let resultSet = db.executeQuery(stringQuery, withArgumentsIn: []) {
                while resultSet.next() {
                    if let dict = resultSet.resultDictionary {
                        dataSet.add(dict)
                    }
                }
                resultSet.close()
            } else {
                print("❌ SELECT failed: \(db.lastErrorMessage())")
            }
        }
        return dataSet
    }
    
    func line(_ stringQuery: String) -> NSDictionary {
        var sQuery = stringQuery
        if sQuery.lowercased().range(of: "limit") == nil {
            sQuery += " LIMIT 1"
        }
        var dataSet: NSDictionary = NSDictionary()
        ensureQueue()
        dbQueue?.inDatabase { db in
            if let resultSet = db.executeQuery(sQuery, withArgumentsIn: []) {
                if resultSet.next() {
                    if let dict = resultSet.resultDictionary {
                        dataSet = dict as NSDictionary
                    }
                }
                resultSet.close()
            } else {
                print("❌ SELECT line failed: \(db.lastErrorMessage())")
            }
        }
        return dataSet
    }
}

