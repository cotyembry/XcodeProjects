//
//  ViewController.swift
//  CastRemote
//
//  Created by Coty Embry on 12/2/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

/*

    TODO: separate this code out so that it isnt all crammed into this ViewController.swift file

    TODO:

    TODO: when not connected make the CastIcon gray, when connected make the CastIcon blue

    TODO: make a skip button that will open up the youtube application by going to url youtube:// [this is the only workaround I can think of at this time]

    TODO: figure out why I'm having to use grand central dispatch to get the streamDuration bc if I don't I'll get back an optional value

    TODO: Figure out how to get the streamDuration right after the application successfully joins to the media

    TODO: make this able to run in the safari app by clicking the share/action button

    A cool thought: what if while the app is running/media is running just from the lockscreen the user can pause, play, fast forward, and rewind the media (much like a podcast does)

    when the device goes offline do stuff
    BUT WHEN THE DEVICE COMES BACK ONLINE....or at least starts a new media session....rejoin the application to make a streamline connection where it works with the new media

    make it where if launching the app before the device is "busy" it will rescan and get the most up to date device status

    TODO: figure out a way to device.stopScan() so it doesn't use a bunch of battery consumption

    //I'd like to get rid of the while statements that are printing... but I guess it flushes the buffer or something crazy to help to hang on not connecting to the device... not sure

    TODO: find out what services have ads that could come up so I can add the case to the liveStreamOrAd() method case
*/


import UIKit
import iAd

var castInstance: ChromeCastWorkFiles? = ChromeCastWorkFiles()


//this class will conform to the custom protocol to update the labelView
class ViewController: UIViewController, UITextFieldDelegate, UpdateView, ApplicationStatus, ADBannerViewDelegate {
    
    //iAD class
    //var iAdInstance = Ads()
    //var bannerView: ADBannerView?
    //var bottomConstraint: NSLayoutConstraint?
    //let mediumRectAdView = ADBannerView(adType: ADAdType.MediumRectangle ) //Create banner
    
    
    //get my app delegate instance
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //this is used in my didBecomeActive() method to control the background thread
    var didBecomeActiveHelper = false
    
    //this is to add the available chrome cast devices to the button menu that will be presented to the user
    var castButton: UIAlertController? //= UIAlertController.init(title: "Chromecast Devices", message: "Select To Connect", preferredStyle: .ActionSheet)
    
    var endedFirstThread = false //this is used to syncronize my threads
    var whileLoopIsRunning: Bool? //this is also used to syncronize my threads
    
    var textField1HasFocus = false //this is used to help with my text fields and getting the correct data to skip the file
    var textField2HasFocus = false
    //and to help with the data inside the text fields
    var textField1Data = ""
    var textField2Data = ""
    var endEditingWasCalled = false
    var cancelWasSelected = false
    var whileAdHelper = false
    
    //this next variable has a property observer so when the value changes it updates the view accordingly
    var streamDuration: NSTimeInterval = 0.0 {
        didSet {
            if streamDuration == 0.0 {
                labelViewForMediaLength.text = ""
                labelMediaTitleView.text = ""
                labelView.text = ""
            }
            else {
                //now to make the output to the user look like hours and minutes
                let myString = String(streamDuration/60)
                //print("number of minutes in movie: \(myString)")
                if myString.containsString(".") {
                    var myStringArray = myString.componentsSeparatedByString(".")
                    let tempString: String = myStringArray[1] + "00"//also for safety i append to 0's on the end of the string just in case the string isn't long enough for the work int he future
                    //print("temp string is: \(tempString)")
                    //here I use the StringExtension.swift file: now to get in into a 60 minute type of format (its in a 100 type of format)
                    
                    
                    var x = Int(tempString[0...1])!*60/100
                    
                    if Int(tempString[2]) > 0 {
                        x++ //the Chromecast will round the second up 1 if the 3rd digit is greater than 0 from what I've seen
                    }
                    //now to format the minutes part of the text
                    if String(x).characters.count == 1 {
                        labelViewForMediaLength.text = "\(myStringArray[0]):0\(x)"
                    }
                    else {
                        labelViewForMediaLength.text = "\(myStringArray[0]):\(x)"
                    }
                    
                }
                else { //it divided equally or its an ad or a live stream
                    if myString == "inf" {
                        labelMediaTitleView.text = "A live stream or ad is playing"
                        
                        //now lets loop until the ad isn't playing so we can update the title and stream duration
                        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                        dispatch_async(dispatch_get_global_queue(priority, 0)) {
                            self.liveStreamOrAdCase()
                        }
                    }
                    else {
                        labelViewForMediaLength.text = myString
                    }
                }
            }
        }
    }
    
    // MARK: IBOutlet Properties
    @IBOutlet weak var labelViewForMediaLength: UILabel!
    @IBOutlet weak var labelView: UILabel!

    @IBOutlet weak var minuteTextViewOutlet: UITextField!
    @IBOutlet weak var secondTextViewOutlet: UITextField!
    
    @IBOutlet weak var stopMediaButtonView: UIButton!
    @IBOutlet weak var volumeSliderView: UISlider!
    @IBOutlet weak var castButtonView: UIBarButtonItem!
    @IBOutlet weak var labelMediaTitleView: UILabel!

    @IBOutlet weak var progressBarView: UIProgressView! = UIProgressView.init(progressViewStyle: UIProgressViewStyle.Default)

    //Delegate methods for AdBannerView
    //This code simply adds the rectangle advertisement to the view, it hasn’t been positioned yet. This where the real work comes into play, creating/modifying your view to accommodate the advertisement.
    
    func bannerViewDidLoadAd(banner: ADBannerView!) {
        //print("success")
        
        //get the center of the ad and match it up with the center of the view
        //ill have to do this by off setting the x to the middle
        
        //(banner.frame.width / 2) //this is the offset that needs to be from the middle of the screen
        //this next line of code centers the ad horizontally
        banner.frame.origin.x = (self.view.frame.width / 2) - (banner.frame.width / 2)
        
        banner.frame.origin.y = volumeSliderView.frame.origin.y + 35
        
        self.view.addSubview(banner) //Add banner to view (Ad loaded)
    }
    
    func bannerView(banner: ADBannerView!, didFailToReceiveAdWithError
        error: NSError!) {
            //print("failed to load ad")
            banner.removeFromSuperview() //Remove the banner (No ad)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        navigationItem.rightBarButtonItems[0].image = UIBarButtonItem.i
        //iAD delegation
        //mediumRectAdView.delegate = self
        
        //set the delegation for the updateView protocol up to be able to update the labelView from another class
        castInstance?.delegate = self
        
        //set the delegate for the progressView protocol to be able to update the progress of the current media session
        appDelegate.delegate = self
        
        //set up the ChromeCast files
        castInstance!.setUp()
        
        minuteTextViewOutlet.delegate = self
        secondTextViewOutlet.delegate = self
        
        //setup the label view start text
        labelView.text = ""
        labelViewForMediaLength.text = ""
        //make sure this view can display multiple lines for long titles
        labelMediaTitleView.text = ""
        labelMediaTitleView.lineBreakMode = .ByWordWrapping
        labelMediaTitleView.numberOfLines = 3 //this sets the maximum value of the UILabel for the word wrap

        
        //setup the progressView
        progressBarView!.progress = 0.0
        
        
        //make the background pretty with gradients
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = self.view.bounds
        
        //create the colors with help from the extension of the UIColor
        let darkGray = UIColor(netHex: 0x737373)
        let lighterGray = UIColor(netHex: 0xf2f2f2)
        
        gradient.colors = [darkGray.CGColor, lighterGray.CGColor]
        self.view.layer.insertSublayer(gradient, atIndex: 0)


        self.canDisplayBannerAds = false
        
        
        
    }
    
    //this would be needed if I was supporting other orientations (it works, but i'm requiring full size for now)
    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        
        //make the background color set to thewith the correct size no matter what the orientation is
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = CGRectMake(0, 0, size.width, size.height)
        
        //create the color with help from the extension of the UIColor
        let darkGray = UIColor(netHex: 0x737373)
        let lighterGray = UIColor(netHex: 0xf2f2f2)
        
        //add the colors to produce the gradient
        gradient.colors = [darkGray.CGColor, lighterGray.CGColor]
        
        //simply replace the view that was added in the viewDidLoad() method
        self.view.layer.replaceSublayer(view.layer.sublayers![0], with: gradient)
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        
        return true
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        addKeyboardBarButtons(textField)
        
        //these conditions are done to be able to get the data out of the variables to skip to the correct length in the media
        if textField.tag == 1 {
            textField1HasFocus = true
        }
        else {
            textField2HasFocus = true
        }
    }
    
    func addKeyboardBarButtons(textField: UITextField) {
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace,
            target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .Done,
            target: self, action: Selector("endEditing"))
        
        let cancelBarButton = UIBarButtonItem.init(title: "Cancel", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("cancelEditing"))
        
        if textField.tag == 1 { //doing this bc we don't want to add "next" on the other text field
            let nextBarButton = UIBarButtonItem.init(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("customNextResponder"))
            keyboardToolbar.items = [flexBarButton, doneBarButton, nextBarButton, cancelBarButton]
            minuteTextViewOutlet.inputAccessoryView = keyboardToolbar
        }
        else {
            keyboardToolbar.items = [flexBarButton, doneBarButton, cancelBarButton]
            secondTextViewOutlet.inputAccessoryView = keyboardToolbar
        }


    }
    
    func cancelEditing() {
        cancelWasSelected = true
        minuteTextViewOutlet.endEditing(true)
        secondTextViewOutlet.endEditing(true)
    }
    
    //this hides the keyboard
    func endEditing() {
        endEditingWasCalled = true //I'll use this to help with getting the data from the text fields
        minuteTextViewOutlet.endEditing(true)
        secondTextViewOutlet.endEditing(true)
    }
    
    func customNextResponder() {
        //if we are here, this was called from minuteTextViewOutlet which has .tag == 1
        let nextTag = 2
        
        //try to find the next responder (it's safe to do minuteTextViewOutlet.blahblah bc it was the one that called this method
        let nextResponder = minuteTextViewOutlet.superview?.viewWithTag(nextTag) as UIResponder!
        
        if nextResponder != nil {
            //found next responder so set it
            nextResponder.becomeFirstResponder()
        }
        else {
            //next responder not found so resign the keyboard
            minuteTextViewOutlet.resignFirstResponder()
        }
    }
    
    //this is called after textFieldShouldReturn(_:)
    func textFieldDidEndEditing(textField: UITextField) {
        //these conditions are done to be able to get the data out of the variables to skip to the correct length in the media
        if textField.tag == 1 {
            //print("field 1 lost focus")
            
            if endEditingWasCalled != true && cancelWasSelected != true {
                //the seconds textField should have focus
                textField2HasFocus = true
                //print("text field 2 should have focus")
            }
            
            textField1Data = textField.text!
            textField1HasFocus = false
        }
        else {
            //print("field 2 lost focus")
            textField2Data = textField.text!
            textField2HasFocus = false
        }
        
        //now to skip to the time specified (if appropriate)
        if textField1HasFocus || textField2HasFocus || cancelWasSelected {
            //do nothing
        }
        else { //get the data from both textFields and skip to it
            //print("in statement that shouldnt execute if a textfield has focus")
            //make sure its safe to skip to the data
            if castInstance?.mediaIsPlaying == true && (textField1Data != "" || textField2Data != "") {
                
                //make sure I dont crash the app by unwrapping a nil optional and
                //the data needs to be in seconds:
                //i.e. convert from minutes to seconds for textField1 and add textField2 since it is already in the form of seconds
                let skipToHere: NSTimeInterval?
                if textField1Data != "" && textField2Data != "" {
                    skipToHere =  NSTimeInterval(textField1Data)! * 60 + NSTimeInterval(textField2Data)!
                }
                else if textField1Data != "" && textField2Data == "" {
                    skipToHere =  NSTimeInterval(textField1Data)! * 60
                }
                else {
                    skipToHere =  NSTimeInterval(textField2Data)!
                }
                
                //TODO: make sure that this is a valid entry before seeking
                //let skipToHere: NSTimeInterval = NSTimeInterval(tempData!)
                
                //and reset the labels
                //TODO: i might now have to do this next part
                minuteTextViewOutlet.text = "min"
                secondTextViewOutlet.text = "sec"
                
                
                //I'll use this to seek to the media position specified
                castInstance!.mediaControlChannel?.seekToTimeInterval(skipToHere!)
                castInstance!.mediaControlChannel.play()
                
                //now let the label display what it skipped to for 3 seconds
                labelView.text = "Skipped to: \(textField1Data) min and \(textField2Data) sec"
                
                //now to reset the data for future use if possible to be on the safe side
                textField1Data = ""
                textField2Data = ""
                
                //all this next part is doing is making the labelView.text disappear after 3 seconds
                let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                dispatch_async(queue) {
                    sleep(3)
                    let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                    dispatch_async(dispatch_get_global_queue(priority, 0)) {
                        // do some task
                        dispatch_async(dispatch_get_main_queue()) {
                            self.labelView.text = ""
                        }
                    }
                }
                
            }
            else {
                //all this next part is doing is making the text appear then disappear after 3 seconds
                let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
                if castInstance?.mediaIsPlaying != true {
                    if textField1HasFocus || textField2HasFocus {
                        //do nothing
                    }
                    else {
                        labelView.text = "No media is playing to skip to"
                    }
                    self.minuteTextViewOutlet.text = "min"
                    self.secondTextViewOutlet.text = "sec"
                    dispatch_async(queue) {
                        sleep(3)
                        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                        dispatch_async(dispatch_get_global_queue(priority, 0)) {
                            // do some task
                            dispatch_async(dispatch_get_main_queue()) {
                                self.labelView.text = ""
                            }
                        }
                    }
                }
            }
        }
        endEditingWasCalled = false //reset this for use later if needed
        cancelWasSelected = false //reset this for use later if needed
        
        if self.textField2HasFocus {
            self.minuteTextViewOutlet.text = "\(self.textField1Data) min"
        }
        else {
            self.minuteTextViewOutlet.text = "min"
        }
        self.secondTextViewOutlet.text = "sec"
        textField.resignFirstResponder()
    }
    
    
    // MARK: IBActions
    
    @IBAction func adjustVolumeViewAction(sender: UISlider) {
        if self.streamDuration != 0.0 {
            castInstance?.deviceManager?.setVolume(volumeSliderView.value)
        }
    }

    @IBAction func pauseMedia(sender: UIButton) {
        castInstance!.mediaControlChannel!.pause()
    }
    
    @IBAction func playMedia(sender: UIButton) {
        castInstance!.mediaControlChannel!.play()
    }
    
    @IBAction func editTextView(sender: UITextField) {
        
    }
    
    
    @IBAction func fastForwardMedia(sender: UIButton) {
        castInstance!.mediaControlChannel!.seekToTimeInterval(castInstance!.mediaControlChannel!.approximateStreamPosition() + 15)
        castInstance!.mediaControlChannel!.play()
        
        //castInstance!.mediaControlChannel!.seekToTimeInterval(2480)
   /*
        print("namespace = \(castInstance!.mediaControlChannel.protocolNamespace)")
        let nameSpace = castInstance!.mediaControlChannel.protocolNamespace
        castInstance!.mediaControlChannel = GCKMediaControlChannel(namespace: nameSpace)
    */
        
//        castInstance!.mediaControlChannel.mediaStatus.m
        //self.streamDuration = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration
    }
    
    @IBAction func rewindMedia(sender: AnyObject) {
        print("stream duration=\(castInstance!.mediaControlChannel!.approximateStreamPosition())")
        castInstance!.mediaControlChannel!.seekToTimeInterval(castInstance!.mediaControlChannel!.approximateStreamPosition() - 15)
        castInstance!.mediaControlChannel!.play()
    }
    
    @IBAction func stopMediaButtonAction(sender: UIButton) {
        castInstance!.deviceManager?.stopApplication()
        self.streamDuration = 0.0
        self.progressBarView.setProgress(0.0, animated: true)
        castInstance!.mediaIsPlaying = false
    }
    
    func connectToDevice(deviceToConnectTo: GCKDevice) {
        //print("in connect to device")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //I use this for the thread(s) I create shortly

        // [START device-selection]
        let identifier = NSBundle.mainBundle().bundleIdentifier
        
        castInstance!.deviceManager = GCKDeviceManager(device: deviceToConnectTo, clientPackageName: identifier)
        
        castInstance!.deviceManager!.delegate = castInstance.self
        castInstance!.myDevice = deviceToConnectTo //this is necesary to be used in the castInstance class so the connection can be made correctly
        castInstance!.deviceManager!.connect()
        //print("just called .connect()")

        dispatch_async(queue) {
            //all this while statement is making sure of is that the device actually connects without the device going offline in the process and its waiting for the isDisconnectOkayHelper boolean value to change (which means is just connected)
            //I use the dictionary to account for multiple chromecast devices that might be on the same wifi network that could go offline
            var x = 0
            while castInstance!.isDisconnectOkayHelper == false && castInstance!.deviceDidGoOfflineDictionary["\(castInstance!.myDevice?.friendlyName)"] != nil { // the right of the && use to say: castInstance!.deviceDidGoOffline == false
                //wait until one of the variables change
                print(".", terminator:"") //I have to do this because If I don't print anything this doesn't work
                sleep(1/2)
                x++
                if x > 500 {
                    sleep(1) //this will slow down the processor cycles to give more time to connect
                }
                
            } //Bug: if I didn't include this print statement for the ".", the app hangs up and doesn't let me connect to the device. Not sure why though other than possibly flushing some buffer or something... and it has to print something, I cant say print("""")
            
            
            if castInstance!.deviceDidGoOffline == false {
                //update the label view to show the device friendly name that was just connected
                //we don't want to do this on a background thread so we need to get the main thread by doing the following:
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    // do some task
                    dispatch_async(dispatch_get_main_queue()) {
                        let labelText: String = "Connected to: " + (castInstance!.myDevice?.friendlyName)!
                        self.navigationItem.rightBarButtonItems![0].image = UIImage(named: "ic_cast_connected_black_24dp")
                        self.castButton!.title = "\(labelText)"
                    }
                }
            }
            self.endedFirstThread = true
        }
        // [END device-selection]
        
        //I had to use a multi-thread this task to resolve this issue since I couldn't have the thread stalled out while waiting: two tasked had to be done at once to resolve my issue. That's what the following three lines are doing is making another thread
        dispatch_async(queue) {
            while self.endedFirstThread != true { /* wait until it does */ } 
            self.endedFirstThread = false //resetting it for next time if needed
            self.waitForDeviceToJoinApplication()
        }

    }
    
    //since I am not figuring out how to get the streamDuration cleanly in the "did join session" on the chromecast api method this is my workaround (above I had to create a new thread for this part as well)
    func waitForDeviceToJoinApplication() -> Void {
        while(castInstance!.joining == false && castInstance!.gotHere == false) { print("in wait for device to join first while"); sleep(1) /* sit here and wait until one changes states */ }
        //once the above loop is satisfied check the outcome to see if there was an issue:
        if(castInstance!.joining == true) {
            while(castInstance!.successfullyJoined == false && castInstance!.deviceDidGoOffline == false) { //print("in second while in the join app");
                sleep(1) /* wait until the state changes */
            }
            //once this loop above is satisfied check the outcome to see if there was an issue:
            if(castInstance!.successfullyJoined == true && castInstance!.deviceDidGoOffline == false) {
                //print("success")
            }
            else {
                //print("Could not join session")
                return //if we get here we don't want to go any further
            }
        }
        else {
            //print("Could not join session since no media is playing")
            return //if we get here we don't want to go any further
        }

        //this next part is needed because I need to update the UI, but can't do it to the background thread so I use this function call to wait for the main thread to do the work so that the UI can be updated (using the main thread)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                //print("in sub thread main thread getter")
                if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                    //print("passed")
                    //print("->\(castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration)")
                    self.streamDuration = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration
                }
                else {
                    self.labelMediaTitleView.text = "If media is playing, connect to device again please"
                    sleep(3)
                    self.labelViewForMediaLength.text = ""
                    //print("failed")
                }
                
            }
        }
/*
        let testingTry = castInstance!.mediaControlChannel.mediaStatus.mediaInformation.metadata
        
        print("title is? => \(testingTry.stringForKey(kGCKMetadataKeyTitle)) ")
        print("subtitle is? => \(testingTry.stringForKey(kGCKMetadataKeySubtitle )) ")
        print("artist is? => \(testingTry.stringForKey(kGCKMetadataKeyArtist )) ")
        print("album artist is? => \(testingTry.stringForKey(kGCKMetadataKeyAlbumArtist )) ")
*/
//        print("season number is? => \(testingTry.stringForKey(kGCKMetadataKeySeasonNumber )) ")

        //now reset the variables I used so I can do it again next time
        castInstance!.joining = false
        castInstance!.gotHere = false
        castInstance!.successfullyJoined = false
        castInstance!.deviceDidGoOffline = false
    }

    @IBAction func castButtonViewAction(sender: UIBarButtonItem) {
        
        //this = nil part just clears the action buttons in case one is missing from the past (i.e. a device went offline)
        //also when a device is connected, I set the text of the device connected to so If the title isnt Chromecast Devices, I want to keep the string by doing the following
        let titleString: String! = castButton?.title
        if castButton?.title != "Chromecast Devices" && castButton?.title != nil {
            castButton = nil
            //keep the current title during the initilization
            castButton = UIAlertController.init(title: "\(titleString)", message: "Choose different device, or disconnect", preferredStyle: .ActionSheet)
        }
        else {
            castButton = nil
            castButton = UIAlertController.init(title: "Chromecast Devices", message: "Select To Connect", preferredStyle: .ActionSheet)
        }
        //print("here")

        
        //to add the buttons
        if let deviceScanner = castInstance!.deviceScanner {
            deviceScanner.startScan()
            deviceScanner.passiveScan = false
            for device in deviceScanner.devices  {
                let buttonToAdd = UIAlertAction(title: device.friendlyName, style: .Default, handler: { (buttonSelected: UIAlertAction) -> Void in
                    //now to find the correct device to connect to because this UIAlertAction parameter doesnt give me a way to pass the device itself in as a parameter... at least I couldn't figure out how to do it
                    let deviceToConnectTo = self.castButtonHelper(buttonSelected) //I did this bc I couldnt figure out how to properly use the scope of a closure in Swift
                    castInstance!.deviceManager?.disconnect()
                    //print("trying to connect to: \(deviceToConnectTo.friendlyName)")
                    self.connectToDevice(deviceToConnectTo)
                })
                var buttonExists = false
                for button in castButton!.actions {
                    if(buttonToAdd.title == button.title) {
                        buttonExists = true
                    }
                }
                if(!buttonExists) {
                    castButton!.addAction(buttonToAdd)
                }
                deviceScanner.passiveScan = true
            }
            //            deviceScanner.stopScan()
        }
        let ok = UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction ) -> Void in
            self.dismissViewControllerAnimated(true, completion: {});
            
        })
        castButton!.addAction(ok)// add action to uialertcontroller
        
        let disconnect = UIAlertAction(title: "Disconnect", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction ) -> Void in
            //TODO: Make sure the device is connected before doing this
            if castInstance?.isDisconnectOkayHelper == true {
                castInstance!.deviceManager!.disconnect()
                castInstance!.isDisconnectOkayHelper = false
                self.labelViewForMediaLength.text = ""
                self.labelMediaTitleView.text = ""
                self.labelView.text = ""
                castInstance!.mediaIsPlaying = false
                self.castButton!.title = "Chromecast Devices"
                self.castButton!.message = "Select To Connect"
                self.navigationItem.rightBarButtonItems![0].image = UIImage(named: "ic_cast_black_24dp")
                
            }
        })
        castButton!.addAction(disconnect)// add action to uialertcontroller


        
        
        self.presentViewController(castButton!, animated: true, completion: nil)
    }
    
    //this will take in the UIAlertAction button that was selected, and match up the device
    func castButtonHelper(buttonSelected: UIAlertAction) -> GCKDevice {
        //print("->\(buttonSelected.title!)")
        
        var deviceToReturn: GCKDevice?
        if let deviceScanner = castInstance!.deviceScanner {
            deviceScanner.startScan()
            deviceScanner.passiveScan = false
            for device in deviceScanner.devices {
                if(device.friendlyName == buttonSelected.title) {
                    deviceToReturn = (device as! GCKDevice) //this should crash if the device is nil
                }
            }
//            deviceScanner.stopScan()
              deviceScanner.passiveScan = true
        }
        return deviceToReturn!
    }
    //[END_IBActions]
    
    
    //Now for my custom protocol implementation
    func updateStreamDuration() {
        if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
            //print("got here")
            self.streamDuration = 0.0
            self.streamDuration = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration
            
            if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation.metadata != nil {
                self.labelMediaTitleView.text = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.metadata.stringForKey(kGCKMetadataKeyTitle)
            }
            
            //now to make the progress bar work
            self.didBecomeActive()
        }
        else {
            //print("didnt pass")
            self.streamDuration = 0.0
            self.progressBarView.progress = 0
            self.labelViewForMediaLength.text = ""
            self.labelMediaTitleView.text = ""
        }
        
    }
    
    func updateUIBarButtonImage(device: GCKDevice) {
        //this gets called when a device goes offline
        //if the device that goes offline is the device currently connect to we want to update the UIBarButtonImage to show the correct png file (that its disconnected)
        if let deviceConnectedTo = castInstance?.myDevice?.friendlyName {
            if deviceConnectedTo == device.friendlyName {
                //update the image to show the app is no longer connected
                self.navigationItem.rightBarButtonItems![0].image = UIImage(named: "ic_cast_black_24dp")
            }
        }
    }
    
    //this is ran when the application gets an active status (it's in the foreground) it is a delegate for the AppDelegate class and also when the queue is updated this gets called to make sure it is updating the progress bar view
    //this just makes sure to update the progressBarView when the application gets the forground or the queue gets updated on the chromecast
    func didBecomeActive() {
        //this condition is here to make sure that multiple threads aren't created
        if self.didBecomeActiveHelper == false || self.whileLoopIsRunning == false { //either this is the first time going into this section
            let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT                           //or the while loop is done; either way we want it running
            dispatch_async(dispatch_get_global_queue(priority, 0)) {                 //with only one background thread
                // do some task
                
                //this if else madness below just makes sure that at the very end of the queue, it stops the while loop and updates the views to show that nothing is playing
                while self.streamDuration != 0.0 {
                    if String(self.streamDuration) == "inf" {
                        //print("stream duration = inf")
                    }

                    if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                        //if this works then I can get the stream duration and check it
                        if self.streamDuration == castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration {
                            //we are good to go through the code in this statement
                            self.whileLoopIsRunning = true
                            sleep(2)
                            //print("progress view background thread is running")
                            dispatch_async(dispatch_get_main_queue()) {
                                //update UI here
                                
                                //I commented out this if block since I just added this check above. I didnt delete it bc i might need to bring it back
                                //if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                                    
                                    self.progressBarView.setProgress(Float(castInstance!.mediaControlChannel!.approximateStreamPosition())  /  Float(self.streamDuration), animated: true)
                                    self.labelView.text = String(castInstance!.mediaControlChannel!.approximateStreamPosition() / 60)
                                
                                let myString = String(castInstance!.mediaControlChannel!.approximateStreamPosition() / 60)
                                if myString.containsString(".") {
                                    var myStringArray = myString.componentsSeparatedByString(".")
                                    let tempString: String = myStringArray[1] + "00"//also for safety i append two 0's on the end of the string just in case the string isn't long enough for the work int he future
                                    //here I use the StringExtension.swift file: now to get in into a 60 minute type of format (its in a 100 type of format)
                                    
                                    
                                    var x = Int(tempString[0...1])!*60/100
                                    
                                    if Int(tempString[2]) > 0 {
                                        x++ //the Chromecast will round the second up 1 if the 3rd digit is greater than 0 from what I've seen
                                    }
                                    
                                    if String(x).characters.count == 1 {
                                        self.labelView.text = "\(myStringArray[0]):0\(x)"
                                    }
                                    else {
                                        self.labelView.text = "\(myStringArray[0]):\(x)"
                                    }
                                }
                                
                                //}
                            }
                        }
                        else {
                            //the video stopped playing
                            dispatch_async(dispatch_get_main_queue()) {
                                self.streamDuration = 0.0
                            }
                        }
                    }
                    else {
                        //the video stopped playing
                        dispatch_async(dispatch_get_main_queue()) {
                            self.streamDuration = 0.0
                        }
                    }
                    
                }
                //since we are out of the while loop change this to false
                //print("while loop isnt running now")
                self.whileLoopIsRunning = false
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressBarView.setProgress(0.0, animated: true)
                    self.labelView.text = ""
                    self.labelViewForMediaLength.text = ""
                }
            }
            self.didBecomeActiveHelper = true
        }
    }
    
    //this is called in the property observer of streamDuration if and only if the streamDuration that comes back is 'inf'
    func liveStreamOrAdCase() -> Void {
        
        //loop until we get a change in the stream duration since an ad is playing right now
        while self.whileAdHelper != true {
            
            if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                
                if !String(castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration).containsString("inf") {
                    self.whileAdHelper = true
                }
                
            }
            sleep(1)
            //print("in liveStreamOrAdLoop")
        }
        //reset the variable for use later
        self.whileAdHelper = false
        //we got here because an ad is no longer playing
        //now we need to update the stream duration and the title of the media
        dispatch_async(dispatch_get_main_queue()) {
            //this if statement probably isn't needed, but just for safety
            if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                
                self.streamDuration = castInstance!.mediaControlChannel.mediaStatus.mediaInformation.streamDuration
                self.labelMediaTitleView.text = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.metadata.stringForKey(kGCKMetadataKeyTitle)
                if self.whileLoopIsRunning != true {
                    //this makes sure that the progress view keeps getting updated because if an ad was playing it stopped the progress view while loop so this checks to make sure that that particular while loop is not running and calls the following method to make sure the stream duration gets updated
                    self.updateStreamDuration()
                }
                
            }
            
        }
        
    }

}