//
//  JoNavigationController.swift
//  JoGallery
//
//  Created by django on 3/2/17.
//  Copyright © 2017 django. All rights reserved.
//

import UIKit

class JoNavigationController: UINavigationController {
    
    // MARK: Override
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    override var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return .portrait
    }
    
}

