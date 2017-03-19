//
//  ViewController.swift
//  SkinTone
//
//  Created by Coty Embry on 12/17/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

import UIKit
import CoreGraphics

class ViewController: UIViewController {

    override func viewWillAppear(animated: Bool) {
        
        var dataProvider: CGDataProviderRef?
        var image: CGImageRef
        let dontCare: UnsafePointer<CGFloat> = nil

        dataProvider = CGDataProviderCreateWithFilename("brownImage");
        image = CGImageCreateWithPNGDataProvider(dataProvider, dontCare, false, .RenderingIntentDefault)!

        if(dataProvider == nil) {
            print("this is nil")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

