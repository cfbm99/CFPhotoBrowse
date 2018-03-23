//
//  ChrysanthemumIndicatorView.swift
//  
//
//  Created by Apple on 2017/7/19.
//
//

import UIKit

class ChrysanthemumIndicatorView: UIView {
    //private vars
    fileprivate lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.stopAnimating()
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    //public funcs
    public convenience init(toView: UIView) {
        self.init(frame: CGRect.zero)
        self.bounds = CGRect(origin: CGPoint.zero, size: CGSize(width: 30, height: 30))
        self.center = toView.center
        indicator.frame = self.bounds
        
        toView.addSubview(self)
        self.addSubview(indicator)
    }
    
    public func start() {
        indicator.startAnimating()
    }
    
    public func stop() {
        indicator.stopAnimating()
    }
    
//    public static func hide(fromView: UIView) {
//        for view in fromView.subviews.reversed() {
//            if view.isKind(of: self) {
//                let hud = view as! ChrysanthemumIndicatorView
//                UIView.animate(withDuration: 0.3, animations: {
//                    hud.alpha = 0
//                }, completion: { (finish) in
//                    hud.removeFromSuperview()
//                })
//            }
//        }
//    }
    

}
