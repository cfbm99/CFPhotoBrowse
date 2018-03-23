//
//  ViewController.swift
//  CFPhotoBrowse
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit
import SDWebImage

class ViewController: UIViewController {
    
    @IBOutlet weak var collectionV: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    fileprivate var imageUrls: [[String : String]] = []
    
    //life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        collectionV.reloadData()
        initializeInterface()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        flowLayout.itemSize = CGSize(width: (view.bounds.width - 41) / 3, height: (view.bounds.width - 41) / 3)
    }
    
    // private funcs
    fileprivate func initializeInterface() {
        flowLayout.minimumLineSpacing = 10
        flowLayout.minimumInteritemSpacing = 10
        flowLayout.sectionInset = UIEdgeInsetsMake(10, 10, 0, 10)
        getMovieList()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func clearCache(_ sender: UIBarButtonItem) {
        print(SDImageCache.shared().getSize())
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk { 
            print(SDImageCache.shared().getSize())
        }
    }
}

extension ViewController {
    
    fileprivate func getMovieList() {
        guard let url = URL.init(string: "https://api.douban.com/v2/movie/in_theaters?city=%E6%88%90%E9%83%BD&start=0&count=20") else { return }
        var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15)
        request.httpMethod = "GET"
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                guard let data = data, let json = try? JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments), let dic = json as? [String : Any], let dics = dic["subjects"] as? [[String : Any]] else { return }
                for imgDic in dics {
                    self.imageUrls.append(imgDic["images"] as! [String : String])
                }
                DispatchQueue.main.async(execute: {
                    self.collectionV.reloadData()
                })
            }
        }
        task.resume()
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count - 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomCollectionViewCell", for: indexPath) as! CustomCollectionViewCell
        if let urlString = imageUrls[indexPath.row]["small"], let url = URL.init(string: urlString) {
            cell.imageV.sd_setImage(with: url)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        var items: [CFPhotoBrowseItem] = []
        for idx in 0 ..< imageUrls.count - 6 {
            let cell = collectionView.cellForItem(at: IndexPath(item: idx, section: 0)) as! CustomCollectionViewCell
            let imageUrl = imageUrls[idx]["large"]!
            let item = CFPhotoBrowseItem(imgUrl: imageUrl, thumbnails: cell.imageV.image)
            items.append(item)
        }
        let browseVc = CFPhotoBrowse(photoItems: items, selectedIdx: indexPath.row)
        browseVc.delegate = self
        browseVc.transitioningDelegate = self
        browseVc.modalPresentationStyle = .custom
        self.present(browseVc, animated: true, completion: nil)
    }
}

extension ViewController : CFPhotoBrowseDelegate {
    
    func panGestureForVcDismissBegin(idx: Int) {
        guard let cell = collectionV.cellForItem(at: IndexPath(item: idx, section: 0)) as? CustomCollectionViewCell else { return }
        cell.isHidden = true
    }
    
    func panGestureForVcDisminssEnd(idx: Int) {
        guard let cell = collectionV.cellForItem(at: IndexPath(item: idx, section: 0)) as? CustomCollectionViewCell else { return }
        cell.isHidden = false
    }
}

extension ViewController : UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CFPhotoBrowseTransitionAnimation(transitionstyle: .present)
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CFPhotoBrowseTransitionAnimation(transitionstyle: .dismiss)
    }
}
