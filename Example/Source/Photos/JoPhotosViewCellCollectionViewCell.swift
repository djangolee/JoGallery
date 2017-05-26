//
//  JoPhotosViewCellCollectionViewCell.swift
//  Example
//
//  Created by django on 5/26/17.
//  Copyright © 2017 Django. All rights reserved.
//

import UIKit

class JoPhotosViewCellCollectionViewCell: UICollectionViewCell {
    let imageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: Setup

extension JoPhotosViewCellCollectionViewCell {
    
    fileprivate func setup() {
        setupVariable()
        setupUI()
        prepareLaunch()
    }
    
    private func setupVariable() {
        
    }
    
    private func prepareLaunch() {
        
    }
    
    private func setupUI() {
        
        setupImageView()
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        imageView.frame = contentView.bounds
    }
    
    private func setupImageView() {
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
    }
}
