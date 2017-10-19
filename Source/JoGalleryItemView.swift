//
//  JoGalleryItemView.swift
//  JoGallery
//
//  Created by django on 5/10/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import Photos

public class JoGalleryItemView: UIView {
    
    // MARK: Member variable
    
    fileprivate (set) var zoomScale: CGFloat
    fileprivate (set) var isRotating: Bool { didSet { if (isRotating) { isTouching = true } } }
    fileprivate (set) var isDragging: Bool { didSet { if (isDragging) { isTouching = true } } }
    fileprivate (set) var isZooming: Bool { didSet { if (isZooming) { isTouching = true } } }
    fileprivate (set) var isScrolling: Bool { didSet { if (isScrolling) { isTouching = true } } }
    fileprivate (set) var isTouching: Bool {
        didSet {
            if let delegate = delegate, oldValue == false, isTouching == true {
                delegate.galleryItemViewBeginTouching(self)
            }
        }
    }
    
    public weak var delegate: JoGalleryItemViewDelegate?
    public let contentView = UIImageView()
    public let scrollView = UIScrollView()
    
    fileprivate let containView = UIView()
    
    fileprivate weak var scrollViewPinchGestureRecognizer: UIPinchGestureRecognizer? {
        didSet {
            removeObserver(oldValue)
            addObserver(scrollViewPinchGestureRecognizer)
        }
    }
    
    open var offset: CGPoint {
        get {
            if isScrolling {
                return CGPoint(x: scrollView.center.x - bounds.width / 2, y: scrollView.center.y - bounds.height / 2)
            } else {
                return CGPoint.zero
            }
        }
    }
    
    open var maximumBodyOriginZoomScale: CGFloat {
        get {
            return 2
        }
    }
    
    open var intrinsicBodyOriginSize: CGSize {
        get {
            return CGSize.zero
        }
    }
    
    
    // MARK: Life cycle
    
    override public init(frame: CGRect) {
        isRotating = false
        isDragging = false
        isZooming = false
        isScrolling = false
        isTouching = false
        zoomScale = 1
        super.init(frame: frame)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        removeObserver(scrollViewPinchGestureRecognizer)
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        setNeedsBodyUpdate()
        reSetupFrameRotationForScroll(animation: false)
    }
}

// MARK: Distribution

extension JoGalleryItemView {
    
    var currentMotionState: JoGalleryItemMotionStateAttributes {
        get {
            return JoGalleryItemMotionStateAttributes(self)
        }
    }
    
    // This should be called whenever the return values for the view content status bar attributes have changed. If it is called from within an animation block, the changes will be animated along with the rest of the animation block.
    open func setNeedsBodyUpdate() {

        let layout = JoGalleryItemLayoutAttributes(intrinsicBodyOriginSize, maximumBodyOriginZoomScale)
        
        scrollView.zoomScale = 1
        scrollView.minimumZoomScale = layout.minimumZoomScale
        scrollView.maximumZoomScale = layout.maximumZoomScale
        scrollView.contentSize = layout.contentSize
        contentView.bounds.size = layout.bodySizeBoundsSize
        scrollView.transform = layout.transform
        
        adjustContentCenter()
    }
    
    fileprivate func reSetupFrameRotationForScroll(animation: Bool = false) {
        if animation {
            UIView.animate(withDuration: 0.25, animations: {
                self.reSetupFrameRotationForScroll()
            })
        } else {
            zoomScale = max(scrollView.minimumZoomScale, scrollView.zoomScale)
            setAnchorPoint(CGPoint(x: 0.5, y: 0.5), for: scrollView)
            scrollView.transform = CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: 0, ty: 0)
            scrollView.frame = bounds
            adjustContentCenter()
        }
    }
    
    fileprivate func setAnchorPoint(_ anchorPoint: CGPoint, for view: UIView) {
        var transition = CGPoint.zero
        let oldOrigin = view.frame.origin
        view.layer.anchorPoint = anchorPoint
        let newOrigin = view.frame.origin
        transition.x = newOrigin.x - oldOrigin.x
        transition.y = newOrigin.y - oldOrigin.y
        view.center = CGPoint(x: view.center.x - transition.x, y: view.center.y - transition.y);
    }
    
    fileprivate func adjustContentCenter() {
        var center = CGPoint.zero
        center.x = max(scrollView.contentSize.width, scrollView.bounds.width) / 2
        center.y = max(scrollView.contentSize.height, scrollView.bounds.height) / 2
        contentView.center = center
    }
}

// MARK: Handle methods

extension JoGalleryItemView: UIGestureRecognizerDelegate {
    
    @objc fileprivate func handleDoublePress(_ sender: UITapGestureRecognizer) {
        guard let view = sender.view, view == contentView else {
            return
        }

        let zoomScale = scrollView.zoomScale == scrollView.maximumZoomScale ? scrollView.minimumZoomScale : scrollView.maximumZoomScale
        let location = sender.location(in: view)
        var zoomRect = CGRect.zero
        zoomRect.size.width = contentView.frame.width / zoomScale
        zoomRect.size.height = contentView.frame.height / zoomScale
        zoomRect.origin.x = location.x - zoomRect.width / 2
        zoomRect.origin.y = location.y - zoomRect.height / 2
        scrollView.zoom(to: zoomRect, animated: true)
    }
    
    @objc fileprivate func handleRotation(_ sender: UIRotationGestureRecognizer) {
        guard let view = sender.view, view == scrollView else {
            return
        }
        
        switch sender.state {
        case .possible:
            break
        case .began:
            if scrollView.zoomScale <= scrollView.minimumZoomScale,
                sender.numberOfTouches >= 2,
                contentView.bounds.contains(sender.location(ofTouch: 0, in: contentView)),
                contentView.bounds.contains(sender.location(ofTouch: 1, in: contentView)) {
                
                let location1 = sender.location(ofTouch: 0, in: contentView)
                let location2 = sender.location(ofTouch: 1, in: contentView)
                let location = CGPoint(x: (location1.x + location2.x) / 2, y: (location1.y + location2.y) / 2)
                let anchorLocation = contentView.convert(location, to: scrollView)
                let anchor = CGPoint(x: anchorLocation.x / scrollView.frame.width, y: anchorLocation.y / scrollView.frame.height)
                setAnchorPoint(anchor, for: scrollView)
                isRotating = true
            }
            break
        case .changed:
            if isRotating {
                if sender.numberOfTouches >= 2 {
                    scrollView.transform = view.transform.rotated(by: sender.rotation)
                    adjustContentCenter()
                } else {
                    endTouch()
                }
            }
            break
        case .ended, .cancelled, .failed:
            if isRotating {
                endTouch()
            }
            break
        }
        sender.rotation = 0
    }
    
    @objc fileprivate func handlePan(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view, view == scrollView else {
            return
        }
        
        switch sender.state {
        case .possible:
            break
        case .began:
            if scrollView.zoomScale < scrollView.minimumZoomScale,
                sender.numberOfTouches >= 2,
                contentView.bounds.contains(sender.location(ofTouch: 0, in: contentView)),
                contentView.bounds.contains(sender.location(ofTouch: 1, in: contentView)) {
                
                isDragging = true
            }
            break
        case .changed:
            if isDragging {
                if sender.numberOfTouches >= 2 {
                    let translation = sender.translation(in: containView)
                    scrollView.center = CGPoint(x: scrollView.center.x + translation.x, y: scrollView.center.y + translation.y)
                } else {
                    endTouch()
                }
            }
            break
        case .ended, .cancelled, .failed:
            if isDragging {
                endTouch()
            }
            break
        }
        sender.setTranslation(CGPoint.zero, in: containView)
    }
    
    @objc fileprivate func handleScroll(_ sender: UIPanGestureRecognizer) {
        guard let view = sender.view, view == self else {
            return
        }
        
        switch sender.state {
        case .possible:
            break
        case .began:
            if zoomScale == 1 {
                isScrolling = true
            }
            break
        case .changed:
            if isScrolling {
                let translation = sender.translation(in: self)
                let scale = 1 - fabs(offset.y) / (bounds.height / 2)
                scrollView.transform = CGAffineTransform(scaleX: scale, y: scale)
                scrollView.center = CGPoint(x: scrollView.center.x + translation.x * scale * scale, y: scrollView.center.y + translation.y * scale * scale)
            }
            break
        case .ended, .cancelled, .failed:
            endTouch()
            break
        }
        if let delegate = delegate {
            delegate.galleryItemViewDidScroll(self)
        }
        sender.setTranslation(CGPoint.zero, in: self)
    }
    
    @objc fileprivate func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        guard let _ = sender.view, sender.state == .changed else {
            return
        }
        if let delegate = delegate {
            delegate.galleryItemViewDidLongPress(self)
        }
    }
    
    @objc fileprivate func handleSinglePress(_ sender: UITapGestureRecognizer) {
        guard let _ = sender.view else {
            return
        }
        if let delegate = delegate {
            delegate.galleryItemViewDidClick(self)
        }
    }
    
    @objc fileprivate func scrollViewZoomChangState(_ state: UIGestureRecognizerState) {
        switch state {
        case .possible, .began:
            isZooming = true
            break
        case .changed:
            break
        case .ended, .cancelled, .failed:
            endTouch()
            break
        }
    }
    
    override public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let scroll = gestureRecognizer as? UIPanGestureRecognizer , gestureRecognizers?.contains(gestureRecognizer) ?? false {
            let translation = scroll.translation(in: self)
            if fabs(translation.y) > fabs(translation.x), zoomScale == 1 {
                return true
            } else {
                return false
            }
        } else {
            return super.gestureRecognizerShouldBegin(gestureRecognizer)
        }
    }
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        
        var contains = false
        if scrollView.gestureRecognizers?.contains(gestureRecognizer) ?? false ||
            contentView.gestureRecognizers?.contains(gestureRecognizer) ?? false ||
            containView.gestureRecognizers?.contains(gestureRecognizer) ?? false {
            
            contains = true
        }
        
        var otherContains = false
        if scrollView.gestureRecognizers?.contains(otherGestureRecognizer) ?? false ||
            contentView.gestureRecognizers?.contains(otherGestureRecognizer) ?? false ||
            containView.gestureRecognizers?.contains(otherGestureRecognizer) ?? false {
            
            otherContains = true
        }
        return contains && otherContains
    }
    
}

// MARK: About Observer

extension JoGalleryItemView {
    
    fileprivate func addObserver(_ gestureRecognizer: UIGestureRecognizer?) {
        gestureRecognizer?.addObserver(self, forKeyPath: #keyPath(UIGestureRecognizer.state), options: .new, context: nil)
        if let gestureRecognizer = gestureRecognizer {
            isZooming = true
            scrollViewZoomChangState(gestureRecognizer.state)
        }
    }
    
    fileprivate func removeObserver(_ gestureRecognizer: UIGestureRecognizer?) {
        gestureRecognizer?.removeObserver(self, forKeyPath: #keyPath(UIGestureRecognizer.state))
    }
    
    override public func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if let object = object as? UIPinchGestureRecognizer {
            scrollViewZoomChangState(object.state)
        }
    }
}

// MARK: UIScrollViewDelegate

extension JoGalleryItemView: UIScrollViewDelegate {
    
    public func scrollViewWillBeginZooming(_ scrollView: UIScrollView, with view: UIView?) {
        if let gestureRecognizers = scrollView.gestureRecognizers {
            for gestureRecognizer in gestureRecognizers {
                if gestureRecognizer is UIPinchGestureRecognizer {
                    scrollViewPinchGestureRecognizer = gestureRecognizer as? UIPinchGestureRecognizer
                }
            }
        }
    }
    
    public func scrollViewDidEndZooming(_ scrollView: UIScrollView, with view: UIView?, atScale scale: CGFloat) {
        endTouch()
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        adjustContentCenter()
        if scrollView.isZooming {
            zoomScale = scrollView.zoomScale
        }
        
        if let delegate = delegate {
            delegate.galleryItemViewDidZoom(self)
        }
    }
    
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return contentView
    }
    
    func checkEndTouching(_ finishEnd: () -> Void) {
        if !isZooming, !isDragging, !isRotating, !isScrolling, isTouching {
            finishEnd()
        }
    }
    
    func endTouch() {
        
        if isZooming || isDragging || isRotating || isScrolling, isTouching {
            if let delegate = delegate {
                delegate.galleryItemViewWillEndTouch(self)
            }
        }
        
        isRotating = false
        isDragging = false
        isZooming = false
        isScrolling = false
        
        if isTouching {
            isTouching = false
            reSetupFrameRotationForScroll(animation: true)
            if let delegate = delegate {
                delegate.galleryItemViewDidEndTouch(self)
            }
        }
    }
}

extension JoGalleryItemView {
    
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
        
        clipsToBounds = true
        setupContainView()
        setupScrollView()
        setupContentView()
        bindingSubviewsLayout()
        bindingCustomGestureRecognizer()
    }
    
    private func bindingSubviewsLayout() {
        
        containView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint(item: containView, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containView, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containView, attribute: .bottom, relatedBy: .equal, toItem: self, attribute: .bottom, multiplier: 1, constant: 0).isActive = true
        NSLayoutConstraint(item: containView, attribute: .trailing, relatedBy: .equal, toItem: self, attribute: .trailing, multiplier: 1, constant: 0).isActive = true
        
    }
    
    private func setupContainView() {
        
        addSubview(containView)
    }

    private func setupScrollView() {
        
        scrollView.delegate = self
        scrollView.clipsToBounds = false
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        containView.addSubview(scrollView)
    }
    
    private func setupContentView() {
        
        contentView.contentMode = .scaleAspectFill
        scrollView.addSubview(contentView)
    }
    
    private func bindingCustomGestureRecognizer() {
        
        contentView.isUserInteractionEnabled = true
        let double = UITapGestureRecognizer(target: self, action: #selector(handleDoublePress(_:)))
        double.delegate = self
        double.numberOfTapsRequired = 2
        contentView.addGestureRecognizer(double)
        
        let long = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        long.delegate = self
        long.minimumPressDuration = 1
        contentView.addGestureRecognizer(long)
        
        let rotation = UIRotationGestureRecognizer(target: self, action: #selector(handleRotation(_:)))
        rotation.delegate = self
        scrollView.addGestureRecognizer(rotation)

        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        pan.delegate = self
        pan.minimumNumberOfTouches = 2
        pan.maximumNumberOfTouches = 2
        scrollView.addGestureRecognizer(pan)
        
        let scroll = UIPanGestureRecognizer(target: self, action: #selector(handleScroll(_:)))
        scroll.delegate = self
        scroll.minimumNumberOfTouches = 1
        scroll.maximumNumberOfTouches = 1
        addGestureRecognizer(scroll)

//        let single = UITapGestureRecognizer(target: self, action: #selector(handleSinglePress(_:)))
//        single.delegate = self
//        single.numberOfTapsRequired = 1
//        addGestureRecognizer(single)
//        single.require(toFail: double)
    }
}
