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
    
    // MARK: Member variable
    
    let button = UIButton(type: .system)
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        setup()
    }

}

// MARK: Touch methods

extension JoViewController {
    @objc fileprivate func onClickButton(_ sender: UIButton) {
        self.navigationController?.pushViewController(JoPhotosViewController(), animated: true)
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
        
        setupButton()
        bindingSubviewsLayout()
    }
    
    private func bindingSubviewsLayout() {
        _ = {
            button.translatesAutoresizingMaskIntoConstraints = false
            let centerX = NSLayoutConstraint(item: button, attribute: .centerX, relatedBy: .equal, toItem: view, attribute: .centerX, multiplier: 1, constant: 0)
            let centerY = NSLayoutConstraint(item: button, attribute: .centerY, relatedBy: .equal, toItem: view, attribute: .centerY, multiplier: 1, constant: 0)
            view.addConstraints([centerX, centerY])
        }()
    }
    
    private func setupButton() {
        button.setTitle("iPhone Photos", for: .normal)
        button.addTarget(self, action: #selector(onClickButton(_:)), for: .touchUpInside)
        button.layer.cornerRadius = 3
        button.layer.borderWidth = 1
        button.layer.borderColor = button.titleLabel?.textColor.cgColor
        button.contentEdgeInsets = UIEdgeInsets(top: 20, left: 25, bottom: 20, right: 25)
        view.addSubview(button)
    }
}
