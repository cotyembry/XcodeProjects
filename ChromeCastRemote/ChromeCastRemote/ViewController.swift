//
//  ViewController.swift
//  ChromeCastRemote
//
//  Created by Coty Embry on 11/27/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

import UIKit



class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Initially hide the Cast button.
        navigationItem.rightBarButtonItems = []
        
        
        // [START device-scanner]
        // Establish filter criteria.
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID: kReceiverAppID)
        
        // Initialize device scanner.
        deviceScanner = GCKDeviceScanner(filterCriteria: filterCriteria)
        if let deviceScanner = deviceScanner {
            deviceScanner.addListener(self)
            deviceScanner.startScan()
            deviceScanner.passiveScan = true
        }
        // [END device-scanner]
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

