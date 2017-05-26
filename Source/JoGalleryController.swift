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
    
    weak open var delegate: JoGalleryDelegate?
    weak open var dataSource: JoGalleryDataSource?
    
    fileprivate weak var fromParent: UIViewController?
    fileprivate var isStatusBarHidden: Bool
    fileprivate let transitioning: JoGlleryTransitioning
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
        transitioning = JoGlleryTransitioning()
        closeZoomThresholdValue = 0.75
        closeScrollThresholdValue = 100
        isStatusBarHidden = true
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
    
    override open func setNeedsStatusBarAppearanceUpdate() {
        if self.backgroundView.alpha < 0.9 {
            self.isStatusBarHidden = self.fromParent?.prefersStatusBarHidden ?? self.isStatusBarHidden
        } else {
            self.isStatusBarHidden = true
        }
        super.setNeedsStatusBarAppearanceUpdate()
    }
    
    override open var prefersStatusBarHidden: Bool {
        return isStatusBarHidden
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
        
        isStatusBarHidden = viewControllerFromParent.prefersStatusBarHidden
        fromParent = viewControllerFromParent
        _currentIndexPath = toItem
        adjustScrollToItem(to: toItem)
        
        setParentLocationAttributes(toItem) { 
            viewControllerFromParent.present(self, animated: true) {
                if let completion = completion {
                    completion()
                }
                if let delegate = self.delegate {
                    delegate.presentTransitionCompletion(in: self, openAt: toItem)
                }
                self.setNeedsStatusBarAppearanceUpdate()
            }
        }
    }
    
    open func prepareDismiss(_ galleryImageView: JoGalleryImageView, animated flag: Bool, completion: (() -> Swift.Void)? = nil) {
        if let delegate = delegate, let location = delegate.presentForTransitioning(in: self, openAt: currentIndexPath) {
            transitioning.dismissLocationAttributes = location
            transitioning.dismissTransitionAttributes = galleryImageView.imageAttributes;
            transitioning.dismissTransitionAttributes?.alpha = backgroundView.alpha;
        } else {
            transitioning.dismissLocationAttributes = nil
            transitioning.dismissTransitionAttributes = nil;
        }
        
        dismiss(animated: flag) {
            if let completion = completion {
                completion()
            }
            if let delegate = self.delegate {
                delegate.dismissTransitionCompletion(in: self, closeAt: self.currentIndexPath)
            }
        }
    }
    
    private func setParentLocationAttributes(_ toItem: IndexPath, completion: @escaping () -> Swift.Void) {
        if let delegate = delegate, let location = delegate.presentForTransitioning(in: self, openAt: toItem) {
            let size = collectionView(collectionView, layout: collectionView.collectionViewLayout, sizeForItemAt: toItem)
            JoGalleryKit.image(location.content, resultHandler: { (image) in
                if let image = image {
                    self.transitioning.parentLocationAttributes = location
                    self.transitioning.parentTransitionAttributes = JoGalleryImageView.imageAttributes(image, with: size)
                    completion()
                } else {
                    self.transitioning.parentLocationAttributes = nil;
                    self.transitioning.parentTransitionAttributes = nil
                    completion()
                }
            })
        } else {
            transitioning.parentLocationAttributes = nil;
            transitioning.parentTransitionAttributes = nil
            completion()
        }
    }
}

// MARK: JoGalleryImageViewDelegate

extension JoGalleryController: JoGalleryImageViewDelegate {
    
    public func galleryImageViewDidClick(_ galleryImageView: JoGalleryImageView) {
        prepareDismiss(galleryImageView, animated: true)
    }
    
    public func galleryImageViewDidZoom(_ galleryImageView: JoGalleryImageView) {
        galleryDidTransforming(galleryImageView)
    }
    
    public func galleryImageViewDidScroll(_ galleryImageView: JoGalleryImageView) {
        galleryDidTransforming(galleryImageView)
    }
    
    public func galleryImageViewBeginTouching(_ galleryImageView: JoGalleryImageView) {
        if let delegate = delegate, let view = delegate.galleryBeginTransforming(in: self, atIndex: currentIndexPath) {
            view.isHidden = true
        }
    }
    
    public func galleryImageViewWillEndTouch(_ galleryImageView: JoGalleryImageView) {
        if backgroundView.alpha <= 0 {
            prepareDismiss(galleryImageView, animated: true)
        }
    }
    
    public func galleryImageViewDidEndTouch(_ galleryImageView: JoGalleryImageView) {
        galleryDidTransforming(galleryImageView, didEnd: true)
    }
    
    private func galleryDidTransforming(_ galleryImageView: JoGalleryImageView, didEnd: Bool = false) {
        var zoomScale: CGFloat = 0
        if galleryImageView.zoomScale >= 1 {
            zoomScale = 1
        } else if (galleryImageView.zoomScale < closeZoomThresholdValue) {
            zoomScale = 0
        } else {
            zoomScale = (galleryImageView.zoomScale - closeZoomThresholdValue) / (1 - closeZoomThresholdValue)
        }
        
        var scrollScale: CGFloat = 0
        if galleryImageView.offset.equalTo(CGPoint.zero) {
            scrollScale = 1
        } else if (closeScrollThresholdValue < fabs(galleryImageView.offset.y)) {
            scrollScale = 0
        } else {
            scrollScale = (closeScrollThresholdValue - fabs(galleryImageView.offset.y)) / closeScrollThresholdValue
        }
        
        if self.backgroundView.alpha != min(zoomScale, scrollScale) {
            UIView.animate(withDuration: 0.25, animations: { 
                self.backgroundView.alpha = min(zoomScale, scrollScale)
                self.setNeedsStatusBarAppearanceUpdate()
            }, completion: { (completion) in
                if let delegate = self.delegate, let view = delegate.galleryDidEndTransforming(in: self, atIndex: self.currentIndexPath, with: self.backgroundView.alpha), didEnd {
                    view.isHidden = false
                }
            })
        }
        
        if let delegate = self.delegate, !didEnd {
            delegate.galleryDidTransforming(in: self, atIndex: self.currentIndexPath, isTouching: galleryImageView.isTouching, with: self.backgroundView.alpha)
        }
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
        cell.contentImageView.delegate = self
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
            let top = NSLayoutConstraint(item: self.backgroundView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            let leadeing = NSLayoutConstraint(item: self.backgroundView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.backgroundView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            let trailting = NSLayoutConstraint(item: self.backgroundView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            self.view.addConstraints([top, leadeing, bottom, trailting])
        }()
        
        _ = {
            self.collectionView.translatesAutoresizingMaskIntoConstraints = false
            let top = NSLayoutConstraint(item: self.collectionView, attribute: .top, relatedBy: .equal, toItem: self.view, attribute: .top, multiplier: 1, constant: 0)
            let leadeing = NSLayoutConstraint(item: self.collectionView, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
            let bottom = NSLayoutConstraint(item: self.collectionView, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
            let trailting = NSLayoutConstraint(item: self.collectionView, attribute: .trailing, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
            self.view.addConstraints([top, leadeing, bottom, trailting])
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
        view.addSubview(collectionView)
    }
}

