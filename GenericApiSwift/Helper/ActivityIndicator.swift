//
//  ActivityIndicator.swift
//  GenericApiSwift
//
//  Created by Apple on 04/06/23.
//

import UIKit

class ActivityIndicator {
    static let shared = ActivityIndicator()
    
    private var activityIndicator: UIActivityIndicatorView?
    private var overlayView: UIView?
    
    func showActivityIndicator() {
        guard let window = UIApplication.topViewController() else {
            return
        }
        
        overlayView = UIView(frame: CGRect(x: 0, y: 0, width: window.view.bounds.width, height: window.view.bounds.height))
        overlayView?.backgroundColor = UIColor(white: 0.0, alpha: 0.5)
        
        activityIndicator = UIActivityIndicatorView(style: .large)
        activityIndicator?.center = overlayView!.center
        activityIndicator?.startAnimating()
        
        overlayView?.addSubview(activityIndicator!)
        window.view.addSubview(overlayView!)
    }
    
    func hideActivityIndicator() {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.activityIndicator?.stopAnimating()
            self.overlayView?.removeFromSuperview()
            self.activityIndicator = nil
            self.overlayView = nil
        })
    }
}
