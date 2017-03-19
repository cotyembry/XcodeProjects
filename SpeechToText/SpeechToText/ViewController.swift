//
//  ViewController.swift
//  SpeechToText
//
//  Created by Coty Embry on 12/25/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

//  TODO: Lookup what nil means in Objective-C versus nil in Swift
//      : also make sure a property in Objective-C is the same as just a variable in Swift (this is necessary to know for the property of the OEEventsObserver which will be the delegate
//  
//      : also make sure I'm initializing the properties correctly. Should I use ClassName() or ClassName.init() or something else
//  The error seems to be coming from line 38 when I'm generating the Language Model

import UIKit


//instead of using NSArray, I used type Array... let's hope it still works since I've read Swift's Array is bridged with NSArray I would think it will still work (whatever bridged means...)


class ViewController: UIViewController, OEEventsObserverDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        //This is needed to set the OEEventsObserver Delegate
//        var openEarsEventsObserver: OEEventsObserver = OEEventsObserver()
//        openEarsEventsObserver.delegate = self
        
        
//Step 1. set up OELanguageModelGenerator
        var languageModelGeneratorInstance = OpenEarsWorkFiles()
        //create language model - or grammar - (needed for offline speech recognition): this defines vocabulary that the app can recognize
        languageModelGeneratorInstance.lmg()

//        let languageModelGenerator: OELanguageModelGenerator = OELanguageModelGenerator()
//        var words: [AnyObject]  = Array(arrayLiteral: ["send", "yes"]) //in the documentation, they put nil as the last parameter... I'm not sure why

//        let name: String? = "CotysCustomLanguageModelFile" //this will be the name for the language model files
        
//        let error: NSError? = languageModelGenerator.generateLanguageModelFromArray(words, withFilesNamed: name!, forAcousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish") )



//        var languageModelPath: String?
//        var dictionaryPath: String?
/*
        if(error == nil) {
            languageModelPath = languageModelGenerator.pathToSuccessfullyGeneratedLanguageModelWithRequestedName(name)
        
            dictionaryPath = languageModelGenerator.pathToSuccessfullyGeneratedDictionaryWithRequestedName(name)
        }
        else {
            //handle error
            print("Error: Could not create Language Model -> \(error)")
        }
*/
//Done with Step 1.
        
//Step 2. set up OEPocketsphinxController (the class that performs speech recognition)
        //pre-reqs: a language model and a phonetic dictionary for it. These files define which words OEPocketsphinxController is capable of recognizing. (they were just created above in step 1 with the OELanguageModelGenerator. Yay!
        //also needed: an acoustic model. OpenEars ships with an English (and Spanish) acoustic model
        
        languageModelGeneratorInstance.psc()
        
/*
        do {
            try OEPocketsphinxController.sharedInstance().setActive(true)
        } catch {
            print("Error: OEPocketsphinxController.sharedInstance().setActive(true) threw error -> \(error)")
        }
        
        OEPocketsphinxController.sharedInstance().startListeningWithLanguageModelAtPath(languageModelGeneratorInstance.languageModelPath, dictionaryAtPath: languageModelGeneratorInstance.dictionaryPath, acousticModelAtPath: OEAcousticModel.pathToModel("AcousticModelEnglish"), languageModelIsJSGF: false) //in the documentation, it doesn't explain what the last parameter is for
*/  

//Step 3. Implement the OEEventsObserver delegate methods to handle the status's of the listening session
/*
        func pocketsphinxDidReceiveHypothesis(hypothesis: String!, recognitionScore: String!, utteranceID: String!) {
            print("The received hypothesis is -> \(hypothesis) with a score of \(recognitionScore) and an Id of \(utteranceID)")
        }
        
        func pocketsphinxDidStartListening() {
            print("Pocketsphinx is now listening")
        }
        
        func pocketsphinxDidDetectSpeech() {
            print("Pocketsphinx has detectd speech")
        }
        
        func pocketsphinxDidDetectFinishedSpeech() {
            print("Pocketsphinx has detected a period of silence, concluding an utterance")
        }

        func pocketsphinxDidStopListening() {
            print("Pocketsphinx has stopped listening")
        }
        
        func pocketsphinxDidSuspendRecognition() {
            print("Pocketsphinx has suspended recognition")
        }
        
        func pocketsphinxDidResumeRecognition() {
            print("Pocketsphinx did resume recognition")
        }
        
        func pocketsphinxDidChangeLanguageModelToFile(newLanguageModelPathAsString: String!, andDictionary: String!) {
            print("Pocketsphinx is now using the following language model:\n\(newLanguageModelPathAsString) and the following dictionary: \(andDictionary)")
        }
        
        func pocketSphinxContinuousSetupDidFailWithReason(reasonForFailure: String!) {
            print("Listening setup wasn't successful and returned the failure reason \(reasonForFailure)")
        }
        
        func pocketSphinxContinuousTeardownDidFailWithReason(reasonForFailure: String!) {
            print("Listening teardown wasn't successful and returned the failure reason: \(reasonForFailure)")
        }
        
        func testRecognitionCompleted() {
            print("A test file that was submitted for recognition is now complete.")
        }
*/
        var x = 0
        while(x < 15) {
            print("still running")
            x++
            sleep(3)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

