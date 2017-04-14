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
    
    // Input field for RFID number
    @IBOutlet weak var rfidField: UITextField!
    
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

                })
                
                present(alertController, animated: true, completion: nil)
            }
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Run when done loading the web view
        rfidField.becomeFirstResponder()
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
    
    // Update the webView fram to the new window size after rotate.
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: nil) { _ in
            self.webView.frame = self.view.bounds
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Hide the keyboard shortcut bar when external keyboard is connected.
        rfidField.autocorrectionType = .no
        let shortcut: UITextInputAssistantItem? = rfidField.inputAssistantItem
        shortcut?.leadingBarButtonGroups = []
        shortcut?.trailingBarButtonGroups = []
        
        // Load the webView
        webView.frame = view.bounds
        webView.navigationDelegate = self
        view.addSubview(webView)
        let blippURL = URL(string: "https://blipp.baljan.org/")
        webView.load(URLRequest(url: blippURL!))
        rfidField.delegate = self
    }
}

