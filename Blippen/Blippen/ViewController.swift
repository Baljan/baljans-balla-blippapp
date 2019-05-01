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
    
    func setTokenCookie(value: String) {
        webView.evaluateJavaScript("Cookies.set('token', '\(value)');", completionHandler: nil)
    }
    
    func setOrAskForTokenCookie() {
        let storedToken = UserDefaults.standard.string(forKey: "Token")
        
        if let token = storedToken {
            // Set cookie with stored credentials
            setTokenCookie(value: token)
            rfidField.becomeFirstResponder()
        } else {
            // If no token, open a modal dialog and ask for credentials
            let alertController = UIAlertController(title: "Configure token", message: "This app is for internal use only.", preferredStyle: .alert)
            alertController.addTextField(configurationHandler: { textField in
                textField.placeholder = "Token"
            })
            alertController.addAction(UIAlertAction(title: "Save", style: .default) { action in
                // Store token and update cookie
                let token = (alertController.textFields?[0].text)!
                
                UserDefaults.standard.set(token, forKey: "Token")
                
                self.setTokenCookie(value: token)
                self.rfidField.becomeFirstResponder()
            })
            
            present(alertController, animated: true, completion: nil)
        }
        
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // Run when done loading the web view
        setOrAskForTokenCookie()
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        let refreshAlert = UIAlertController(title: "Kunde inte starta Blippen", message: "Detta kan bero på att iPaden inte hunnit koppla upp sig mot nätverket.\n\nVill du försöka igen?", preferredStyle: UIAlertController.Style.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ja", style: .default, handler: { (action: UIAlertAction!) in
            self.reloadWebView()
        }))
        
        refreshAlert.addAction(UIAlertAction(title: "Nej", style: .cancel, handler: { (action: UIAlertAction!) in
            exit(1)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
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
        webView.scrollView.maximumZoomScale = 1.0;
        webView.scrollView.minimumZoomScale = 1.0;
        view.addSubview(webView)
        reloadWebView()
        rfidField.delegate = self
    }
    
    func reloadWebView() {
        let blippURL = URL(string: "https://blipp.baljan.org/")
        webView.load(URLRequest(url: blippURL!, cachePolicy: URLRequest.CachePolicy.reloadIgnoringCacheData))
    }
}

