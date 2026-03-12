//
//  PDFViewController.swift
//  AZ Holistic Sport Clinic
//
//  Created by Manolis Georgiou on 31/08/2020.
//  Copyright © 2020 Manolis Georgiou. All rights reserved.
//

import UIKit
import PDFKit

class PDFViewController: UIViewController {
    
    var pdfView = PDFView()
    
    var pdfURL: URL!
    var pdfTemporaryLocation: URL!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(frame: CGRect(x: self.view.frame.width-130, y: 10, width: 120, height: 34))
        
        button.setTitle(NSLocalizedString("CLOSE",comment: "CLOSE"), for: .normal)
        button.setTitleColor(UIColor().convertHexStringToColor(GlobalVar.blueColor), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular )
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(closeWindow), for: .touchUpInside)
        
        let buttonShare = UIButton(frame: CGRect(x:10, y: 10, width: 240, height: 34))
        
        buttonShare.setTitle(NSLocalizedString("SHARE",comment: "SHARE"), for: .normal)
        buttonShare.setTitleColor(UIColor().convertHexStringToColor(GlobalVar.blueColor), for: .normal)
        buttonShare.titleLabel?.font = .systemFont(ofSize: 14, weight: .regular )
        buttonShare.contentHorizontalAlignment = .left
        buttonShare.addTarget(self, action: #selector(loadPDFAndShare), for: .touchUpInside)
        
        view.addSubview(pdfView)
        view.addSubview(buttonShare)
        view.addSubview(button)
        
        if let document = PDFDocument(url: pdfURL) {
            pdfView.document = document
        }
    }
    
    @objc func loadPDFAndShare(sender: UIButton!) {

        let pdfData = pdfView.document?.dataRepresentation()
        let activityViewController = UIActivityViewController(activityItems: [NSLocalizedString("SHEREYOURPDF",comment: "SHEREYOURPDF"), pdfData!], applicationActivities: nil)   // and present it
        present(activityViewController, animated: true) {() -> Void in }
       
    }
    
    @objc func closeWindow(sender: UIButton!) {
      self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLayoutSubviews() {
        pdfView.frame = view.frame
    }
}
