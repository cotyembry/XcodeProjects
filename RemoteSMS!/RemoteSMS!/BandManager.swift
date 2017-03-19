//
//
//  BandManager.swift
//  RemoteSMS!
//
//  Created by Coty Embry on 12/21/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//


//public let _SharedBandManagerInstance = BandManager()

@objc public class BandManager : NSObject, MSBClientManagerDelegate {
    //these firtst two classes create the shared instance singleton
    // swiftSharedInstance is not accessible from ObjC
    class var swiftSharedInstance: BandManager {
        struct Singleton {
            static let instance = BandManager()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    class func sharedInstance() -> BandManager {
        return BandManager.swiftSharedInstance
    }
    
    
    
    public var discoveredBands = [MSBClient]() //renamed from discoveredClients
    
    public var clientManager = MSBClientManager.sharedManager()
    
    public var tileManager = TileManager()
    
    /*
    class var sharedInstance: BandManager {
        return _SharedBandManagerInstance
    }
    */
    
    override init() {
        super.init()
        self.clientManager.delegate = self
    }

    func attachedClients() -> [MSBClient]? {
        if let manager = self.clientManager {
            self.discoveredBands = [MSBClient]()
            for client in manager.attachedClients() {
                self.discoveredBands.append(client as! MSBClient)
            }
        }
                
        return self.discoveredBands
    }

    
    func connectClient(client: MSBClient) {
        print("connecting")
        clientManager.connectClient(client)
    }
  
    func disconnectClient(client: MSBClient) {
        print("disconnecting")
        clientManager.cancelClientConnection(client)
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidConnect client: MSBClient!) {
        //handle connect event
        print("connected!!!")

        var tileLayout = TileLayout()
        tileLayout.createLayout()
        //now at this point the TileLayout class has already created the tile and added the layout to the tile at this point and updated the TileManager variable with the current version of the tile
        //it also added the layout to the tile
        
        //what's left is to set the content of the page that's within the tile
        tileLayout.setPageContentForTileOnBand()
    }
    
    public func clientManager(clientManager: MSBClientManager!, clientDidDisconnect client: MSBClient!) {
        //handle disconnect event
        print("disconnected...")
    }

    public func clientManager(clientManager: MSBClientManager!, client: MSBClient!, didFailToConnectWithError error: NSError!) {
        //handle failure event
        print("failed to connect for some reason")
    }


}

