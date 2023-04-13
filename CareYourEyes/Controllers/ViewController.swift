//
//  ViewController.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // Tell the camera view which orientation currently is
        let deviceOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .unknown
        if let cameraVC = segue.destination as? CameraViewController {
            cameraVC.deviceOrientation = deviceOrientation
        }
        
    }


}

