//
//  JoGalleryKit.swift
//  JoGallery
//
//  Created by Django on 5/26/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit
import Photos

class JoGalleryKit: NSObject {
    
    class func image(_ any: Any,  resultHandler: @escaping (UIImage?) -> Swift.Void) {
        if let asset = any as? PHAsset {
            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            let scale = UIScreen.main.scale
            let itemSize = CGSize.init(width: scale * targetSize.width, height: scale * targetSize.height)
            let requetOptions = PHImageRequestOptions()
            requetOptions.resizeMode = .fast
            requetOptions.isSynchronous = false
            requetOptions.deliveryMode = .highQualityFormat
            
            PHImageManager.default().requestImage(for: asset, targetSize: itemSize, contentMode: .aspectFit, options: requetOptions) { (image, info) in
                OperationQueue.main.addOperation {
                    resultHandler(image)
                }
            }
        } else if let image = any as? UIImage {
            OperationQueue.main.addOperation {
                resultHandler(image)
            }
        }
    }
    
}
