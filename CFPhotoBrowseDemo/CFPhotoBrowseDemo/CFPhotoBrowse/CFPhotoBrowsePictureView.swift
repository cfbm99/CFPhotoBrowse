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

    weak var delegate: CFPhotoBrowsePictureViewDelegate?
    
    public lazy var imageV: UIImageView = {
        let imageV = UIImageView()
        imageV.contentMode = .scaleAspectFill
        imageV.clipsToBounds = true
        imageV.isUserInteractionEnabled = true
        return imageV
    }()
    
    fileprivate lazy var backScollView: UIScrollView = {
        let scroll: UIScrollView = UIScrollView(frame: self.bounds)
        scroll.showsVerticalScrollIndicator = false
        scroll.showsHorizontalScrollIndicator = false
        scroll.minimumZoomScale = 1
        scroll.maximumZoomScale = 2
        scroll.delegate = self
        return scroll
    }()
    
    fileprivate var idx: Int!
    fileprivate var photoItem: CFPhotoBrowseItem!

    convenience init(frame: CGRect, photoItem: CFPhotoBrowseItem, idx: Int, delegate: CFPhotoBrowsePictureViewDelegate?) {
        self.init(frame: frame)
        self.addSubview(backScollView)
        backScollView.addSubview(imageV)
        addGestures()
        self.photoItem = photoItem
        if let image = imageFromCache(by: photoItem.imgUrl) {
            self.photoItem.HDImage = image
            resizeImgView(by: image)
        } else {
            _ = ChrysanthemumIndicatorView(toView: self)
            resizeImgView(by: photoItem.thumbnails)
        }
        self.idx = idx
        self.delegate = delegate
    }
    
    public func loadingImage() {
        if let _ = photoItem.HDImage { return }
        if SDWebImageManager.shared().isRunning() { return }
        if let image = imageFromCache(by: photoItem.imgUrl) {
            photoItem.HDImage = image
            resizeImgView(by: image)
        } else {
            guard let url = URL.init(string: photoItem.imgUrl) else { return }
            SDWebImageManager.shared().downloadImage(with: url, options: [.retryFailed, .refreshCached], progress: nil) { (image, error, type, finish, url) in
                if let img = image {
                    self.photoItem.HDImage = img
                    self.resizeImgView(by: img)
                }
                ChrysanthemumIndicatorView.hide(fromView: self)
            }
        }
    }
    
    fileprivate func resizeImgView(by image: UIImage?) {
        guard let image = image else { return }
        let scale = image.size.width / image.size.height
        let height = self.frame.width / scale
        var originY = (self.frame.height - height) / 2
        if originY < 0 {
            originY = 0
        }
        if scale > 2 {
            backScollView.maximumZoomScale = scale
        }
        imageV.frame = CGRect(x: 0, y: originY, width: self.frame.width, height: height)
        imageV.image = image
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
            if backScollView.zoomScale <= 1 {
                let touchPt = tap.location(in: tap.view)
                backScollView.zoom(to: CGRect(x: touchPt.x, y: touchPt.y, width: 1, height: 1), animated: true)
            } else {
                backScollView.setZoomScale(1, animated: true)
            }
        }
    }
    
}

extension CFPhotoBrowsePictureView {
    
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

