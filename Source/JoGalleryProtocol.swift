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
    
    func numberOfSections(in galleryController: JoGalleryController) -> Int
    
    func galleryController(_ galleryController: JoGalleryController, numberOfItemsInSection section: Int) -> Int
    func galleryController(_ galleryController: JoGalleryController, cellForItemAt indexPath: IndexPath) -> JoGalleryCell
}

extension JoGalleryDataSource {
    public func numberOfSections(in galleryController: JoGalleryController) -> Int {
        return 1
    }
}

public protocol JoGalleryDelegate: NSObjectProtocol {
    
    func gallery(_ galleryController: JoGalleryController, cellSizeForItemAt indexPath: IndexPath) -> CGSize
    func gallery(_ galleryController: JoGalleryController, scrolDidDisplay cell: JoGalleryCell, forItemAt indexPath: IndexPath, oldItemFrom oldIndexPath: IndexPath)

    func galleryBeginTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath)
    func galleryDidTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, isTouching : Bool, with thresholdValue: CGFloat)
    func galleryDidEndTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, with thresholdValue: CGFloat)
    
}

extension JoGalleryDelegate {
    
    public func gallery(_ galleryController: JoGalleryController, scrolDidDisplay cell: JoGalleryCell, forItemAt indexPath: IndexPath, oldItemFrom oldIndexPath: IndexPath) { }
    
    public func galleryBeginTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath) { }
    public func galleryDidTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, isTouching : Bool, with thresholdValue: CGFloat) { }
    public func galleryDidEndTransforming(in galleryController: JoGalleryController, atIndex indexPath: IndexPath, with thresholdValue: CGFloat) { }
}

// MARK: AnimatedTransitioning

public protocol JoGalleryControllerAnimatedTransitioning : NSObjectProtocol {
 
    func transitionDuration(using transitionContext: JoGalleryControllerContextTransitioning?, atIndex indexPath: IndexPath?) -> TimeInterval
    
    func animateTransition(using transitionContext: JoGalleryControllerContextTransitioning, atIndex indexPath: IndexPath)
}

extension JoGalleryControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: JoGalleryControllerContextTransitioning?, atIndex indexPath: IndexPath?) -> TimeInterval {
        return 0.25
    }
}

// MARK: JoGalleryItemView

public protocol JoGalleryItemViewDelegate: NSObjectProtocol {
    
    func galleryItemViewDidClick(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewDidLongPress(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewDidScroll(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewDidZoom(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewDidRotation(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewBeginTouching(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewWillEndTouch(_ galleryItemView: JoGalleryItemView)
    func galleryItemViewDidEndTouch(_ galleryItemView: JoGalleryItemView)
}

extension JoGalleryItemViewDelegate {
    
    public func galleryItemViewDidClick(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewDidLongPress(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewDidScroll(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewDidZoom(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewDidRotation(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewBeginTouching(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewWillEndTouch(_ galleryItemView: JoGalleryItemView) { }
    public func galleryItemViewDidEndTouch(_ galleryItemView: JoGalleryItemView) { }
}
