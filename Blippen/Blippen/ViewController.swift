//
//  ViewController.swift
//  Blippen
//
//  Created by Tobias Lundgren on 2017-02-02.
//  Copyright © 2017 Tobias Lundgren. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKNavigationDelegate, UITextFieldDelegate {
    
    var webView: WKWebView?
    
    // Input field for RFID number
    @IBOutlet weak var inputField: UITextField!
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Never release focus from the text field
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Run when enter is pressed in the text field.
        let rfidNumber: String = textField.text!
        
        // So, why do this instead of just using the field in the web view? It turns out that the card reader spits out its data
        // to fast for the web view, resulting in garbled data. So we use a native text field (which behaves nicely) instead.
        //
        webView?.evaluateJavaScript("document.getElementById('rfid').value='\(rfidNumber)';", completionHandler: nil)
        webView?.evaluateJavaScript("document.getElementById('form').dispatchEvent(new Event('submit'));", completionHandler: nil)
        
        // Resets the text field for the next entry.
        textField.text = ""
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView = WKWebView(frame: view.bounds)
        webView?.navigationDelegate = self
        view.addSubview(webView!)
        
        inputField.delegate = self
        
        // Set focus to the input field.
        inputField.becomeFirstResponder()
        
        // Load the url into the webview
        let blippURL = URL(string: "https://blipper:Blipper123@blipp.baljan.org")!
        webView?.load(URLRequest(url: blippURL))
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

