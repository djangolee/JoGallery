//
//  JoGalleryProtocol.swift
//  JoGallery
//
//  Created by django on 5/19/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

// MARK: JoGalleryController

public protocol JoGalleryDataSource: NSObjectProtocol {
    
    func galleryController(_ galleryController: JoGalleryController, numberOfItemsInSection section: Int) -> Int
    func galleryController(_ galleryController: JoGalleryController, cellForItemAt indexPath: IndexPath) -> JoGalleryCell
    
    func numberOfSections(in galleryController: JoGalleryController) -> Int
}

extension JoGalleryDataSource {
    public func numberOfSections(in galleryController: JoGalleryController) -> Int {
        return 1
    }
}

public protocol JoGalleryDelegate: NSObjectProtocol {
    
    typealias JoGalleryLocationAttributes = (location: UIView, content: Any)
    
    func presentForTransitioning(in galleryController: JoGalleryController, openAt indexPath: IndexPath) -> JoGalleryLocationAttributes?
    func presentTransitionCompletion(in galleryController: JoGalleryController, openAt indexPath: IndexPath)
    func dismissForTransitioning(in galleryController: JoGalleryController, closeAt indexPath: IndexPath) -> JoGalleryLocationAttributes?
    func dismissTransitionCompletion(in galleryController: JoGalleryController, closeAt indexPath: IndexPath)
    
    func gallery(_ galleryController: JoGalleryController, scrolDidDisplay cell: JoGalleryCell, forItemAt indexPath: IndexPath, oldItemFrom oldIndexPath: IndexPath)
    
    func galleryBeginTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath) -> UIView?
    func galleryDidTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, isTouching : Bool, with thresholdValue: CGFloat)
    func galleryDidEndTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, with thresholdValue: CGFloat) -> UIView?

}

extension JoGalleryDelegate {
    
    public func presentForTransitioning(in galleryController: JoGalleryController, openAt indexPath: IndexPath) -> JoGalleryLocationAttributes? {
        return nil
    }
    
    public func presentTransitionCompletion(in galleryController: JoGalleryController, openAt indexPath: IndexPath) {
        
    }
    
    public func dismissForTransitioning(in galleryController: JoGalleryController, closeAt indexPath: IndexPath) -> JoGalleryLocationAttributes? {
        return nil
    }
    
    public func dismissTransitionCompletion(in galleryController: JoGalleryController, closeAt indexPath: IndexPath) {
        
    }
    
    public func gallery(_ galleryController: JoGalleryController, scrolDidDisplay cell: JoGalleryCell, forItemAt indexPath: IndexPath, oldItemFrom oldIndexPath: IndexPath) {
        
    }
    
    public func galleryBeginTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath) -> UIView? {
        return nil
    }
    
    public func galleryDidTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, isTouching : Bool, with thresholdValue: CGFloat) {
        
    }
    
    public func galleryDidEndTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, with thresholdValue: CGFloat) -> UIView? {
        return nil
    }
}

// MARK: JoGalleryImageView

public protocol JoGalleryImageViewDelegate: NSObjectProtocol {
    
    func galleryImageViewDidClick(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewDidLongPress(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewDidScroll(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewDidZoom(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewDidRotation(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewBeginTouching(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewWillEndTouch(_ galleryImageView: JoGalleryImageView)
    func galleryImageViewDidEndTouch(_ galleryImageView: JoGalleryImageView)
}

extension JoGalleryImageViewDelegate {
    
    public func galleryImageViewDidClick(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewDidLongPress(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewDidScroll(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewDidZoom(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewDidRotation(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewBeginTouching(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewWillEndTouch(_ galleryImageView: JoGalleryImageView) { }
    public func galleryImageViewDidEndTouch(_ galleryImageView: JoGalleryImageView) { }
}
