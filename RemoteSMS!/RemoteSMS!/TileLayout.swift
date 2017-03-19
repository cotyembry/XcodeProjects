//
//  TileLayout.swift
//  RemoteSMS!
//
//  Created by Coty Embry on 12/22/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//
//  TOFIX flags need to be fixed: they are to do with the enumerations and not hard coding them in. I can't figure out how to get the enumerations to work correctly

import Foundation

class TileLayout {
    
    var tileManagerInstance = TileManager()
    
    
    // Define symbolic constants to uniquely (within the
    // messages page) identify each of the elements of our layout
    // that contain content that the app will set
    // (that is, these Ids will be used when calling APIs
    // to set the page content).
    enum MessagesPageElementId : Int { //does this have to say : UInt16, RawRepresentable  (im going to remove it for now)
        
        //init?(rawValue: Self.RawValue)
        
        case MessagesPageElementId1 = 1 //MSBPageElementIdentifier. //1 // Id for the 1st message text block
        case MessagesPageElementId2 = 2 // Id for the 2nd message text block
    }
    
    // Define symbolic constants for indexes to each layout that
    // the tile has. The index of the first layout is 0. Because
    // only 5 layouts are allowed, the max index value is 4.
    enum LayoutIndex: UInt16 {
        case LayoutIndexFirst = 1
    }
    
    

    func createLayout() {
      /*
        // Create a scrollable vertical panel that will hold 2 text messages.
        let rectangle: MSBPageRect = MSBPageRect(x: 0, y: 0, width: 245, height: 102)
        let panel: MSBPageScrollFlowPanel = MSBPageScrollFlowPanel(rect: rectangle)
        panel.horizontalAlignment = MSBPageHorizontalAlignment.Left
        panel.verticalAlignment = MSBPageVerticalAlignment.Top
        
        
        //add the text block to contain the first message
        let fontType = MSBPageWrappedTextBlockFont.Medium
        let textBlock1: MSBPageWrappedTextBlock = MSBPageWrappedTextBlock.init(rect: rectangle, font: fontType)

        let tempOne: UInt16 = 1
        textBlock1.elementId = tempOne //TOFIX enumeration value where its not hard coded: MessagesPageElementId.MessagesPageElementId1

        textBlock1.margins = MSBPageMargins(left: 15, top: 0, right: 15, bottom: 0)
        textBlock1.color = MSBColor(red: 0xFF, green: 0xFF, blue: 0xFF)
        textBlock1.autoHeight = true
        textBlock1.horizontalAlignment = MSBPageHorizontalAlignment.Left
        textBlock1.verticalAlignment = MSBPageVerticalAlignment.Top
        
        panel.addElement(textBlock1)

        //add the text block to contain the second message
        let textBlock2: MSBPageWrappedTextBlock = MSBPageWrappedTextBlock.init(rect: rectangle, font: fontType)
        
        let tempTwo: UInt16 = 2
        textBlock2.elementId = tempTwo //TOFIX enumeration value where its not hard coded: MessagesPageElementId.MessagesPageElementId2
        
        
        textBlock2.margins = MSBPageMargins(left: 15, top: 0, right: 15, bottom: 0)
        textBlock2.color = MSBColor(red: 0xFF, green: 0xFF, blue: 0xFF)
        textBlock2.autoHeight = true
        textBlock2.horizontalAlignment = MSBPageHorizontalAlignment.Left
        textBlock2.verticalAlignment = MSBPageVerticalAlignment.Top
  
        panel.addElement(textBlock2)
        
        //now create the page layout
        let layout: MSBPageLayout = MSBPageLayout()
        layout.root = panel
        
//Create the Tile Section
        
        //add the layout to the tile after getting creating a new tile
        tileManagerInstance.createTile()
        let tile = tileManagerInstance.tile

        tile!.pageLayouts.addObject(layout)

        //update the self.tile in the tileManager since we just added a layout to the tile
        tileManagerInstance.tile = tile
        
        //add tile to band (make sure the Band is connected first
        tileManagerInstance.addTileToBand(tile, methodThatDidTheCalling: "TileLayout.createLayout()")

    */

    }

    func setPageContentForTileOnBand() {
        
        //create new UUID for the messages page
        let messagesPageId = NSUUID()
        
        //create the object that contains the page content to be set
        var textData1 = MSBPageWrappedTextBlockData()
        do {
            let uIntOne: UInt16 = 1
            //TOFIX: the elementId parameter should be an enumberation: .MessagesPageElementId1
            textData1 = try MSBPageWrappedTextBlockData(elementId: uIntOne, text: "This is the text of the first message")
        } catch {
            //handle error
            print("Error: could not add text data #1 to element: \(error)")
        }

        //create the object that contains the page content to be set
        var textData2 = MSBPageWrappedTextBlockData()
        do {
            let uIntTwo: UInt16 = 2
            //TOFIX: the elementId parameter should be an enumeration: .MessagesPageElementId2
            textData2 = try MSBPageWrappedTextBlockData(elementId: uIntTwo, text: "This is the text of the second message")
        } catch {
            //handle error
            print("Error: could not add text data #2 to element: \(error)")
        }

        //now that the content has been created, let's add it to the page
        //TOFIX: the layoutIndex: parameter should be enumerations .LayoutIndexFirst
        let testUInt: UInt = 1
        let pageData: MSBPageData = MSBPageData(id: messagesPageId, layoutIndex: testUInt, value: [textData1, textData2])

        //now it's time to get the Band and set the page just created to it (that's probably important...)
        var discoveredBands = BandManager.sharedInstance().attachedClients()
        let myBand = discoveredBands![0]
        myBand.tileManager.setPages([pageData], tileId: tileManagerInstance.tileId, completionHandler: {(error: NSError!) -> Void in
            
            if(error != nil) {
                //handle error
                print("Error when setting page to tile: \(error)")
            }
            
        })
        
    }
    
}