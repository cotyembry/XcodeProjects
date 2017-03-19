//
//  ViewController.swift
//  CastRemote
//
//  Created by Coty Embry on 12/2/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

/*

    TODO: fix it if more than one application is online then goes offline (this messes with the boolean variable)

    TODO: see why no media is playing to skip to comes up if one of the text fields still has focus

    TODO: make two edit text boxes with an arrow to jump between the two to specify minutes and seconds

    TODO: make the interface not jump around when the labels get text assigned to them

    TODO: take the view out of the stack view so the interface will be compatable below ios 8

    TODO: make a skip button that will open up the youtube application by going to url youtube:// [this is the only workaround I can think of at this time]

    TODO: figure out why I'm having to use grand central dispatch to get the streamDuration bc if I don't I'll get back an optional value

    TODO: if the app is a youtube video it will give back INF for the stream duration while it is loading the video; make a while loop to check back after a little bit to update the stream duration after the video has loaded

    TODO: when the streamDuration gets set, start a background thread which will later call the main thread to update the progressView bar


    TODO: fix the application background when the app is rotated sideways

    TODO: Figure out how to get the streamDuration right after the application successfully joins to the media

    TODO: make sure that I clear the [Actions] array before adding the devices so that it will correctly reflect when a device goes offline a user can't select the device to try to connect to it


    TODO: make this able to run in the safari app by clicking the share/action button

    A cool thought: what if while the app is running/media is running just from the lockscreen the user can pause, play, fast forward, and rewind the media (much like a podcast does)

    when the device goes offline do stuff
    BUT WHEN THE DEVICE COMES BACK ONLINE....or at least starts a new media session....rejoin the application to make a streamline connection where it works with the new media

    make it where if launching the app before the device is "busy" it will rescan and get the most up to date device status

    TODO: make sure when selecting the disconnect button, that nil wasn't found - or any of the buttons for that matter
    TODO: figure out a way to device.stopScan() so it doesn't use a bunch of battery consumption

    //I'd like to get rid of the while statements that are printing... but I guess it flushes the buffer or something crazy to help to hang on not connecting to the device... not sure

    TODO: find out what services have ads that could come up so I can add the case to the liveStreamOrAd() method case
*/


import UIKit


var castInstance: ChromeCastWorkFiles? = ChromeCastWorkFiles()


//this class will conform to the custom protocol to update the labelView
class ViewController: UIViewController, UITextFieldDelegate, UpdateView, ApplicationStatus {
    
    //get my app delegate instance
    var appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
    
    //this is used in my didBecomeActive() method to control the background thread
    var didBecomeActiveHelper = false
    
    //this is to add the available chrome cast devices to the button menu that will be presented to the user
    var castButton = UIAlertController.init(title: "Chromecast Devices", message: "Select To Connect", preferredStyle: .ActionSheet)
    var selectedOnce = false
    
    var endedFirstThread = false //this is used to syncronize my threads
    var whileLoopIsRunning: Bool? //this is also used to syncronize my threads
    
    var textField1HasFocus = false //this is used to help with my text fields and getting the correct data to skip the file
    var textField2HasFocus = false
    
    var endEditingWasCalled = false
    
    //and to help with the data inside the text fields
    var textField1Data = ""
    var textField2Data = ""
    
    //this next variable has a property observer so when the value changes it updates the view accordingly
    var streamDuration: NSTimeInterval = 0.0 {
        didSet {
            if streamDuration == 0.0 {
                labelViewForMediaLength.text = ""
                labelMediaTitleView.text = ""
            }
            else {
                //now to make the output to the user look like hours and minutes
                let myString = String(streamDuration/60)
                print("number of minutes in movie: \(myString)")
                if myString.containsString(".") {
                    var myStringArray = myString.componentsSeparatedByString(".")
                    let tempString: String = myStringArray[1] + "00"//also for safety i append to 0's on the end of the string just in case the string isn't long enough for the work int he future
                    print("temp string is: \(tempString)")
                    //here I use the StringExtension.swift file: now to get in into a 60 minute type of format (its in a 100 type of format)
                    
                    
                    var x = Int(tempString[0...1])!*60/100
                    
                    if Int(tempString[2]) > 0 {
                        x++ //the Chromecast will round the second up 1 if the 3rd digit is greater than 0 from what I've seen
                    }
                    
                    labelViewForMediaLength.text = "Media Length: " + "\(myStringArray[0]) min \(x) sec"
                }
                else { //it divided equally or its an ad or a live stream
                    if myString == "inf" {
                        labelViewForMediaLength.text = "A live stream or ad is playing"
                        liveStreamOrAdCase()
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
    @IBOutlet weak var chromeCastNameView: UILabel!
    @IBOutlet weak var labelMediaTitleView: UILabel!

    @IBOutlet weak var progressBarView: UIProgressView! = UIProgressView.init(progressViewStyle: UIProgressViewStyle.Default)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        labelMediaTitleView.text = ""
        chromeCastNameView.text = ""
        
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

        
    }
    
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
        
        if textField.tag == 1 { //doing this bc we don't want to add "next" on the other text field
            let nextBarButton = UIBarButtonItem.init(title: "Next", style: UIBarButtonItemStyle.Plain, target: self, action: Selector("customNextResponder"))
            keyboardToolbar.items = [flexBarButton, doneBarButton, nextBarButton]
            minuteTextViewOutlet.inputAccessoryView = keyboardToolbar
            print("here1")
        }
        else {
            keyboardToolbar.items = [flexBarButton, doneBarButton]
            secondTextViewOutlet.inputAccessoryView = keyboardToolbar
            print("here2")
        }


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
            print("I found the next responder!!!")
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
            print("field 1 lost focus")
            
            if endEditingWasCalled != true {
                //the seconds textField should have focus
                textField2HasFocus = true
                print("text field 2 should have focus")
            }
            
            textField1Data = textField.text!
            textField1HasFocus = false
            
        }
        else {
            print("field 2 lost focus")
            textField2Data = textField.text!
            textField2HasFocus = false
        }
        
        //now to skip to the time specified (if appropriate)
        if textField1HasFocus || textField2HasFocus {
            //do nothing
        }
        else { //get the data from both textFields and skip to it
            print("in statement that shouldnt execute if a textfield has focus")
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
        self.minuteTextViewOutlet.text = "min"
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
    }
    
    @IBAction func rewindMedia(sender: AnyObject) {
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
        print("in connect to device")
        let queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0) //I use this for the thread(s) I create shortly

        // [START device-selection]
        let identifier = NSBundle.mainBundle().bundleIdentifier
        
        castInstance!.deviceManager = GCKDeviceManager(device: deviceToConnectTo, clientPackageName: identifier)
        
        castInstance!.deviceManager!.delegate = castInstance.self
        castInstance!.myDevice = deviceToConnectTo //this is necesary to be used in the castInstance class so the connection can be made correctly
        castInstance!.deviceManager!.connect()
        print("just called .connect()")

        dispatch_async(queue) {
            //all this while statement is making sure of is that the device actually connects without the device going offline in the process and its waiting for the isDisconnectOkayHelper boolean value to change (which means is just connected)
            var x = 0
            while castInstance!.isDisconnectOkayHelper == false && castInstance!.deviceDidGoOffline == false {
                //wait until one of the variables change
                print(".", terminator:"")
                sleep(1/2)
                x++
                if x > 500 {
                    sleep(1) //this will slow down the processor cycles to give more time to connect
                }
                
            } //Bug: if I didn't include this print statement, the app hangs up and doesn't let me connect to the device. Not sure why though other than possibly flushing some buffer or something... and it has to print something, I cant say print("""")
            
            
            if castInstance!.deviceDidGoOffline == false {
                //update the label view to show the device friendly name that was just connected
                //we don't want to do this on a background thread so we need to get the main thread by doing the following:
                let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
                dispatch_async(dispatch_get_global_queue(priority, 0)) {
                    // do some task
                    dispatch_async(dispatch_get_main_queue()) {
                        let labelText: String = "Connected to: " + (castInstance!.myDevice?.friendlyName)!
                        self.chromeCastNameView.text = labelText
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
            while(castInstance!.successfullyJoined == false && castInstance!.deviceDidGoOffline == false) { print("in second while in the join app"); sleep(1) /* wait until the state changes */
            }
            //once this loop above is satisfied check the outcome to see if there was an issue:
            if(castInstance!.successfullyJoined == true && castInstance!.deviceDidGoOffline == false) {
                print("success")
            }
            else {
                print("Could not join session")
                return //if we get here we don't want to go any further
            }
        }
        else {
            print("Could not join session since no media is playing")
            return //if we get here we don't want to go any further
        }

        //this next part is needed because I need to update the UI, but can't do it to the background thread so I use this function call to wait for the main thread to do the work so that the UI can be updated (using the main thread)
        let priority = DISPATCH_QUEUE_PRIORITY_DEFAULT
        dispatch_async(dispatch_get_global_queue(priority, 0)) {
            // do some task
            dispatch_async(dispatch_get_main_queue()) {
                print("in sub thread main thread getter")
                if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                    print("passed")
                    print("->\(castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration)")
                    self.streamDuration = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration
                }
                else {
                    self.labelViewForMediaLength.text = "If media is playing, connect to device again please"
                    sleep(3)
                    self.labelViewForMediaLength.text = ""
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
        //to add the buttons
        if let deviceScanner = castInstance!.deviceScanner {
            deviceScanner.startScan()
            deviceScanner.passiveScan = false
            for device in deviceScanner.devices  {
                let buttonToAdd = UIAlertAction(title: device.friendlyName, style: .Default, handler: { (buttonSelected: UIAlertAction) -> Void in
                    //now to find the correct device to connect to because this UIAlertAction parameter doesnt give me a way to pass the device itself in as a parameter... at least I couldn't figure out how to do it
                    let deviceToConnectTo = self.castButtonHelper(buttonSelected) //I did this bc I couldnt figure out how to properly use the scope of a closure in Swift
                    castInstance!.deviceManager?.disconnect()
                    print("trying to connect to: \(deviceToConnectTo.friendlyName)")
                    self.connectToDevice(deviceToConnectTo)
                })
                var buttonExists = false
                for button in castButton.actions {
                    if(buttonToAdd.title == button.title) {
                        buttonExists = true
                    }
                }
                if(!buttonExists) {
                    castButton.addAction(buttonToAdd)
                }
            deviceScanner.passiveScan = true
            }
//            deviceScanner.stopScan()
        }
        if(selectedOnce == false) {
            let ok = UIAlertAction(title: "Nevermind", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction ) -> Void in
                self.dismissViewControllerAnimated(true, completion: {});
        
            })
            castButton.addAction(ok)// add action to uialertcontroller

            let disconnect = UIAlertAction(title: "Disconnect", style: UIAlertActionStyle.Default, handler: { (action: UIAlertAction ) -> Void in
                //TODO: Make sure the device is connected before doing this
                if castInstance?.isDisconnectOkayHelper == true {
                    castInstance!.deviceManager!.disconnect()
                    castInstance!.isDisconnectOkayHelper = false
                    self.chromeCastNameView.text = ""
                    self.labelViewForMediaLength.text = ""
                    self.labelMediaTitleView.text = ""
                    castInstance!.mediaIsPlaying = false
                }
            })
            castButton.addAction(disconnect)// add action to uialertcontroller

            selectedOnce = true //this makes it where these buttons don't get added again if they have already been added
        }
        self.presentViewController(castButton, animated: true, completion: nil)
    }
    
    //this will take in the UIAlertAction button that was selected, and match up the device
    func castButtonHelper(buttonSelected: UIAlertAction) -> GCKDevice {
        print("->\(buttonSelected.title!)")
        
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
            print("got here")
            self.streamDuration = 0.0
            self.streamDuration = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration
            
            if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                self.labelMediaTitleView.text = castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.metadata.stringForKey(kGCKMetadataKeyTitle)
            }
            
            //now to make the progress bar work
            self.didBecomeActive()
        }
        else {
            print("didnt pass")
            self.streamDuration = 0.0
            self.progressBarView.progress = 0
            self.labelViewForMediaLength.text = ""
            self.labelMediaTitleView.text = ""
        }
        
    }
    
    func updateChromeCastNameView() {
        chromeCastNameView.text = ""
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
                    if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                        //if this works then I can get the stream duration and check it
                        if self.streamDuration == castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.streamDuration {
                            //we are good to go through the code in this statement
                            self.whileLoopIsRunning = true
                            sleep(2)
                            print("progress view background thread is running")
                            dispatch_async(dispatch_get_main_queue()) {
                                //update UI here
                                
                                //I commented out this if block since I just added this check above. I didnt delete it bc i might need to bring it back
                                //if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
                                    
                                    self.progressBarView.setProgress(Float(castInstance!.mediaControlChannel!.approximateStreamPosition())  /  Float(self.streamDuration), animated: true)
                                    
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
                self.whileLoopIsRunning = false
                dispatch_async(dispatch_get_main_queue()) {
                    self.progressBarView.setProgress(0.0, animated: true)
                }
            }
            self.didBecomeActiveHelper = true
        }
    }
    
    //this is called in the property observer of streamDuration if and only if the streamDuration that comes back is 'inf'
    func liveStreamOrAdCase() -> Void {
        //first check to see if it is the youtube app
        if nil != castInstance?.mediaControlChannel?.mediaStatus && castInstance?.mediaControlChannel?.mediaStatus.mediaInformation != nil {
            print("app id->\(castInstance!.mediaControlChannel!.mediaStatus.mediaInformation.metadata.stringForKey(kGCKMediaDefaultReceiverApplicationID))")
        }
    }

}