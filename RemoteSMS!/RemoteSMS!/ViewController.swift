//
//  ViewController.swift
//  RemoteSMS!
//
//  Created by Coty Embry on 12/21/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//
//  TODO: if there isn't a bluetooth connection, handle this error on the app
//                              
//                      Right now the problem with the app probably lies in the setPageContentForTileOnBand() method... or possibly the createLayout() method.... For some reason the page layout isn't getting set up correctly

import UIKit

class ViewController: UIViewController {

    let bandManagerInstance = BandManager()
    
    //MARK: Outlets
    @IBOutlet weak var connectButton: UIButton!
    @IBOutlet weak var addTilesButton: UIButton!
    @IBOutlet weak var disconnectButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        //let tileManagerInstance1 = TileManager()
        //tileManagerInstance1.testing()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


    //MARK: Actions
    @IBAction func connectToBandButton(sender: UIButton) {
        let discoveredBands = BandManager.sharedInstance().attachedClients()
        BandManager.sharedInstance().connectClient(discoveredBands![0])
    }

    @IBAction func addTilesAction(sender: UIButton) {
        //let tileManager = TileManager()
        //tileManager.retrieveBandTilesAndCheckSpaceAndAddTileToBand()
    }
    
    @IBAction func disconnectAction(sender: UIButton) {
        let discoveredBands = BandManager.sharedInstance().attachedClients()
        BandManager.sharedInstance().disconnectClient(discoveredBands![0])
    }
}

