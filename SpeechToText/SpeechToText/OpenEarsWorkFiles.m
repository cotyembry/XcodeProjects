//
//  test.m
//  SpeechToText
//
//  Created by Coty Embry on 12/25/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenEarsWorkFiles.h"
#import <OpenEars/OELanguageModelGenerator.h>
#import <OpenEars/OEAcousticModel.h>
#import <OpenEars/OEPocketsphinxController.h>


@implementation OpenEarsWorkFiles

- (void) lmg {
    
    OELanguageModelGenerator *languageModelGenerator = [[OELanguageModelGenerator alloc] init];
    NSArray *words = [NSArray arrayWithObjects:@"hello", @"turn on", nil];
    NSString *name = @"CotysCustomLanguageModelFile";
    NSError *error = [languageModelGenerator generateLanguageModelFromArray:words withFilesNamed:name forAcousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"]]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to create a Spanish language model instead of an English one.
    
    NSString *languageModelPath = nil;
    NSString *dictionaryPath = nil;
    
    if(error == nil) {
        NSLog(@"got here without error");
        languageModelPath = [languageModelGenerator pathToSuccessfullyGeneratedLanguageModelWithRequestedName:@"CotysCustomLanguageModelFile"];
        self.languageModelPath = languageModelPath;
        dictionaryPath = [languageModelGenerator pathToSuccessfullyGeneratedDictionaryWithRequestedName:@"CotysCustomLanguageModelFile"];
        self.dictionaryPath = dictionaryPath;
    } else {
        NSLog(@"got here with error");

        NSLog(@"Error: %@",[error localizedDescription]);
    }
}

- (void) psc {
    [[OEPocketsphinxController sharedInstance] setActive:TRUE error:nil];
    [[OEPocketsphinxController sharedInstance] startListeningWithLanguageModelAtPath: self.languageModelPath dictionaryAtPath: self.dictionaryPath acousticModelAtPath:[OEAcousticModel pathToModel:@"AcousticModelEnglish"] languageModelIsJSGF:NO]; // Change "AcousticModelEnglish" to "AcousticModelSpanish" to perform Spanish recognition instead of English.
}

@end