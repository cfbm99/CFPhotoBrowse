//
//  CFPhotoBrowse.swift
//  CFPhotoBrowse
//
//  Created by 曹飞 on 2017/8/12.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import Photos

protocol CFPhotoBrowseDelegate : NSObjectProtocol {
    func panGestureForVcDismissBegin(idx: Int)
    func panGestureForVcDisminssEnd(idx: Int)
}

class CFPhotoBrowse: UIViewController {
    
    //private vars
    fileprivate let padding: CGFloat = 20
    fileprivate var cfPhotoBrowsePictureViews: [CFPhotoBrowsePictureView] = []
    fileprivate var currentImgVLastSupperV: UIView?
    fileprivate var cfPhotoItems: [CFPhotoBrowseItem] = []
    
    //public vars
    public weak var delegate: CFPhotoBrowseDelegate?
    public var currentImageV: UIImageView!
    public var currentIdx: Int = 0
    
    //private lazy vars
    fileprivate lazy var scollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.backgroundColor = UIColor.black
        scroll.alwaysBounceHorizontal = false
        scroll.alwaysBounceVertical = false
        scroll.isPagingEnabled = true
        scroll.delegate = self
        return scroll
    }()
    
    fileprivate lazy var panGesture: UIPanGestureRecognizer = {
        let pan = UIPanGestureRecognizer(target: self, action: #selector(panAction))
        return pan
    }()
    
    fileprivate lazy var longGestue: UILongPressGestureRecognizer = {
        let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(longAction))
        longGesture.minimumPressDuration = 1
        return longGesture
    }()
    
    //public funcs
    convenience init(photoItems: [CFPhotoBrowseItem], selectedIdx: Int?) {
        self.init(nibName: nil, bundle: nil)
        cfPhotoItems = photoItems
        if let idx = selectedIdx {
            currentIdx = idx
        }
    }
    
    //life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeInterface()
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateFrames()
    }
    
    //private funcs
    fileprivate func initializeInterface() {
        view.addSubview(scollView)
        view.addGestureRecognizer(panGesture)
        view.addGestureRecognizer(longGestue)
        addPhotoBrowsePhotoViews()
        registPhotoLibrary()
    }
    
    fileprivate func calculateFrames() {
        scollView.frame = CGRect(x: 0, y: 0, width: view.frame.width + padding, height: view.frame.height)
        scollView.contentSize = CGSize(width: scollView.frame.width * CGFloat(cfPhotoItems.count), height: scollView.frame.height)
        for (idx, itemView) in cfPhotoBrowsePictureViews.enumerated() {
            var itemFrame = scollView.bounds
            itemFrame.origin.x = CGFloat(idx) * scollView.frame.width
            itemFrame.size.width = view.frame.width
            itemView.frame = itemFrame
        }
        scollView.setContentOffset(CGPoint(x: CGFloat(currentIdx) * scollView.bounds.width, y: 0), animated: false)
        cfPhotoBrowsePictureViews[currentIdx].layoutIfNeeded()
        cfPhotoBrowsePictureViews[currentIdx].loadingImage()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

extension CFPhotoBrowse {
    
    fileprivate func addPhotoBrowsePhotoViews() {
        for (idx, item) in cfPhotoItems.enumerated() {
            let photoView = CFPhotoBrowsePictureView(photoItem: item, idx: idx, delegate: self)
            scollView.addSubview(photoView)
            cfPhotoBrowsePictureViews.append(photoView)
        }
        currentImageV = cfPhotoBrowsePictureViews[currentIdx].imageV
    }
}

extension CFPhotoBrowse: UIScrollViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentIdx = Int(scrollView.contentOffset.x / ((scrollView.frame.width)))
        currentImageV = cfPhotoBrowsePictureViews[currentIdx].imageV
        cfPhotoBrowsePictureViews[currentIdx].loadingImage()
    }
}

extension CFPhotoBrowse: CFPhotoBrowsePictureViewDelegate {
    
    func dismissVc(by idx: Int, imageV: UIImageView) {
        self.dismiss(animated: true, completion: nil)
    }
}

extension CFPhotoBrowse {
    
    func longAction(long: UILongPressGestureRecognizer) {
        if long.state == .began {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)
            let saveAction = UIAlertAction(title: "保存图片", style: UIAlertActionStyle.default, handler: { (action) in
                self.saveImage(image: self.currentImageV?.image)
            })
            let cancel = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel, handler: nil)
            alert.addAction(saveAction)
            alert.addAction(cancel)
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func panAction(pan: UIPanGestureRecognizer) {
        let translationPt = pan.translation(in: pan.view)
        if translationPt.y < 0 {
            return
        }
        var percent = translationPt.y / view.frame.height
        if percent > 1 {
            percent = 1
        }
        if pan.state == .began {
            currentImgVLastSupperV = currentImageV.superview
            currentImageV.removeFromSuperview()
            view.window?.addSubview(currentImageV)
            delegate?.panGestureForVcDismissBegin(idx: currentIdx)
        } else if pan.state == .changed {
            currentImageV.transform = CGAffineTransform.init(translationX: translationPt.x, y: translationPt.y).scaledBy(x: 1 - percent, y: 1 - percent)
            view.alpha = 1 - percent
        } else if pan.state == .ended {
            if percent > 0.3 {
                self.dismiss(animated: true, completion: {
                    self.delegate?.panGestureForVcDisminssEnd(idx: self.currentIdx)
                })
            } else {
                guard let lastSupperV = currentImgVLastSupperV else { return }
                currentImageV.removeFromSuperview()
                lastSupperV.addSubview(currentImageV)
                UIView.animate(withDuration: 0.3, animations: {
                    self.currentImageV.transform = CGAffineTransform.identity
                    self.view.alpha = 1
                })
                delegate?.panGestureForVcDisminssEnd(idx: currentIdx)
            }
        }
    }
}

extension CFPhotoBrowse {
    
    fileprivate func registPhotoLibrary() {
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) in
                
            })
        }
    }
    
    fileprivate func saveImage(image: UIImage?) {
        guard let img = image else { return }
        PHPhotoLibrary.shared().performChanges({
            PHAssetChangeRequest.creationRequestForAsset(from: img)
        }) { (success, error) in
            if !success {
                print(error?.localizedDescription ?? "error")
            }
        }
        
    }
}
