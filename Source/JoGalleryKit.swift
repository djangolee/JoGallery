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
    
    static let `default` = JoGalleryKit()
    
    let cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.totalCostLimit = 50 * 1024 * 1024
        return cache
    }()
    
    func image(_ content: Any?,  resultHandler: @escaping (UIImage?) -> Swift.Void) {
        if let asset = content as? PHAsset {
            if let image = cache.object(forKey: asset.localIdentifier as NSString) {
                OperationQueue.main.addOperation {
                    resultHandler(image)
                }
            } else {
                let requetOptions = PHImageRequestOptions()
                requetOptions.resizeMode = .none
                requetOptions.isSynchronous = false
                requetOptions.deliveryMode = .highQualityFormat
                
                PHImageManager.default().requestImage(for: asset, targetSize: PHImageManagerMaximumSize, contentMode: .default, options: requetOptions) { (image, info) in
                    if let image = image {
                        self.cache.setObject(image, forKey: asset.localIdentifier as NSString)
                    }
                    OperationQueue.main.addOperation {
                        resultHandler(image)
                    }
                }
            }
        } else if let image = content as? UIImage {
            OperationQueue.main.addOperation {
                resultHandler(image)
            }
        } else {
            OperationQueue.main.addOperation {
                resultHandler(nil)
            }
        }
    }
    
    func imageSizeRange(content: Any?) -> (defaultSize: CGSize, contentSize: CGSize, maximumZoomScale: CGFloat) {
        
        guard let content = content, (content is PHAsset || content is UIImage) else {
            return (CGSize.zero, CGSize.zero, 2)
        }
        
        var imageSize = CGSize.zero
        var defaultSize = CGSize.zero
        var contentSize = CGSize.zero
        var maximumZoomScale: CGFloat = 2
        let screenSize = UIScreen.main.bounds.size
        let aspectRatio = screenSize.width / screenSize.height
        var imageAspectRatio: CGFloat = 0
        
        if let image = content as? UIImage {
            imageAspectRatio = image.size.width / image.size.height;
            defaultSize = image.size
            imageSize = defaultSize
        } else if let asset = content as? PHAsset {
            imageAspectRatio = CGFloat(asset.pixelWidth) / CGFloat(asset.pixelHeight)
            defaultSize = CGSize(width: CGFloat(asset.pixelWidth), height: CGFloat(asset.pixelHeight))
            imageSize = defaultSize
        }
        
        if imageAspectRatio < aspectRatio {
            defaultSize.height = screenSize.height < defaultSize.height ? screenSize.height : defaultSize.height
            defaultSize.width = defaultSize.height * imageAspectRatio
        } else {
            defaultSize.width = screenSize.width < defaultSize.width ? screenSize.width : defaultSize.width
            defaultSize.height = defaultSize.width * (1 / imageAspectRatio)
        }
        contentSize = CGSize(width: max(defaultSize.width, screenSize.width), height: max(defaultSize.height, screenSize.height))
        maximumZoomScale = imageSize.width * 2 / defaultSize.width
        
        return (defaultSize, contentSize, maximumZoomScale)
    }
}
