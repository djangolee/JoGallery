//
//  JoGalleryCell.swift
//  JoGallery
//
//  Created by django on 5/17/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

open class JoGalleryCell: UICollectionViewCell {
    
    // MARK: Member variable
    
    open let contentImageView = JoGalleryImageView()
    open var minimumLineSpacing: CGFloat = 0
    
    fileprivate var layoutCenterX: NSLayoutConstraint?
    fileprivate weak var collectionView: UICollectionView? {
        willSet {
            if let scrollView = collectionView {
                removeObserver(scrollView)
            }
            if let scrollView = newValue {
                addObserver(scrollView)
            }
        }
    }
    
    // MARK: Life cycle
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    deinit {
        if let collectionView = collectionView {
            removeObserver(collectionView)
        }
    }
    
    override open func didMoveToSuperview() {
        super.didMoveToSuperview()
        var next: UIResponder? = nil
        if let superview = superview {
            next = superview
            while true {
                if next is UICollectionView {
                    break
                } else if next == nil {
                    break
                } else {
                    next = next?.next
                }
            }
        }
        collectionView = next as? UICollectionView
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: About Observer

extension JoGalleryCell {
    
    static let contentOffsetKeyPath: String = "contentOffset"
    
    fileprivate func addObserver(_ scrollView: UIScrollView) {
        scrollViewDidScroll(scrollView)
        scrollView.addObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset), options: .new, context: nil)
    }
    
    fileprivate func removeObserver(_ scrollView: UIScrollView) {
        scrollView.removeObserver(self, forKeyPath: #keyPath(UIScrollView.contentOffset))
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let scrollView = collectionView {
            scrollViewDidScroll(scrollView)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let centerX = layoutCenterX else { return }
        var rect = CGRect.zero
        rect.origin = scrollView.contentOffset
        rect.size = scrollView.frame.size
        
        guard frame.intersects(rect) else {
            if centerX.constant != 0 {
                centerX.constant = 0
            }
            return
        }
        
        if rect.minX == frame.minX {
            centerX.constant = 0
        } else {
            let offset = (frame.minX - rect.minX) / frame.width * (minimumLineSpacing / 2)
            if !offset.isNaN {
                centerX.constant = offset
            }
        }
    }
}

// MARK: Setup

extension JoGalleryCell {
    
    fileprivate func setup() {
        setupVariable()
        setupUI()
        setupVariable()
    }
    
    private func setupVariable() {
        
    }
    
    private func setupUI() {
        preservesSuperviewLayoutMargins = false
        layoutMargins = .zero
        
        setupContentImageView()
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        contentImageView.translatesAutoresizingMaskIntoConstraints = false
        let centerX = NSLayoutConstraint(item: contentImageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0)
        let centerY = NSLayoutConstraint(item: contentImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: contentImageView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        let height = NSLayoutConstraint(item: contentImageView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        layoutCenterX = centerX
        addConstraints([centerX, centerY, width, height])
    }
    
    private func setupContentImageView() {
        addSubview(contentImageView)
    }
}
