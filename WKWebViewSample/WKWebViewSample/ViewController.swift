//
//  ViewController.swift
//  WKWebViewSample
//
//  Created by kkato on 2016/04/13.
//  Copyright © 2016年 CrossBridge. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, WKUIDelegate, WKNavigationDelegate, UITextFieldDelegate {
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var toolBar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    
    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()

        textField.delegate = self
        
        webView = WKWebView()
        webView.UIDelegate = self
        webView.navigationDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(webView)
        
        let views = ["webView":webView, "textField":textField, "toolBar":toolBar]
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[webView]|", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[textField][webView][toolBar]", options: NSLayoutFormatOptions(rawValue: 0), metrics: nil, views: views))
        
        webView.addObserver(self, forKeyPath: "canGoBack", options: NSKeyValueObservingOptions.New, context: nil)
        webView.addObserver(self, forKeyPath: "canGoForward", options: NSKeyValueObservingOptions.New, context: nil)
        webView.addObserver(self, forKeyPath: "loading", options: NSKeyValueObservingOptions.New, context: nil)
        
        let url = NSURL(string:"http://yahoo.co.jp/")
        let req = NSURLRequest(URL:url!)
        webView.loadRequest(req)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        
        if object!.isEqual(webView) {
            if keyPath == "canGoBack"{
               backButton.enabled = webView.canGoBack
            } else if keyPath == "canGoForward" {
               forwardButton.enabled = webView.canGoForward
            } else if keyPath == "loading" {
                let app = UIApplication.sharedApplication()
                app.networkActivityIndicatorVisible = webView.loading
            }
        }
    }

    @IBAction func pressButton(sender: UIBarButtonItem) {
        if sender == backButton {
            webView.goBack()
        } else if sender == forwardButton {
            webView.goForward()
        } else if sender == reloadButton {
            webView.reload()
        }
    }

    deinit{
        webView.removeObserver(self, forKeyPath: "canGoBack", context: nil)
        webView.removeObserver(self, forKeyPath: "canGoForward", context: nil)
        webView.removeObserver(self, forKeyPath: "loading", context: nil)
    }

    // WKUIDelegate method
    func webView(webView: WKWebView, createWebViewWithConfiguration configuration: WKWebViewConfiguration, forNavigationAction navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard let url = navigationAction.request.URL else {
            return nil
        }
        guard let targetFrame = navigationAction.targetFrame where targetFrame.mainFrame else {
            webView.loadRequest(NSURLRequest.init(URL: url))
            return nil
        }
        return nil
    }
    
    // WKNavigationDelegate method
    func webView(webView: WKWebView, didFailNavigation navigation: WKNavigation!, withError error: NSError) {
        print(error.localizedDescription)
    }
    
    func webView(webView: WKWebView, didFinishNavigation navigation: WKNavigation!) {
        textField.text = webView.URL?.absoluteString
    }
    
    // UITextFieldDelegate method
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        let url = NSURL(string:textField.text!)
        let req = NSURLRequest(URL:url!)
        webView.loadRequest(req)
      
        textField.resignFirstResponder()
        
        return true
    }
}

