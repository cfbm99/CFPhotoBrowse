//
//  ChrysanthemumIndicatorView.swift
//  
//
//  Created by Apple on 2017/7/19.
//
//

import UIKit

class ChrysanthemumIndicatorView: UIView {

    fileprivate lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.startAnimating()
        return indicator
    }()
    
    public convenience init(toView: UIView) {
        self.init(frame: toView.bounds)
        self.addSubview(indicator)
        toView.addSubview(self)
    }
    
    public static func hide(fromView: UIView) {
        for view in fromView.subviews.reversed() {
            if view.isKind(of: self) {
                let hud = view as! ChrysanthemumIndicatorView
                UIView.animate(withDuration: 0.3, animations: { 
                    hud.alpha = 0
                }, completion: { (finish) in
                    hud.removeFromSuperview()
                })
            }
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.frame = CGRect(x: (self.frame.width - 30) / 2, y: (self.frame.height - 30) / 2, width: 30, height: 30)
    }

}
