//
//  CFPhotoBrowsePictureView.swift
//  AVarietyOfDemoCollection
//
//  Created by Apple on 2017/7/17.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import SDWebImage

protocol CFPhotoBrowsePictureViewDelegate: NSObjectProtocol {
    func dismissVc(by idx: Int, imageV: UIImageView)
}

class CFPhotoBrowsePictureView: UIView {

    //private vars
    fileprivate var idx: Int!
    fileprivate var photoItem: CFPhotoBrowseItem!
    
    fileprivate lazy var backScollView: UIScrollView = {
        let scroll: UIScrollView = UIScrollView()
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 3
        scroll.delegate = self
        return scroll
    }()
    
    //public vars
    weak var delegate: CFPhotoBrowsePictureViewDelegate?
    
    public lazy var imageV: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        imageV.isUserInteractionEnabled = true
        return imageV
    }()
    
    //public funcs
    convenience init(photoItem: CFPhotoBrowseItem, idx: Int, delegate: CFPhotoBrowsePictureViewDelegate?) {
        self.init(frame: CGRect.zero)
        self.addSubview(backScollView)
        backScollView.addSubview(imageV)
        addGestures()
        self.photoItem = photoItem
        self.idx = idx
        if let image = imageFromCache(by: photoItem.imgUrl) {
            self.photoItem.HDImage = image
            imageV.image = image
        } else {
            imageV.image = photoItem.thumbnails
        }
        self.delegate = delegate
    }
    
    public func loadingImage() {
        if let _ = photoItem.HDImage { return }
        if SDWebImageManager.shared().isRunning() { return }
        if let image = imageFromCache(by: photoItem.imgUrl) {
            photoItem.HDImage = image
            resizeImgView()
        } else {
            guard let url = URL.init(string: photoItem.imgUrl) else { return }
            SDWebImageManager.shared().downloadImage(with: url, options: [.retryFailed, .refreshCached], progress: nil) { (image, error, type, finish, url) in
                if let img = image {
                    self.photoItem.HDImage = img
                    self.imageV.image = img
                    self.resizeImgView()
                }
                ChrysanthemumIndicatorView.hide(fromView: self)
            }
        }
    }
    
    //private funcs
    override func layoutSubviews() {
        super.layoutSubviews()
        backScollView.frame = self.bounds
        resizeImgView()
    }
    
    fileprivate func resizeImgView() {
        guard let image = imageV.image else { return }
        let scale = image.size.width / image.size.height
        let height = self.frame.width / scale
        var originY = (self.frame.height - height) / 2
        if originY < 0 {
            originY = 0
        }
        if scale > 1.5 {
            backScollView.maximumZoomScale = backScollView.frame.height / height + 1
        }
        imageV.frame = CGRect(x: 0, y: originY, width: self.frame.width, height: height)
    }
}

extension CFPhotoBrowsePictureView: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageV
    }
    
    func scrollViewDidZoom(_ scrollView: UIScrollView) {
        let ptX = scrollView.contentSize.width / 2
        let ptY = scrollView.contentSize.height > scrollView.frame.height ? scrollView.contentSize.height / 2 : ((scrollView.frame.height - scrollView.contentSize.height) / 2 + scrollView.contentSize.height / 2)
        imageV.center = CGPoint(x: ptX, y: ptY)
    }
}

extension CFPhotoBrowsePictureView {
    // single and double gestures
    fileprivate func addGestures() {
        let singleGesture = UITapGestureRecognizer(target: self, action: #selector(singleAction))
        singleGesture.delaysTouchesBegan = true
        let doubleGesture = UITapGestureRecognizer(target: self, action: #selector(doubleAction))
        doubleGesture.numberOfTapsRequired = 2
        singleGesture.require(toFail: doubleGesture)
 
        backScollView.addGestureRecognizer(singleGesture)
        backScollView.addGestureRecognizer(doubleGesture)
    }
    
    func singleAction(tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            delegate?.dismissVc(by: idx, imageV: imageV)
        }
    }
    
    func doubleAction(tap: UITapGestureRecognizer) {
        if tap.state == .ended {
            if backScollView.zoomScale <= backScollView.minimumZoomScale {
                var scale: CGFloat = backScollView.maximumZoomScale
                if imageV.frame.width / imageV.frame.height > 1.5 {
                    scale = backScollView.frame.height / imageV.frame.height
                }
                let touchPt = tap.location(in: tap.view)
                let width = backScollView.bounds.width / scale
                let height = backScollView.bounds.height / scale
                backScollView.zoom(to: CGRect(x: touchPt.x - width / scale, y: touchPt.y - height / scale, width: width, height: height), animated: true)
            } else {
                backScollView.setZoomScale(1, animated: true)
            }
        }
    }
    
}

extension CFPhotoBrowsePictureView {
    // image cache funcs
    fileprivate func imageFromCache(by key: String) -> UIImage? {
        let sdCache = SDImageCache.shared()
        if let image = sdCache?.imageFromMemoryCache(forKey: key) {
            return image
        } else {
            if let image = sdCache?.imageFromDiskCache(forKey: key) {
                return image
            } else {
                return nil
            }
        }
    }
}

