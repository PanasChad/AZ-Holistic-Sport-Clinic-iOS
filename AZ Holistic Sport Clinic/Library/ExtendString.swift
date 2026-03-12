//
//  ExtendString.swift
//  myKAPOS
//
//  Created by Μανώλης Γεωργίου on 25/08/16.
//  Copyright © 2016 Μανώλης Γεωργίου. All rights reserved.
//

import Foundation

extension String  {
    func htmlAttributedString() -> NSAttributedString? {
        
        guard let data = self.data(using: String.Encoding.unicode, allowLossyConversion: false) else { return nil }
        
        guard let html = try? NSMutableAttributedString(
            data: data,
            options: [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil) else { return nil }
        
        return html
    }
    
    var md5: String! {
        let str = self.cString(using: String.Encoding.utf8)
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let result = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str!, strLen, result)
        
        let hash = NSMutableString()
        for i in 0..<digestLen {
            hash.appendFormat("%02x", result[i])
        }
        
        result.deallocate(capacity: digestLen)
        
        return String(format: hash as String)
    }
}
