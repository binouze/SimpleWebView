//
//  PannableViewController.swift
//  SmartWKWebView
//
//  Created by Baris Atamer on 12/25/17.
//

import Foundation
import UIKit

public class PannableViewController: UIViewController
{
    var panGestureRecognizer:   UIPanGestureRecognizer?
    var originalPosition:       CGPoint?
    var currentPositionTouched: CGPoint?
    var panning:                Bool = false;
    
    public override func viewDidLoad()
    {
        super.viewDidLoad()
        panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panGestureAction(_:)) )
        view.addGestureRecognizer(panGestureRecognizer!)
    }
    
    public override func viewDidLayoutSubviews()
    {
        super .viewDidLayoutSubviews()
        
        if( !panning )
        {
            view.frame = UIScreen.main.bounds
            originalPosition = view.center
            print("viewDidLayoutSubviews")
        }
    }
    
    @objc func panGestureAction(_ panGesture: UIPanGestureRecognizer)
    {
        return
        
        let translation = panGesture.translation(in: view)
        
        if panGesture.state == .began
        {
            panning = true
            originalPosition = view.center
            currentPositionTouched = panGesture.location(in: view)
        }
        else if panGesture.state == .changed
        {
            let yy = translation.y / view.frame.size.height
            let y2 = (1-yy) * translation.y
            self.view.frame.origin = CGPoint(
                x: view.frame.origin.x,
                y: y2
            )
        }
        else if panGesture.state == .ended
        {
            panning = false
            animateToOriginalPosition()
        }
    }
    
    func dismissView()
    {
        self.dismiss()
    }
    
    func dismiss()
    {
        self.dismiss(animated: false, completion: nil)
    }
    
    func animateToOriginalPosition()
    {
        panning = false
        UIView.animate(withDuration: 0.3, delay: 0, options: [.curveEaseOut], animations: {
            self.view.center = self.originalPosition!
        })
    }
}
