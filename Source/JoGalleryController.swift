//
//  JoGalleryController.swift
//  JoGallery
//
//  Created by django on 5/17/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

open class JoGalleryController: UIViewController {
    
    // MARK: Member variable
    
    fileprivate var _currentIndexPath: IndexPath
    open var currentIndexPath: IndexPath {
        set {
            _currentIndexPath = newValue
            adjustScrollToItem(to: newValue)
        }
        get {
            return _currentIndexPath
        }
    }
    
    open var minimumLineSpacing: CGFloat
    open var backgroundView: UIView = UIView()
    open var closeZoomThresholdValue: CGFloat
    open var closeScrollThresholdValue: CGFloat
    open var maximumBodyOriginZoomScale: CGFloat = 2
    
    fileprivate let transitioning: JoGlleryTransitioning
    
    weak open var delegate: JoGalleryDelegate?
    weak open var dataSource: JoGalleryDataSource?
    weak open var transitioningAnimate: JoGalleryControllerAnimatedTransitioning? {
        get {
            return transitioning.transitioningDelegate
        }
        set {
            transitioning.transitioningDelegate = newValue
        }
    }
    
    fileprivate let collectionView: UICollectionView = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.minimumLineSpacing = 0
        flowLayout.minimumInteritemSpacing = 0
        flowLayout.scrollDirection = .horizontal
        return UICollectionView(frame: CGRect.zero, collectionViewLayout: flowLayout)
    }()
    
    // MARK: Life cycle

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        _currentIndexPath = IndexPath(item: 0, section: 0)
        minimumLineSpacing = 30
        closeZoomThresholdValue = 0.75
        closeScrollThresholdValue = 100
        transitioning = JoGlleryTransitioning()
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        self.transitioningDelegate = transitioning
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Self.view life cycle
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override open func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        adjustScrollToItem(to: currentIndexPath)
    }

    override open func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustScrollToItem(to: currentIndexPath)
    }
    
    override open var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .slide
    }
    
    override open var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override open var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
}

// MARK: Open

extension JoGalleryController {
    
    // For each reuse identifier that the collection view will use, register either a class from which to instantiate a cell.
    // If a class is registered, it must contain exactly 1 top level object which is a UICollectionViewCell, it will be instantiated via alloc/initWithFrame:
    
    open func register(_ cellClass: Swift.AnyClass, forCellWithReuseIdentifier identifier: String) {
        collectionView.register(cellClass, forCellWithReuseIdentifier: identifier)
    }
    
    open func dequeueReusableCell(withReuseIdentifier identifier: String, for indexPath: IndexPath) -> JoGalleryCell {
        return collectionView.dequeueReusableCell(withReuseIdentifier: identifier, for: indexPath) as! JoGalleryCell
    }
    
    open func reloadData() {
        collectionView.reloadData()
    }
    
    open func present(from viewControllerFromParent: UIViewController, toItem: IndexPath, completion: (() -> Swift.Void)? = nil) {
        _currentIndexPath = toItem
        adjustScrollToItem(to: toItem)
        
        if let delegate = delegate {
            let attributes = JoGalleryItemMotionStateAttributes(delegate.gallery(self, cellSizeForItemAt: toItem))
            transitioning.animationIndexPath(indexPath: toItem, attributes: attributes);
        } else {
            transitioning.animationIndexPath(indexPath: nil, attributes: nil)
        }
        
        viewControllerFromParent.present(self, animated: true, completion: completion)
    }
    
    open func prepareDismiss(_ galleryItemView: JoGalleryItemView, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {

        var attributes  = JoGalleryItemMotionStateAttributes(galleryItemView)
        attributes.alpha = backgroundView.alpha
        transitioning.animationIndexPath(indexPath: currentIndexPath, attributes: attributes)
        
        dismiss(animated: flag, completion: completion)
    }
    
}

// MARK: JoGalleryItemViewDelegate

extension JoGalleryController: JoGalleryItemViewDelegate {
    
    public func galleryItemViewDidClick(_ galleryItemView: JoGalleryItemView) {
        prepareDismiss(galleryItemView, animated: true)
    }
    
    public func galleryItemViewDidZoom(_ galleryItemView: JoGalleryItemView) {
        galleryDidTransforming(galleryItemView)
    }
    
    public func galleryItemViewDidScroll(_ galleryItemView: JoGalleryItemView) {
        galleryDidTransforming(galleryItemView)
    }
    
    public func galleryItemViewBeginTouching(_ galleryItemView: JoGalleryItemView) {
        delegate?.galleryBeginTransforming(in: self, atIndex: currentIndexPath)
    }
    
    public func galleryItemViewWillEndTouch(_ galleryItemView: JoGalleryItemView) {
        if backgroundView.alpha <= 0 {
            prepareDismiss(galleryItemView, animated: true)
        } else {
            delegate?.galleryDidEndTransforming(in: self, atIndex: currentIndexPath, with: backgroundView.alpha)
        }
    }
    
    public func galleryItemViewDidEndTouch(_ galleryItemView: JoGalleryItemView) {
        galleryDidTransforming(galleryItemView, didEnd: true)
    }
    
    private func galleryDidTransforming(_ galleryItemView: JoGalleryItemView, didEnd: Bool = false) {
        var zoomScale: CGFloat = 0
        var scrollScale: CGFloat = 0
        
        if didEnd {
            zoomScale = 1
            scrollScale = 1
        } else {
            if galleryItemView.zoomScale >= 1 {
                zoomScale = 1
            } else if (galleryItemView.zoomScale < closeZoomThresholdValue) {
                zoomScale = 0
            } else {
                zoomScale = (galleryItemView.zoomScale - closeZoomThresholdValue) / (1 - closeZoomThresholdValue)
            }
            if galleryItemView.offset.equalTo(CGPoint.zero) {
                scrollScale = 1
            } else if (closeScrollThresholdValue < fabs(galleryItemView.offset.y)) {
                scrollScale = 0
            } else {
                scrollScale = (closeScrollThresholdValue - fabs(galleryItemView.offset.y)) / closeScrollThresholdValue
            }
        }
        
        if self.backgroundView.alpha != min(zoomScale, scrollScale) {
            UIView.animate(withDuration: 0.25, animations: {
                self.backgroundView.alpha = min(zoomScale, scrollScale)
            })
        }
        
        delegate?.galleryDidTransforming(in: self, atIndex: currentIndexPath, isTouching: galleryItemView.isTouching, with: backgroundView.alpha)
    }
}

// MARK: CollectionView protocol

extension JoGalleryController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
     public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return UIApplication.shared.keyWindow?.bounds.size ?? CGSize.zero
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let dataSource = dataSource {
            return dataSource.galleryController(self, numberOfItemsInSection: section)
        } else {
            return 0
        }
    }
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        if let dataSource = dataSource {
            return dataSource.numberOfSections(in: self)
        } else {
            return 0
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = dataSource!.galleryController(self, cellForItemAt: indexPath)
        cell.minimumLineSpacing = minimumLineSpacing
        cell.containView.delegate = self
        cell.update(maxZoomScale: maximumBodyOriginZoomScale, originSize: delegate?.gallery(self, cellSizeForItemAt: indexPath) ?? CGSize.zero)
        return cell
    }
    
    public func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        adjustCurrentIndexPath()
    }
    
    func adjustCurrentIndexPath() {
        if let indexPath = currentIndexPathsForFullVisible(), indexPath != _currentIndexPath {
            let oldItem = _currentIndexPath
            _currentIndexPath = indexPath
            
            if let delegate = delegate, let cell = collectionView.cellForItem(at: currentIndexPath) as? JoGalleryCell {
                delegate.gallery(self, scrolDidDisplay: cell, forItemAt: currentIndexPath, oldItemFrom: oldItem)
            }
        }
    }
    
    func adjustScrollToItem(to indexPath: IndexPath) {
        
        if let frame = collectionView.collectionViewLayout.layoutAttributesForItem(at: indexPath)?.frame,
            let visibleIndexPath = currentIndexPathsForFullVisible(),
            indexPath != visibleIndexPath, !frame.equalTo(CGRect.zero) {
            
            collectionView.contentOffset = frame.origin
        }
    }
    
    func currentIndexPathsForFullVisible() -> IndexPath? {
        let inrect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        
        let indexPaths = collectionView.indexPathsForVisibleItems
        for indexPath in indexPaths {
            if let cell = collectionView.cellForItem(at: indexPath),
                inrect.contains(cell.frame) {
                return indexPath
            }
        }
        return nil
    }
}

// MARK: Setup

extension JoGalleryController {
    
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
        view.backgroundColor = .clear
        setupBackgroundView()
        setupCollection()
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        _ = {
            self.backgroundView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: self.backgroundView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        }()
        
        _ = {
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
            NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        }()
    }
    
    private func setupBackgroundView() {
        backgroundView.backgroundColor = .black
        view.addSubview(backgroundView)
    }
    
    private func setupCollection() {
        collectionView.backgroundColor = .clear
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.isPagingEnabled = true
        collectionView.bounces = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.showsHorizontalScrollIndicator = false
        view.addSubview(collectionView)
    }
}

