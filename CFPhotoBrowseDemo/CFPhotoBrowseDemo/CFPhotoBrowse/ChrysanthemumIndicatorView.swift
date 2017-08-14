//
//  ChrysanthemumIndicatorView.swift
//  
//
//  Created by Apple on 2017/7/19.
//
//

import UIKit

class ChrysanthemumIndicatorView: UIView {

    lazy var indicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        indicator.startAnimating()
        return indicator
    }()
    
    convenience init(toView: UIView) {
        self.init(frame: toView.bounds)
        self.addSubview(indicator)
        toView.addSubview(self)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        indicator.frame = CGRect(x: (self.frame.width - 30) / 2, y: (self.frame.height - 30) / 2, width: 30, height: 30)
    }

}
