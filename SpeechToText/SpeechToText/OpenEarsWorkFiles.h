//
//  LanguageModelGenerator.h
//  SpeechToText
//
//  Created by Coty Embry on 12/25/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

#import <Foundation/Foundation.h>


#ifndef LanguageModelGenerator_h
#define LanguageModelGenerator_h

@interface OpenEarsWorkFiles : NSObject

@property (strong, nonatomic) NSString *languageModelPath;
@property (strong, nonatomic) NSString *dictionaryPath;

- (void) lmg; //LanguageModelGenerator
- (void) psc; //PocketsphinxController

@end


#endif /* LanguageModelGenerator_h */
