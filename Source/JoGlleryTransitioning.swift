//
//  JoGlleryTransitioning.swift
//  JoGallery
//
//  Created by django on 5/18/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import Photos

class JoGlleryTransitioning: NSObject {
    
    open var parentLocationAttributes: JoGalleryDelegate.JoGalleryLocationAttributes?
    open var dismissLocationAttributes: JoGalleryDelegate.JoGalleryLocationAttributes?
    
    open var parentTransitionAttributes: UICollectionViewLayoutAttributes?
    open var dismissTransitionAttributes: UICollectionViewLayoutAttributes?
    
    fileprivate weak var presented: UIViewController?
    fileprivate weak var presenting: UIViewController?
    fileprivate weak var dismissed: UIViewController?
    
    fileprivate var presentedImage: UIImage?
    fileprivate var dismissedImage: UIImage?
}

extension JoGlleryTransitioning: UIViewControllerTransitioningDelegate, UIViewControllerAnimatedTransitioning {
    
    // MARK: UIViewControllerTransitioningDelegate
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presented = presented
        self.presenting = presenting
        self.dismissed = nil
        return self
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self.presented = nil
        self.presenting = nil
        self.dismissed = dismissed
        return self
    }
    
    static let transitionDuration: TimeInterval = 0.25
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return JoGlleryTransitioning.transitionDuration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else {
                
                transitionContext.completeTransition(true)
                return
        }
        
        if let _ = presented, let _ = presenting, let parentLocationAttributes = parentLocationAttributes, let parentTransitionAttributes = parentTransitionAttributes {
            JoGalleryKit.default.image(parentLocationAttributes.content, resultHandler: { (image) in
                self.presentedImage = image
                self.presentOfAnimateTransition(using: transitionContext, fromVC: fromViewController, toVC: toViewController, location: parentLocationAttributes, transition: parentTransitionAttributes)
            })
        } else if let _ = dismissed, let dismissLocationAttributes = dismissLocationAttributes, let dismissTransitionAttributes = dismissTransitionAttributes {
            JoGalleryKit.default.image(dismissLocationAttributes.content, resultHandler: { (image) in
                self.dismissedImage = image
                self.dismissOfAnimateTransition(using: transitionContext, fromVC: fromViewController, toVC: toViewController, location: dismissLocationAttributes, transition: dismissTransitionAttributes)
            })
        } else {
            transitionContext.completeTransition(true)
        }
    }
    
    func addNavigationBarMaskView(_ viewController: UIViewController, containerView: UIView) -> (lastView: UIView, navigationMaskView: UIView?) {
        
        if let navigationController = viewController as? UINavigationController, let lastVC = navigationController.viewControllers.last {
            let navigationMaskView = UIView(frame: navigationController.navigationBar.frame)
            navigationMaskView.backgroundColor = .black
            if navigationMaskView.frame.origin.y != 0 {
                navigationMaskView.frame.size.height = 64
                navigationMaskView.frame.origin.y = 0
            }
            containerView.addSubview(navigationMaskView)
            return (lastVC.view, navigationMaskView)
        } else {
            return (viewController.view, nil)
        }
    }
    
    private func presentOfAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, location: JoGalleryDelegate.JoGalleryLocationAttributes, transition: UICollectionViewLayoutAttributes) {
        
        guard  let fromView = fromVC.view, let toView = toVC.view, let keyWindow = UIApplication.shared.keyWindow else {
            transitionContext.completeTransition(true)
            return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        transitionContext.completeTransition(true)
        keyWindow.insertSubview(fromView, belowSubview: containerView)
        
        let temp = addNavigationBarMaskView(fromVC, containerView: containerView)
        let presentedView = temp.lastView
        let navigationMaskView = temp.navigationMaskView
        toView.isHidden = true
        navigationMaskView?.alpha = 0
        
        _ = {
            let maskView = UIView(frame: fromView.bounds)
            maskView.backgroundColor = .black
            maskView.alpha = 0
            
            let imageView = UIImageView()
            imageView.clipsToBounds = location.location.clipsToBounds
            imageView.layer.masksToBounds = location.location.layer.masksToBounds
            imageView.contentMode = location.location.contentMode
            imageView.frame = location.location.convert(location.location.bounds, to: fromView)
            imageView.image = presentedImage
            
            presentedView.addSubview(maskView)
            presentedView.addSubview(imageView)

            location.location.isHidden = true
            
            UIView.animate(withDuration: 0.25, animations: { 
                imageView.bounds.size = transition.size
                imageView.center = transition.center
                maskView.alpha = 1
                navigationMaskView?.alpha = 1
            }, completion: { (completion) in
                toView.isHidden = false
                location.location.isHidden = false
                navigationMaskView?.removeFromSuperview()
                maskView.removeFromSuperview()
                imageView.removeFromSuperview()
            })
        }()
    }
    
    private func dismissOfAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController, location: JoGalleryDelegate.JoGalleryLocationAttributes, transition: UICollectionViewLayoutAttributes) {
        
        guard  let fromView = fromVC.view, let toView = toVC.view else {
            transitionContext.completeTransition(true)
            return
        }
        
        let containerView = transitionContext.containerView
        let temp = addNavigationBarMaskView(toVC, containerView: containerView)
        let presentedView = temp.lastView
        let navigationMaskView = temp.navigationMaskView
        navigationMaskView?.alpha = transition.alpha
        
        _ = {
            
            let maskView = UIView(frame: fromView.bounds)
            maskView.backgroundColor = .black
            maskView.alpha = transition.alpha
            
            let imageView = UIImageView()
            imageView.clipsToBounds = location.location.clipsToBounds
            imageView.layer.masksToBounds = location.location.layer.masksToBounds
            imageView.contentMode = location.location.contentMode
            imageView.frame.size = transition.size
            imageView.center = transition.center
            imageView.transform = transition.transform
            imageView.image = dismissedImage
            
            presentedView.addSubview(maskView)
            presentedView.addSubview(imageView)
            
            fromView.isHidden = true
            location.location.isHidden = true
            UIView.animate(withDuration: 0.25, animations: {
                maskView.alpha = 0
                navigationMaskView?.alpha = 0
                imageView.transform = location.location.transform
                imageView.frame = location.location.convert(location.location.bounds, to: toView)
            }, completion: { (completion) in
                fromView.isHidden = false
                location.location.isHidden = false
                
                navigationMaskView?.removeFromSuperview()
                maskView.removeFromSuperview()
                imageView.removeFromSuperview()
                transitionContext.completeTransition(true)
                self.freeResource()
            })
        }()
    }

    private func noneTransitionOfAnimateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let toViewController = transitionContext.viewController(forKey: .to)
        let fromViewController = transitionContext.viewController(forKey: .from)
        let keyWindow = UIApplication.shared.keyWindow
        
        guard  let toView = toViewController?.view, let fromView = fromViewController?.view else {
            transitionContext.completeTransition(true)
            return
        }
        
        if presented == toViewController && self.presenting == fromViewController {
            toViewController?.view.alpha = 0
            containerView.addSubview(toView)
            transitionContext.completeTransition(true)
            keyWindow?.insertSubview(fromView, belowSubview: containerView)
            UIView.animate(withDuration: JoGlleryTransitioning.transitionDuration, animations: {
                toViewController?.view.alpha = 1
            })
        } else if self.dismissed == fromViewController {
            UIView.animate(withDuration: JoGlleryTransitioning.transitionDuration, animations: {
                fromView.alpha = 0
            }, completion: { (completion) in
                transitionContext.completeTransition(true)
                self.freeResource()
            })
        }
    }
    
    private func freeResource() {
        parentLocationAttributes = nil
        dismissLocationAttributes = nil
        
        parentTransitionAttributes = nil
        dismissTransitionAttributes = nil
        
        presented = nil
        presenting = nil
        dismissed = nil
    }
    
}
