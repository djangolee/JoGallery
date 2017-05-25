//
//  JoPhotosViewController.swift
//  Example
//
//  Created by Django on 5/25/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit
import Photos

class JoPhotosViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: PHPhotoLibrary

extension JoPhotosViewController {
    
    func authorizationForPhotos(_ handler: @escaping (PHAuthorizationStatus) -> Swift.Void) {
        switch PHPhotoLibrary.authorizationStatus() {
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (status) in
                handler(PHPhotoLibrary.authorizationStatus())
            }
            break
        default:
            handler(PHPhotoLibrary.authorizationStatus())
            break
        }
    }
}

// MARK: Setup

extension JoPhotosViewController {
    
    fileprivate func setup() {
        setupVariable()
        setupUI()
        prepareLaunch()
    }
    
    private func setupVariable() {
        
    }
    
    private func prepareLaunch() {
        authorizationForPhotos { (status) in
            if status == .authorized {
                
//                let result = PHAsset .fetchAssets(with: <#T##PHFetchOptions?#>)
//                PHImageManager.default().requestImage(for: <#T##PHAsset#>, targetSize: <#T##CGSize#>, contentMode: <#T##PHImageContentMode#>, options: <#T##PHImageRequestOptions?#>, resultHandler: <#T##(UIImage?, [AnyHashable : Any]?) -> Void#>)
                
            }
        }
    }
    
    private func setupUI() {
        
        title = "Photos"
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        
    }
}
