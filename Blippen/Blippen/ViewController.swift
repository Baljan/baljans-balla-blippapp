//
//  ViewController.swift
//  Blippen
//
//  Created by Tobias Lundgren on 2017-02-02.
//  Copyright © 2017 Tobias Lundgren. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate {
    
    
    var webView: WKWebView!
   // Input field for RFID number
    @IBOutlet weak var inputField: UITextField!

    //func controlTextDidEndEditing(_ aNotification : Notification)
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        print("return pressed")
        textField.resignFirstResponder()
        return false
    }

    func submitForm() {
        print("successful submit form")
        
        webView!.evaluateJavaScript("document.getElementById('rfid').value='2043261358';", completionHandler: nil)
        
        webView!.evaluateJavaScript("document.getElementById('form').dispatchEvent(new Event('submit'));", completionHandler: nil)
        
    }
    
    override func loadView() {
        webView = WKWebView()
        webView.navigationDelegate = self
        view = webView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Set focus to the input field.
        
        //inputField.becomeFirstResponder()
        
        // Load the url into the webview
        let blippURL = URL(string: "https://blipper:Blipper123@blipp.baljan.org")!
        webView.load(URLRequest(url: blippURL))
        
        // Waiting 4 sec
        /*DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(4), execute: {
            self.submitForm()
        })*/
        
        

    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

