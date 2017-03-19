//
//  ChromeCastWorkFiles.swift
//  CastRemote
//
//  Created by Coty Embry on 12/27/15.
//  Copyright © 2015 cotyembry. All rights reserved.
//

import Foundation

//create protocol to work with updating the view
protocol UpdateView {
    func updateChromeCastNameView()
    func updateStreamDuration()
    //func updateUIBarButtons()
}

class ChromeCastWorkFiles: NSObject, GCKDeviceScannerListener, GCKDeviceManagerDelegate, GCKMediaControlChannelDelegate {
    
    //this is where I declare my protocols
    var delegate: UpdateView?
    var delegate2: ApplicationStatus?
    

    var deviceScanner: GCKDeviceScanner?
    var deviceManager: GCKDeviceManager?
    var selectedDevice: GCKDevice?
    var myDevice: GCKDevice?
    var mediaControlChannel = GCKMediaControlChannel()
    var joinApplicationMethodHelper: String?
        
    var joining = false //these next 3 variablesare going to be used as my workaround for not being able to get the stream duration easily
    var successfullyJoined = false
    var gotHere = false
    
    var deviceDidGoOfflineDictionary = [String: Bool]()
    
    var deviceDidGoOffline = false
    
    //I'll use this to help see if it's okay to disconnect the chromecast session
    var isDisconnectOkayHelper = false
    var mediaIsPlaying = false
    
    func mediaControlChannelDidUpdateQueue(mediaControlChannel: GCKMediaControlChannel!) {
        print("did update queue")
        
        
        //!!!!!!!!!!!!
        //  This is where I am going to try to put in some delegation; I think I need to call my protocol here. This will tell the class that is implementing the delegation when this method is called
        //!!!!!!!!!!!!
        print("calling updateStreamDuration() to start the delegation")
        delegate?.updateStreamDuration()
        delegate2?.didBecomeActive() //call this to make the progress view update the view
        
        
        //self.deviceManager!.joinApplication(joinApplicationMethodHelper)
    }

    func setUp() {
        // [START device-scanner]
        // Establish filter criteria and use the default receiver id: https://developers.google.com/cast/docs/receiver_apps and pass in the default receiver ID
        
        let filterCriteria = GCKFilterCriteria(forAvailableApplicationWithID: kGCKMediaDefaultReceiverApplicationID)
        
        // Initialize device scanner, then add the listener
        
        deviceScanner = GCKDeviceScanner(filterCriteria: filterCriteria)
        
        if let deviceScanner = deviceScanner {
            deviceScanner.addListener(self)
            deviceScanner.startScan()
            deviceScanner.passiveScan = true
        }
        // [END device-scanner]
        
    }
    
    // [START device-scanner-listener]
    // MARK: GCKDeviceScannerListener
    
    func deviceDidComeOnline(device: GCKDevice!) {
        //updateButtonStates(); //use this later to change the google cast button color
        deviceDidGoOffline = false
        
        //update dictionary
        //deviceDidGoOfflineDictionary = ["\(device.friendlyName)": false]
        
        deviceDidGoOffline = false
    }
    
    func deviceDidGoOffline(device: GCKDevice!) {
        //updateButtonStates(); //use this later to change the google cast button color
        deviceDidGoOffline = true
        //TODO: update label view to show no media; probably will have to call a funciton here
    
        isDisconnectOkayHelper = false
        delegate?.updateChromeCastNameView()
        delegate?.updateStreamDuration()
        
        //update dictionary
        //deviceDidGoOfflineDictionary["\(device.friendlyName)"] = nil
        
        deviceDidGoOffline = true
        
    }
    // [END device-scanner-listener]
    
    
    // [START launch-application]
    // MARK: GCKDeviceManagerDelegate
    // this should be called after the device is connected to the application
    func deviceManagerDidConnect(deviceManager: GCKDeviceManager!) {
        print("Application connected to the ChromeCast.")
        
        self.deviceManager = deviceManager
        
        isDisconnectOkayHelper = true
        let deviceStatus = myDevice?.status //myDevice was set just before calling connect()
        if(GCKDeviceStatus.Busy == deviceStatus) {
            joining = true //workaround for not being able to get the stream duration cleanly
            
            print("Joining current Media session")
            
            //if the application already has media running, join with the current session
            //i pass in a nil value so the joinApplication method will find and connect for me by default if a nil value is passed
            deviceManager.joinApplication(joinApplicationMethodHelper)
        }
        else if(GCKDeviceStatus.Unknown == deviceStatus) {
            print("Device status unknown")
        }
        else if(GCKDeviceStatus.Idle == deviceStatus) {
            print("Device status idle")
        }
        else {
            print("Default case: no clue what the status is")
        }

        gotHere = true //I'll use this cleverly to make sure the while loop is ended correcly with the correct status to avoid an infinite loop in ViewController
    }
    
    // This gets called when an application has launched or joined successfully
    // [END_EXCLUDpublic E]
    func deviceManager(deviceManager: GCKDeviceManager!, didConnectToCastApplication applicationMetadata: GCKApplicationMetadata!, sessionID: String!, launchedApplication: Bool) {
        print("Successfully joined the Media session")
        
        successfullyJoined = true
        mediaIsPlaying = true
        
        mediaControlChannel!.delegate = self
        deviceManager.addChannel(mediaControlChannel)
        mediaControlChannel!.requestStatus()
        
        
        //TODO: try to get the streamDuration of the media right here instead of having to create another thread and use two while loops to look at the variables status's to resolve my issue with making sure that the device joins the session to then be able to get the streamDuration of the media that is currently playing
        
    }
    
    func deviceManager(deviceManager: GCKDeviceManager!, volumeDidChangeToLevel volumeLevel: Float, isMuted muted: Bool) {
        //TODO: set this up to where it updates the view when the volume changes
        //I think I'm going to have to create a delegate for this
        print("volume did change")
       
    }
    
    
}