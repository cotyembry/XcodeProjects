//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

//needed to link my custom Objective-C classes
#import "OpenEarsWorkFiles.h"
#import "OpenEarsEventObserver.h"

//needed for the OELanguageModelGenerator
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>

//needed for OEPocketsphinxController (the controller that performs the speech recognition (this is probably important...)
#import <OpenEars/OEPocketsphinxController.h>
//also needed is the OEAcousticModel, but I already imported that above

//needed for OEEventsObserver (this class keeps the app continuously updated about the status of the listening session, among other things, via delegate callbacks
#import <OpenEars/OEEventsObserver.h>