//
//  Downloader.swift
//  myKAPOS
//
//  Created by Μανώλης Γεωργίου on 02/12/2016.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//

import Foundation

class Downloader {
    class func load(url: URL, to localUrl: URL, completion: @escaping (_ success: Bool) -> ()) {
        let sessionConfig = URLSessionConfiguration.default
        let session = URLSession(configuration: sessionConfig)
        let request = try! URLRequest(url: url)
        
        let task = session.downloadTask(with: request) { (tempLocalUrl, response, error) in
            if let tempLocalUrl = tempLocalUrl, error == nil {
                // Success
                if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                    print("Success: \(statusCode)")
                    
                    if (Int(statusCode) != 200){
                        completion(false)
                        return
                    }
                }
                
                do {
                    try FileManager.default.copyItem(at: tempLocalUrl, to: localUrl)
                    completion(true)
                } catch (let writeError) {
                    print("error writing file \(localUrl) : \(writeError)")
                    completion(false)
                }
                
            } else {
                print("Failure: %@", error?.localizedDescription);
                completion(false)
            }
        }
        
        task.resume()
    }
}
