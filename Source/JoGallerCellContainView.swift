//
//  JoGallerCellContainView.swift
//  JoGallery
//
//  Created by Django Lee on 9/21/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit

public class JoGallerCellContainView: JoGalleryItemView {

    func update(maxZoomScale: CGFloat, originSize: CGSize) {
        self.maxZoomScale = maxZoomScale
        self.originSize = originSize
        setNeedsBodyUpdate()
    }
    
    private var maxZoomScale: CGFloat = 2
    private var originSize: CGSize = CGSize.zero
    
    public override var maximumBodyOriginZoomScale: CGFloat {
        get {
            return maxZoomScale
        }
    }
    
    public override var intrinsicBodyOriginSize: CGSize {
        get {
            return originSize
        }
    }
    
    
}
