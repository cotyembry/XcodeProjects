//
//  OpenEarsEventObserver.h
//  SpeechToText
//
//  Created by Coty Embry on 12/25/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

#import <OpenEars/OEEventsObserver.h>

#ifndef OpenEarsEventObserver_h
#define OpenEarsEventObserver_h

@interface OpenEarsEventObserver : NSObject <OEEventsObserverDelegate>

@property (strong, nonatomic) OEEventsObserver *openEarsEventsObserver;

- (void) pocketsphinxDidReceiveHypothesis:(NSString *)hypothesis recognitionScore:(NSString *)recognitionScore utteranceID:(NSString *)utteranceID;

- (void) pocketsphinxDidStartListening;

- (void) pocketsphinxDidDetectSpeech;

- (void) pocketsphinxDidDetectFinishedSpeech;

- (void) pocketsphinxDidStopListening;

- (void) pocketsphinxDidSuspendRecognition;

- (void) pocketsphinxDidResumeRecognition;

- (void) pocketsphinxDidChangeLanguageModelToFile:(NSString *)newLanguageModelPathAsString andDictionary:(NSString *)newDictionaryPathAsString;

- (void) pocketSphinxContinuousSetupDidFailWithReason:(NSString *)reasonForFailure;

- (void) pocketSphinxContinuousTeardownDidFailWithReason:(NSString *)reasonForFailure;

- (void) testRecognitionCompleted;

@end

#endif /* OpenEarsEventObserver_h */
