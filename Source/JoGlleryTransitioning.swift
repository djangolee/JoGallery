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
    
    weak var transitioningDelegate: JoGalleryControllerAnimatedTransitioning?
    
    var animateIndexPath: IndexPath?
    var animateAttributes: JoGalleryItemMotionStateAttributes?
    
    fileprivate weak var presented: UIViewController?
    fileprivate weak var presenting: UIViewController?
    fileprivate weak var dismissed: UIViewController?
    
    
    func animationIndexPath(indexPath: IndexPath?, attributes: JoGalleryItemMotionStateAttributes?) {
        animateIndexPath = indexPath
        animateAttributes = attributes
    }
    
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
    
    // MARK: UIViewControllerAnimatedTransitioning
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        if let delegate = transitioningDelegate, let indexpath = animateIndexPath {
            return delegate.transitionDuration(using: nil, atIndex: indexpath)
        } else {
            return 0.25
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {

        guard let _ = transitioningDelegate,
            let toViewController = transitionContext.viewController(forKey: .to),
            let fromViewController = transitionContext.viewController(forKey: .from) else {
                
                transitionContext.completeTransition(true)
                animateIndexPath = nil
                animateAttributes = nil
                return
        }
        
        if let _ = presented, let _ = presenting {
            presentOfAnimateTransition(using: transitionContext, fromVC: fromViewController, toVC: toViewController)
        } else if let _ = dismissed {
            dismissOfAnimateTransition(using: transitionContext, fromVC: fromViewController, toVC: toViewController)
        } else {
            noneTransitionOfAnimateTransition(using: transitionContext)
        }
        animateIndexPath = nil
        animateAttributes = nil
    }
    
    private func presentOfAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        guard let keyWindow = UIApplication.shared.keyWindow,
            let fromView = fromVC.view,
            let toView = toVC.view,
            let delegate = transitioningDelegate,
            let indexPath = animateIndexPath,
            let attributes = animateAttributes else {
                
                noneTransitionOfAnimateTransition(using: transitionContext)
                return
        }
        
        let containerView = transitionContext.containerView
        
        var context = JoGalleryControllerContextTransitioning(containerView, fromView, toView, attributes, .present)
        context.completeTransitionBlackCall = { (didComplete) in
            context.completeTransitionBlackCall = nil
            containerView.insertSubview(toView, belowSubview: containerView)
            transitionContext.completeTransition(didComplete)
            keyWindow.insertSubview(fromView, belowSubview: containerView)
        }
        delegate.animateTransition(using: context, atIndex: indexPath)
    }
    
    private func dismissOfAnimateTransition(using transitionContext: UIViewControllerContextTransitioning, fromVC: UIViewController, toVC: UIViewController) {
        
        guard let fromView = fromVC.view,
            let toView = toVC.view,
            let delegate = transitioningDelegate,
            let indexPath = animateIndexPath,
            let attributes = animateAttributes else {
                
                noneTransitionOfAnimateTransition(using: transitionContext)
                return
        }
        let containerView = transitionContext.containerView
        
        var context = JoGalleryControllerContextTransitioning(containerView, fromView, toView, attributes, .dismiss)
        context.completeTransitionBlackCall = { (didComplete) in
            context.completeTransitionBlackCall = nil
            transitionContext.completeTransition(didComplete)
        }
        delegate.animateTransition(using: context, atIndex: indexPath)
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
            UIView.animate(withDuration: transitionDuration(using: nil), animations: {
                toViewController?.view.alpha = 1
            })
        } else if self.dismissed == fromViewController {
            
            UIView.animate(withDuration: transitionDuration(using: nil), animations: {
                fromView.alpha = 0
            }, completion: { (completion) in
                transitionContext.completeTransition(true)
            })
        }
    }

}
