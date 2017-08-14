//
//  CFPhotoBrowseItem.swift
//  CFPhotoBrowse
//
//  Created by Apple on 2017/7/20.
//  Copyright © 2017年 Apple. All rights reserved.
//

import UIKit

struct CFPhotoBrowseItem {
    
    var imgUrl: String
    var thumbnails: UIImage?
    var HDImage: UIImage?

    init(imgUrl: String, thumbnails: UIImage?) {
        self.imgUrl = imgUrl
        self.thumbnails = thumbnails
    }
}
