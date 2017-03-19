//
//  TileManager.swift
//  RemoteSMS!
//
//  Created by Coty Embry on 12/21/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//  BTW... Jesus Saves
//
//  TODO: persist the myUUID for the tile application
//      : also implement a method to remove the tiles

private var discoveredBands: [MSBClient]? = BandManager.sharedInstance().attachedClients()

@objc public class TileManager : NSObject {
    
    
    func testing() {
        print("in tile manager testing")
        var myTestInstance = CreateTileSample()
        myTestInstance.testing()
    }
    
    
    
    //these firtst two classes create the shared instance singleton
    // swiftSharedInstance is not accessible from ObjC
    class var swiftSharedInstance: TileManager {
        struct Singleton {
            static let instance = TileManager()
        }
        return Singleton.instance
    }
    
    // the sharedInstance class method can be reached from ObjC
    class func sharedInstance() -> TileManager {
        return TileManager.swiftSharedInstance
    }
    
    
    public var tile: MSBTile?
    var myBand = discoveredBands![0]
    var tileId: NSUUID?
    
    func createTile() {
        
        //get list of application tiles already on the band using a swift closure
        myBand.tileManager.tilesWithCompletionHandler( {(tiles:[AnyObject]!, error: NSError!) -> Void in
            if((error) != nil) {
                //handle error
                print("Error in .tilesWithCompletionHandler: \(error)")
            }
        })
        
        //Determine if there is space for more tiles on the Band.
        myBand.tileManager.remainingTileCapacityWithCompletionHandler( { (tileCapacity: UInt, error: NSError!) -> Void in
            if((error) != nil) {
                //handle error
                print("Error in .remainingTileCapacityWithCompletionHandler: \(error)")
            }
        })

        //create a new tile
        //first I need to create the small and tile icons from UIImage
        //small icons are 24x24 pixels
        var smallIconUIImage : UIImage = UIImage(named:"tileImage")!
        
        //I have to do the following if a method throws an error
        var smallIcon: MSBIcon?
        do {
            smallIcon = try MSBIcon.init(UIImage: smallIconUIImage) //this creates the actual smallIcon with the UIImage I just created
        } catch {
            //handle error
            print("error was caught when trying to create the smallIcon in TileManager.swift: \(error)")
        }
        

        //The following section sets up the icon/pictures and finally creates new MSBtile
        
        //Tile icons are 46x46 pixels for Microsoft Band 1
        var tileUIImage: UIImage = UIImage(named:"tileIcon")!
        
        //I have to do the following if a method throws an error
        var tileIcon: MSBIcon?
        do {
            tileIcon = try MSBIcon.init(UIImage: tileUIImage) //this creates the actual tileIcon with the UIImage I just created
        } catch {
            //handle error
            print("error was caught when trying to create titleIcon in TileManager.swift: \(error)")
        }
        
        
        //now to finish up creating the tile
        var myUUID = NSUUID.init() //creates a random UUID, I should look into persisting this later
        //let's save this to the self instance as well:
        self.tileId = myUUID
        
        //create a new MSBTile
        var myTile: MSBTile?
        do {
            myTile = try MSBTile(id: myUUID, name: "cotysTile", tileIcon: tileIcon!, smallIcon: smallIcon!)
            
            //now that the tile has been successfully created, let's make it publically visible
            self.tile = myTile
        } catch {
            //handle error
            print("error while creating a new tile: \(error)")
        }

        // enable badging (the count of unread messages)
        myTile!.badgingEnabled = true
        
        
    }

    func addTileToBand(tileToAdd: MSBTile?, methodThatDidTheCalling methodName: String) {
        //finally! add created tile to the Band.
        if(tileToAdd != nil) {
            myBand.tileManager.addTile(tileToAdd, completionHandler: { (error: NSError!) -> Void in
                if(error != nil) {
                    //handle error
                    print("Error while adding the tile to the band: \(error)")
                }
            })
        }
        else {
            print("Error: the tile hasn't been created yet: methodThatDidTheCall -> \(methodName)")
        }
    }
    
    //TODO remove all application tiles
    
}