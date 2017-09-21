//
//  JOGalleryInternalStruct.swift
//  JoGallery
//
//  Created by Django Lee on 9/17/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit

public struct JoGalleryControllerContextTransitioning {
    
    public enum JoGalleryControllerContextTransitioningPushDirection {
        case present, dismiss
    }
    
    public let containerView: UIView
    public let fromView: UIView
    public let toView: UIView
    public let attributes: JoGalleryItemMotionStateAttributes
    public let direction: JoGalleryControllerContextTransitioningPushDirection
    
    internal init(_ container: UIView, _ frome: UIView, _ to: UIView, _ attributes: JoGalleryItemMotionStateAttributes, _ direction: JoGalleryControllerContextTransitioningPushDirection) {
        self.containerView = container
        self.fromView = frome
        self.toView = to
        self.attributes = attributes
        self.direction = direction
    }
    
    internal var completeTransitionBlackCall: ((_ didComplete: Bool) -> Void)?
    
    public func completeTransition(_ didComplete: Bool) {
        completeTransitionBlackCall?(didComplete)
    }
}

internal struct JoGalleryItemLayoutAttributes {
    
    let minimumZoomScale: CGFloat
    let maximumZoomScale: CGFloat
    let contentSize: CGSize
    let transform: CGAffineTransform
    let bodySizeBoundsSize: CGSize
    
    init(_ bodyOriginSize: CGSize, _ maxOriginZoomScale: CGFloat = 2) {
        
        let screenSize = UIScreen.main.bounds.size
        var screenAspectRatio = screenSize.width / screenSize.height
        screenAspectRatio = screenAspectRatio.isNaN ? 1 : screenAspectRatio
        
        var bodySize: CGSize = CGSize.zero
        var bodyAspectRatio = bodyOriginSize.width / bodyOriginSize.height
        bodyAspectRatio = bodyAspectRatio.isNaN ? 1 : bodyAspectRatio
        
        if bodyAspectRatio < screenAspectRatio {
            bodySize.height = screenSize.height < bodyOriginSize.height ? screenSize.height : bodyOriginSize.height
            bodySize.width = bodySize.height * bodyAspectRatio
        } else {
            bodySize.width = screenSize.width < bodyOriginSize.width ? screenSize.width : bodyOriginSize.width
            bodySize.height = bodySize.width / bodyAspectRatio
        }
        
        contentSize = CGSize(width: max(bodySize.width, screenSize.width), height: max(bodySize.height, screenSize.height))
        minimumZoomScale = 1
        maximumZoomScale = max(bodyOriginSize.width * maxOriginZoomScale / contentSize.width, 1.5)
        bodySizeBoundsSize = bodySize
        transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
    }
}

public struct JoGalleryItemMotionStateAttributes {

    public let contentSize: CGSize
    public let contentCenter: CGPoint
    public let transform: CGAffineTransform
    public var alpha: CGFloat
    
    init(_ item: JoGalleryItemView) {
        
        let rect = item.contentView.convert(item.contentView.bounds, to: item)
        
        alpha = 1
        contentSize = item.contentView.frame.size
        contentCenter = CGPoint(x: rect.midX, y: rect.midY)
        transform = item.scrollView.transform
    }
    
    init(_ bodyOriginSize: CGSize) {
        
        let layout = JoGalleryItemLayoutAttributes(bodyOriginSize)
        
        alpha = 1
        contentSize = layout.bodySizeBoundsSize
        contentCenter = CGPoint(x: layout.contentSize.width / 2, y: layout.contentSize.height / 2)
        transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
    }
}
