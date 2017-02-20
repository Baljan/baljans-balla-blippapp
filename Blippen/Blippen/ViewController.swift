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
    
    var webView = WKWebView()
    var modalOpen = false
    
    // Input field for RFID number
    @IBOutlet weak var inputField: UITextField!
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodHTTPBasic {
            let storedCredentials = URLCredentialStorage.shared.defaultCredential(for: challenge.protectionSpace)
            
            if storedCredentials !== nil && challenge.previousFailureCount == 0 {
                // Try stored credentials if they have not failed previously
                completionHandler(.useCredential, storedCredentials)
            } else {
                // If no or bad credentials, open a modal dialog and ask for credentials
                
                let alertController = UIAlertController(title: "Log in", message: "This app is for internal use only.", preferredStyle: .alert)
                alertController.addTextField(configurationHandler: { textField in
                    textField.placeholder = "user name"
                })
                alertController.addTextField(configurationHandler: { textField in
                    textField.placeholder = "password"
                    textField.isSecureTextEntry = true
                })
                alertController.addAction(UIAlertAction(title: "Log in", style: .default) { action in
                    // Store credentials in the keychain and send them to the server
                    let enteredCredentials = URLCredential(
                        user: (alertController.textFields?[0].text)!,
                        password: (alertController.textFields?[1].text)!,
                        persistence: .permanent)
                    URLCredentialStorage.shared.setDefaultCredential(enteredCredentials, for: challenge.protectionSpace)
                    completionHandler(.useCredential, enteredCredentials)
                    self.inputField.becomeFirstResponder()
                })
                
                modalOpen = true
                inputField.resignFirstResponder()
                present(alertController, animated: true, completion: {
                    self.modalOpen = false
                    self.inputField.becomeFirstResponder()
                })
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
        
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        // Never release focus from the text field unless the web view is loading ('loading' includes waiting for the log in modal to be dismissed)
        return webView.isLoading
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Run when enter is pressed in the text field.
        
        // So, why do this instead of just using the field in the web view? It turns out that the card reader spits out its data
        // to fast for the web view, resulting in garbled data. So we use a native text field (which behaves nicely) instead.
        webView.evaluateJavaScript("document.getElementById('rfid').value='\(textField.text!)';", completionHandler: nil)
        webView.evaluateJavaScript("document.getElementById('form').dispatchEvent(new Event('submit'));", completionHandler: nil)
        
        // Resets the text field for the next entry.
        textField.text = ""
        
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.frame = view.bounds
        
        webView.navigationDelegate = self
        view.addSubview(webView)
        
        inputField.delegate = self
        
        // Set focus to the input field.
        inputField.becomeFirstResponder()
        
        // Load the url into the webview
        let blippURL = URL(string: "https://blipp.baljan.org/")
        
        webView.load(URLRequest(url: blippURL!))
    }
}

