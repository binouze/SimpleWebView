//
//  PannableViewController.swift
//  SmartWKWebView
//
//  Created by Baris Atamer on 12/24/17.
//

import Foundation
import UIKit
import WebKit

public class SmartWKWebViewController: PannableViewController, WKNavigationDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate, WKUIDelegate
{
    
    public static var dataschemes:[String] = ["wkwv"]
    public var openBlankInWebView = true
    
    // MARK: - Public Variables
    
    public var barHeight:     CGFloat = 44
    public var topMargin:     CGFloat = UIApplication.shared.statusBarFrame.size.height + 50;
    public var stringLoading: String  = "Loading"
    public var url:           URL!
    public var webView:       WKWebView!
	public var delegate:      SmartWKWebViewControllerDelegate?
    var toolbar:              SmartWKWebViewToolbar!
    
    public var ondismiss:SmartWKWebViewControllerDelegateDissmissed?;
    
    // MARK: - Private Variables
    
    private var backgroundBlackOverlay: UIView =
    {
        let v = UIView(frame: CGRect.zero)
        v.backgroundColor = UIColor.black
        return v;
    } ()
    
    private var isDraggingEnabled = true
    
    
    // MARK: - Initialization
    
    override public init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?)
    {
        super.init(nibName: nil, bundle: nil)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func commonInit()
    {
        //UIApplication.shared.statusBarFrame.size.height
        let notchSize = self.view.safeAreaTop;
        if( notchSize > 0 )
        {
            print("safeAreaTop: \(notchSize) - statusbarframesize: \(UIApplication.shared.statusBarFrame.size.height) - screenscale \(UIScreen.main.scale)")
            
            topMargin = notchSize + 5
        }
        else
        {
            topMargin = 10
        }
            
        modalPresentationStyle = .overCurrentContext
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
      return true
    }
    
    func addThreeFingerSwipeGesture() {
        let gesture = UISwipeGestureRecognizer(target: self, action: #selector(self.handleThreeFingerSwipe))
        gesture.direction = .right
        gesture.numberOfTouchesRequired = 2 // 2 finger swipe
        gesture.delegate = self
        self.webView.addGestureRecognizer(gesture)
    }
    @objc public func handleThreeFingerSwipe() {
        print("3 finger swipe recognized")
        if self.webView.canGoBack {
            print("Can go back")
            self.webView.goBack()
            //self.webView.reload()
        } else {
            print("Can't go back")
        }
    }
    
    // HANDLE BACK BUTTON
    
    private func majBackButtonState()
    {
        toolbar.backButton.isHidden = self.webView == nil || !self.webView.canGoBack
    }
    
    @objc private func backTapped()
    {
        if self.webView != nil && self.webView.canGoBack {
            print("Can go back")
            self.webView.goBack()
            //self.webView.reload()
        } else {
            print("Can't go back")
        }
    }
    
    // MARK: - View Lifecycle
    
    public override func loadView()
    {
        self.view = UIView(frame: CGRect.zero)
    }
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(self.backgroundBlackOverlay)
        initToolbar()
        initWebView()
        view.addObserver(self, forKeyPath: #keyPath(UIView.frame), options: .new, context: nil)
    }
    
    func initToolbar()
    {
        toolbar = SmartWKWebViewToolbar.init(frame: CGRect(x: 0, y: topMargin, width: UIScreen.main.bounds.width, height: barHeight))
        view.addSubview(toolbar)
        toolbar.closeButton.addTarget(self, action: #selector(closeTapped), for: UIControl.Event.touchUpInside)
        toolbar.backButton.addTarget(self, action: #selector(backTapped), for: UIControl.Event.touchUpInside)
    }
    
    func initWebView()
    {
        webView = WKWebView(frame: CGRect.zero)
        webView.backgroundColor = .white
        webView.navigationDelegate = self
        webView.uiDelegate = self
        webView.scrollView.delegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.panGestureRecognizer.addTarget(self, action: #selector(panGestureActionWebView(_:)))
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "URL", options: .new, context: nil)
        webView.configuration.preferences.javaScriptEnabled = true
        
        view.addSubview(webView)
        
        addThreeFingerSwipeGesture()
        majBackButtonState()
    }
    
    public override func viewWillAppear(_ animated: Bool)
    {
        super.viewWillAppear(animated)
        
        toolbar.addressLabel.text = url?.host ?? ""
        toolbar.titleLabel.text   = stringLoading
        
        if #available(iOS 13.0, *)
        {
            toolbar.titleLabel.textColor =  UIColor { tc in
                switch tc.userInterfaceStyle
                {
                    case .dark:
                        return UIColor.black
                    default:
                        return UIColor.black
                }
            }
        }
        
        if let URL = url
        {
            let urlRequest = URLRequest.init(url: URL)
            webView.load(urlRequest)
        }
    }
    
    public override func viewDidLayoutSubviews()
    {
        super.viewDidLayoutSubviews()
        
        webView.frame = CGRect(x: 0, y: barHeight + topMargin,
                               width: UIScreen.main.bounds.width,
                               height: UIScreen.main.bounds.height - barHeight - topMargin)
        
        backgroundBlackOverlay.frame = CGRect(x: 0,
                                              y: -UIScreen.main.bounds.height,
                                              width: UIScreen.main.bounds.width,
                                              height: UIScreen.main.bounds.height * 2)
        
        toolbar.frame = CGRect(x: 0, y: topMargin, width: UIScreen.main.bounds.width, height: barHeight)
    }
    
    deinit
    {
        webView.removeObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress))
        view.removeObserver(self, forKeyPath: #keyPath(UIView.frame))
    }
    
    
    // MARK: - Button events
    
    @objc func closeTapped()
    {
        dismiss()
    }
    
    func forceDismiss()
    {
        ondismiss = nil;
        dismiss();
    }
    
    override func dismiss()
    {
        OperationQueue.main.addOperation
        {
			self.dismiss(animated: true, completion: {
				self.delegate?.didDismiss?(viewController: self)
			})
        }
        ondismiss?.ondismiss?()
    }
    
    // MARK: - WKUIDelegate
    
    public func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView?
    {
        // savoir si la vue doit gérer les _blank en interne ou en externe
        
        if( self.openBlankInWebView )
        {
            // en interne
            if navigationAction.targetFrame == nil {
                print("redirecting _blank to main frame")
                webView.load(navigationAction.request)
            }
        }
        else
        {
            if( UIApplication.shared.canOpenURL(navigationAction.request.url!) )
            {
                UIApplication.shared.open(navigationAction.request.url!, options: [:], completionHandler: nil)
            }
            
            // en externe (default browser)
            /*if UIApplication.shared.canOpenURL(navigationAction.request.URL!) {
                UIApplication.shared.openURL(navigationAction.request.URL!)
            }*/
        }
        
        // non supporté
        return nil
    }
    
    // MARK: - UIWebViewDelegate
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void)
    {
        print("WKWV:: navigation action: \(String(describing: navigationAction.request)) targetFrame: \(String(describing: navigationAction.targetFrame))")
        
        // if datascheme is supported by the app redirect the datas to the app
        if( SmartWKWebViewController.dataschemes.contains(navigationAction.request.url?.scheme ?? "") )
        //if( navigationAction.request.url?.scheme == datascheme )
        {
            print("WKWV:: host \(navigationAction.request.url?.scheme ?? "") sending data")
            
            ondismiss?.ondata(str: navigationAction.request.url?.absoluteString ?? "")
            decisionHandler(.cancel)
        }
        // else only allow https urls
        else if( navigationAction.request.url?.scheme == "https" )
        {
            decisionHandler(.allow)
            
            toolbar.titleLabel.text   = stringLoading
            toolbar.addressLabel.text = navigationAction.request.url?.host ?? ""
            //UIApplication.shared.open( navigationAction.request.url! )
            //dismiss()
        }
        else
        {
            decisionHandler(.cancel)
        }
        
        majBackButtonState()
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "estimatedProgress"
        {
            toolbar.progressView.progress = Float(webView.estimatedProgress)
            toolbar.progressView.isHidden = toolbar.progressView.progress == 1
        }
        
        if keyPath == "frame"
        {
            let alpha = 1 - (view.frame.origin.y / UIScreen.main.bounds.height)
            backgroundBlackOverlay.alpha = alpha
        }
        
        if keyPath == "URL", let key = change?[NSKeyValueChangeKey.newKey]
        {
            print("WKWV:: urlChanged \(key)")
        }
        
        majBackButtonState()
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        toolbar.titleLabel.text = webView.title
        majBackButtonState()
    }
    
    
    // MARK: - ScrollView Delegate
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        if (scrollView.contentOffset.y == 0 && scrollView.panGestureRecognizer.velocity(in: view).y == 0)
        {
            isDraggingEnabled = true
        }
    }
    
    @objc func panGestureActionWebView(_ panGesture: UIPanGestureRecognizer)
    {
        if panGesture.translation(in: self.view).y < 0
        {
            isDraggingEnabled = false
        }
    
        if isDraggingEnabled
        {
            panGestureAction(panGesture)
            webView.scrollView.contentOffset.y = 0
        }
    }
}

@objc public protocol SmartWKWebViewControllerDelegate
{
	@objc optional func didDismiss(viewController: SmartWKWebViewController)
}

@objc public protocol SmartWKWebViewControllerDelegateDissmissed
{
    @objc optional func ondismiss()
    @objc func ondata( str : String )
}

