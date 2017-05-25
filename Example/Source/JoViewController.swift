//
//  JoViewController.swift
//  JoGallery
//
//  Created by django on 3/2/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit
import JoGallery

class JoViewController: UIViewController {
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }

}


// MARK: Setup

extension JoViewController {
    
    fileprivate func setup() {
        setupVariable()
        setupUI()
        prepareLaunch()
    }
    
    private func setupVariable() {
        title = "Example"
        
    }
    
    private func prepareLaunch() {
        view.backgroundColor = .white
    }
    
    private func setupUI() {
        
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        
    }
}
