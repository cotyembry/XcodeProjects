//
//  CreateTileSample.m
//  RemoteSMS!
//
//  Created by Coty Embry on 1/14/16.
//  Copyright © 2016 cotyembry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CreateTileSample.h"
#import <MicrosoftBandKit_iOS/MicrosoftBandKit_iOS.h>

#import "RemoteSMS_-Swift.h"


@implementation CreateTileSample

-(void) testing {
    NSLog(@"in createTileSample testing method");
}

- (void) createTile {

    
    
    //create the tile
    NSUUID *tileId = [NSUUID UUID];
    // create a new MSBTile
    
    // create the small and tile icons from UIImage
    // small icons are 24x24 pixels
    NSError *error;
    MSBIcon *smallIcon = [MSBIcon iconWithUIImage:[UIImage
                                                   imageWithContentsOfFile:@"small.png"] error:&error];
    if (error){
        // handle error
        NSLog(@"error in creating small icon");
    }
    // Tile icons are 46x46 pixels for Microsoft Band 1 and 48x48 pixels
    // for Microsoft Band 2.
    MSBIcon *tileIcon = [MSBIcon iconWithUIImage:[UIImage
                                                  imageWithContentsOfFile:@"tile.png"] error:&error];
    
    if (error){
        // handle error
        NSLog(@"error in creating large icon");
    }
    // Sample code uses random tileId, but you should persist the value
//    for your application's tileId.
    // create a new MSBTile
    MSBTile *tile = [MSBTile tileWithId:tileId name:@"sample"
                               tileIcon:tileIcon smallIcon:smallIcon error:&error];
    if (error){
        // handle error
        NSLog(@"error in creating tile");
    }
    // enable badging (the count of unread messages)
    tile.badgingEnabled = YES;
    
    
    
    
    //
    // Create a scrollable vertical panel that will hold 2 text messages.
    MSBPageScrollFlowPanel *panel = [[MSBPageScrollFlowPanel alloc]
                                     initWithRect:[MSBPageRect rectWithX:0 y:0 width:245 height:102]];
    panel.horizontalAlignment = MSBPageHorizontalAlignmentLeft;
    panel.verticalAlignment = MSBPageVerticalAlignmentTop;
    // Define symbolic constants for indexes to each layout that
    // the tile has. The index of the first layout is 0. Because
    // only 5 layouts are allowed, the max index value is 4.
    typedef enum LayoutIndex
    {
        LayoutIndexMessages = 0,
    } LayoutIndex;
    // Define symbolic constants to uniquely (within the
    // messages page) identify each of the elements of our layout
    // that contain content that the app will set
    // (that is, these Ids will be used when calling APIs
    // to set the page content).
    typedef enum MessagesPageElementId : uint16_t
    {
        MessagesPageElementId1 = 1, // Id for the 1st message text block
        MessagesPageElementId2 = 2, // Id for the 2nd message text block
    } MessagesPageElementId;
    // add the text block to contain the first message
    MSBPageWrappedTextBlock *textBlock1 = [[MSBPageWrappedTextBlock alloc]
                                           initWithRect:[MSBPageRect rectWithX:0 y:0 width:245 height:102]
                                           font:MSBPageWrappedTextBlockFontMedium];
    textBlock1.elementId = MessagesPageElementId1;
    textBlock1.margins = [MSBPageMargins marginsWithLeft:15 top:0 right:15
                                                  bottom:0];
    textBlock1.color = [MSBColor colorWithRed:0xFF green:0xFF blue:0xFF];
    textBlock1.autoHeight = YES;
    textBlock1.horizontalAlignment = MSBPageHorizontalAlignmentLeft;
    textBlock1.verticalAlignment = MSBPageVerticalAlignmentTop;
    [panel addElement:textBlock1];
    // add the text block to contain the second message
    MSBPageWrappedTextBlock *textBlock2 = [[MSBPageWrappedTextBlock alloc]
                                           initWithRect:[MSBPageRect rectWithX:0 y:0 width:245 height:102]
                                           font:MSBPageWrappedTextBlockFontMedium];
    
    
    textBlock2.elementId = MessagesPageElementId2;
    textBlock2.margins = [MSBPageMargins marginsWithLeft:15 top:0 right:15
                                                  bottom:0];
    textBlock2.color = [MSBColor colorWithRed:0xFF green:0xFF blue:0xFF];
    textBlock2.autoHeight = YES;
    textBlock2.horizontalAlignment = MSBPageHorizontalAlignmentLeft;
    textBlock2.verticalAlignment = MSBPageVerticalAlignmentTop;
    [panel addElement:textBlock2];
    // create the page layout
    MSBPageLayout *layout = [[MSBPageLayout alloc] init];
    layout.root = panel;
    
    // prerequisite: bandClient has successfully connected to a Band
    //[TileManager  ]
    
    //[self.client.tileManager addTile:tile completionHandler:^(NSError
    //                                                          *error){
    //    if (error){
            // add tile failed, handle error
    //    } }];
    //6. Set the content of the page on the Band.
    // create a new Guid for the messages page
    NSUUID *messagesPageId = [NSUUID UUID];
    // create the object that contains the page content to be set
    MSBPageWrappedTextBlockData *textData1 = [MSBPageWrappedTextBlockData
                                              pageWrappedTextBlockDataWithElementId:MessagesPageElementId1
                                              text:@"This is the text of the first message" error:&error];
    if (error) {
        // handle error
    }
    MSBPageWrappedTextBlockData *textData2 = [MSBPageWrappedTextBlockData
                                              pageWrappedTextBlockDataWithElementId:MessagesPageElementId2
                                              text:@"This is the text of the second message" error:&error];
    if (error)
    {
        // handle error
    }

    MSBPageData *pageData = [MSBPageData pageDataWithId:messagesPageId
                                            layoutIndex:LayoutIndexMessages value:@[textData1, textData2]];
    /*
    [self.client.tileManager setPages:@[pageData] tileId:tileId
                    completionHandler: ^(NSError *error){
                        if (error) {
                            // unable to set data to the Band
                        }
                    }];
    
*/
 
}

@end