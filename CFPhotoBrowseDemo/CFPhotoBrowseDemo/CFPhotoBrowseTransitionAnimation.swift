//
//  CFPhotoBrowseTransitionAnimation.swift
//  AVarietyOfDemoCollection
//
//  Created by Apple on 2017/7/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

enum CFPhotoBrowseTransitionAnimationStyle: Int {
    case present, dismiss
}

class CFPhotoBrowseTransitionAnimation: NSObject, UIViewControllerAnimatedTransitioning {
    
    var style: CFPhotoBrowseTransitionAnimationStyle
    
    init(transitionstyle: CFPhotoBrowseTransitionAnimationStyle) {
        style = transitionstyle
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if style == .present {
            presentVcTransition(using: transitionContext)
        } else {
            dismissVcTransition(using: transitionContext)
        }
    }
}

extension CFPhotoBrowseTransitionAnimation {
    
    fileprivate func presentVcTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = transitionContext.viewController(forKey: .from) as? ViewController,
            let toVc = transitionContext.viewController(forKey:.to) as? CFPhotoBrowse,
            let toVcCurrentImgV = toVc.currentImageV, let fromIndexpath = fromVc.collectionV.indexPathsForSelectedItems?.last, let fromCell = fromVc.collectionV.cellForItem(at: fromIndexpath) as? CustomCollectionViewCell else { transitionContext.completeTransition(true); return }
        let containerView = transitionContext.containerView
        
        let tempImgV = UIImageView(image: toVcCurrentImgV.image)
        tempImgV.clipsToBounds = true
        tempImgV.contentMode = .scaleAspectFill
        
        let fromRect = fromCell.imageV.convert(fromCell.imageV.bounds, to: containerView)
        let toRect = toVcCurrentImgV.convert(toVcCurrentImgV.bounds, to: containerView)
        tempImgV.frame = fromRect
        toVc.view.alpha = 0
        toVcCurrentImgV.isHidden = true
        containerView.addSubview(toVc.view)
        containerView.addSubview(tempImgV)
        fromCell.imageV.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { 
            tempImgV.frame = toRect
            toVc.view.alpha = 1
        }) { (finish) in
            toVcCurrentImgV.isHidden = false
            tempImgV.removeFromSuperview()
            fromCell.imageV.isHidden = false
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
    
    fileprivate func dismissVcTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let fromVc = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as? CFPhotoBrowse,
            let toVc = transitionContext.viewController(forKey: .to) as? ViewController,
            let fromVcCurrentImgV = fromVc.currentImageV,
            let toVcCell = toVc.collectionV.cellForItem(at: IndexPath(item: fromVc.currentIdx, section: 0)) as? CustomCollectionViewCell else { transitionContext.completeTransition(true); return }
        
        let containerView = transitionContext.containerView
        let tempImgV = UIImageView(image: toVcCell.imageV.image)
        tempImgV.clipsToBounds = true
        tempImgV.contentMode = .scaleAspectFill
        
        let fromRect = fromVcCurrentImgV.convert(fromVcCurrentImgV.bounds, to: containerView)
        let toRect = toVcCell.convert(toVcCell.imageV.frame, to: containerView)
        tempImgV.frame = fromRect
        toVcCell.isHidden = true
        containerView.addSubview(tempImgV)
        fromVc.currentImageV?.isHidden = true
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            tempImgV.frame = toRect
            fromVc.view.alpha = 0
        }) { (finish) in
            toVcCell.isHidden = false
            tempImgV.removeFromSuperview()
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
