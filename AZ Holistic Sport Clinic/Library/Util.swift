//
//  Util.swift
//  DemoProject
//
//  Created by Krupa-iMac on 24/07/14.
//  Copyright (c) 2014 TheAppGuruz. All rights reserved.
//

import UIKit

class Util: NSObject {
    
    // Convert from NSData to json object
    class func nsdataToJSON(_ data: Data) -> NSDictionary? {
        do {
            let JSON = try JSONSerialization.jsonObject(with: data, options:JSONSerialization.ReadingOptions(rawValue: 0))
            guard let JSONDictionary :NSDictionary = JSON as? NSDictionary else {
                print("Not a Dictionary")
                // put in function
                return nil
            }
            print("JSONDictionary! \(JSONDictionary)")
            
            return JSONDictionary
        }
        catch let JSONError as NSError {
            print("\(JSONError)")
        }
        
        return nil
    }
    
    // Convert from JSON to nsdata
    class func jsonToNSData(_ json: AnyObject) -> Data?{
        do {
            return try JSONSerialization.data(withJSONObject: json, options: JSONSerialization.WritingOptions.prettyPrinted)
        } catch let myJSONError {
            print(myJSONError)
        }
        return nil;
    }
    
    class func resizeImage(_ image: UIImage, newWidth: CGFloat) -> UIImage {
        
        let scale = newWidth / image.size.width
        let newHeight = image.size.height * scale
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        image.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    class func getPath(_ fileName: String) -> String {
        
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentsURL.appendingPathComponent(fileName)
        
        return fileURL.path
    }
    
    class func existFile(_ fileName: NSString) -> Bool {
        let documentsURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fooURL = try! documentsURL.appendingPathComponent(fileName as String)
        let fileExists = FileManager().fileExists(atPath: fooURL.path)
    
        return fileExists
    }
    
    class func deleteFile(_ fileName: NSString) {
        let documentsURL = try! FileManager().url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fooURL = try! documentsURL.appendingPathComponent(fileName as String)
        let fileExists = FileManager().fileExists(atPath: fooURL.path)
        
        if (fileExists)
        {
            do{
               try  FileManager().removeItem(atPath: fooURL.path)
            }catch{
                
            }
        }
    }
    
    class func copyFile(_ fileName: NSString) {
        let dbPath: String = getPath(fileName as String)
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: dbPath){
            do{
                try fileManager.removeItem(atPath: dbPath)
            }catch{
                
            }
        }
        
        if !fileManager.fileExists(atPath: dbPath) {
            
            let documentsURL = Bundle.main.resourceURL
            let fromPath = documentsURL!.appendingPathComponent(fileName as String)
            
            var error : NSError?
            do {
                try fileManager.copyItem(atPath: fromPath.path, toPath: dbPath)
                Swift.debugPrint("Path SQLite: \(dbPath)")
            } catch let error1 as NSError {
                error = error1
            }
            
            
            /*let alert: UIAlertView = UIAlertView()
            if (error != nil) {
                alert.title = "Error Occured"
                alert.message = error?.localizedDescription
            } else {
                alert.title = "Successfully Copy"
                alert.message = "Your database copy successfully"
            }
            alert.delegate = nil
            alert.addButton(withTitle: "OK")
            alert.show()*/
        }
    }
    
    class func invokeAlertMethod(_ strTitle: NSString, strBody: NSString, delegate: AnyObject?, viewController: UIViewController) {
        
        
        if #available(iOS 8, *) {
            //iOS 8+ code here.
            //Create the AlertController
            let actionSheetController: UIAlertController = UIAlertController(title: strTitle as String, message: strBody as String, preferredStyle: .alert)
            
            //Create and add the Cancel action
            let OKAction: UIAlertAction = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { action -> Void in
                //Just dismiss the action sheet
            }
            
            actionSheetController.addAction(OKAction)
            
            viewController.present(actionSheetController, animated: true, completion: nil)
        }
        else {
            let alert: UIAlertView = UIAlertView()
            alert.message = strBody as String
            alert.title = strTitle as String
            alert.delegate = delegate
            alert.addButton(withTitle: NSLocalizedString("OK", comment: "OK"))
            alert.show()
        }
        
        
        
    }
}
