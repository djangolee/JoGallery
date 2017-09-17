//
//  JoPhotosViewController.swift
//  Example
//
//  Created by Django on 5/25/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit
import Photos
import JoGallery

class JoPhotosViewController: UIViewController {

    fileprivate var assets = PHFetchResult<PHAsset>()
    fileprivate let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .vertical
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
}

// MARK: Protocol

extension JoPhotosViewController: JoGalleryControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: JoGalleryControllerContextTransitioning, atIndex indexPath: IndexPath) -> TimeInterval {
        return 1
    }
    
    func animateTransition(using transitionContext: JoGalleryControllerContextTransitioning, atIndex indexPath: IndexPath) {
        
        transitionContext.completeTransition(true)
        
    }
}

extension JoPhotosViewController: JoGalleryDelegate {
    
    func gallery(_ galleryController: JoGalleryController, cellSizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: assets[indexPath.item].pixelWidth, height: assets[indexPath.item].pixelHeight)
    }
}

extension JoPhotosViewController: JoGalleryDataSource {
    
    func galleryController(_ galleryController: JoGalleryController, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func galleryController(_ galleryController: JoGalleryController, cellForItemAt indexPath: IndexPath) -> JoGalleryCell {
        let cell = galleryController.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(JoGalleryCell.self), for: indexPath)
        
        let asset = assets[indexPath.item]
        JoPhotosViewController.image(asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight)) { (image) in
            if let imageView = cell.containAnimateView as? UIImageView {
                imageView.image = image
            }
        }
        
        return cell
    }
}


// MARK: UICollectionViewProtocol

extension JoPhotosViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    // MARK: UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = JoGalleryController()
        controller.register(JoGalleryCell.self, forCellWithReuseIdentifier: NSStringFromClass(JoGalleryCell.self))
        controller.delegate = self
        controller.dataSource = self
        controller.transitioningAnimate = self
        controller.present(from: self, toItem: indexPath)
    }
    
    // MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return assets.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(JoPhotosViewCellCollectionViewCell.self), for: indexPath) as! JoPhotosViewCellCollectionViewCell
        cell.asset = assets[indexPath.item]
        return cell
    }
}

// MARK: PHPhotoLibrary

extension JoPhotosViewController {
    
    fileprivate func authorizationForPhotos(_ handler: @escaping (PHAuthorizationStatus) -> Swift.Void) {
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
    
    class func image(_ asset: PHAsset, targetSize: CGSize,  resultHandler: @escaping (UIImage?) -> Swift.Void) {
        let scale = UIScreen.main.scale
        let itemSize = CGSize.init(width: scale * targetSize.width, height: scale * targetSize.height)
        let requetOptions = PHImageRequestOptions()
        requetOptions.resizeMode = .none
        requetOptions.isSynchronous = false
        requetOptions.deliveryMode = .highQualityFormat
        
        PHImageManager.default().requestImage(for: asset, targetSize: itemSize, contentMode: .aspectFit, options: requetOptions) { (image, info) in
            OperationQueue.main.addOperation {
                resultHandler(image)
            }
        }
    }
}

// MARK: Setup

extension JoPhotosViewController {
    
    fileprivate func setup() {
        setupUI()
        prepareLaunch()
    }
    
    private func prepareLaunch() {
        authorizationForPhotos { (status) in
            if status == .authorized {
                let fetchOptions = PHFetchOptions()
                fetchOptions.sortDescriptors = [NSSortDescriptor(key: #keyPath(PHAsset.creationDate), ascending: true)]
                OperationQueue.main.addOperation {
                    self.assets = PHAsset.fetchAssets(with: .image, options: fetchOptions)
                    self.collectionView.reloadData()
                }
            }
        }
    }
    
    private func setupUI() {
        
        title = "All Photos"
        view.backgroundColor = .white
        
        setupCollectionView()
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        collectionView.frame = view.bounds
    }
    
    private func setupCollectionView() {
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.minimumLineSpacing = 1
            flowLayout.minimumInteritemSpacing = 1
            let cellSize = (view.frame.width - flowLayout.minimumInteritemSpacing * 3) / 4
            flowLayout.itemSize = CGSize(width: cellSize, height: cellSize)
        }
        
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(JoPhotosViewCellCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(JoPhotosViewCellCollectionViewCell.self))
        view.addSubview(collectionView)
    }
}
