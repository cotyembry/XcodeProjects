//
//  ViewController.swift
//  TestApp
//
//  Created by Coty Embry on 1/1/16.
//  Copyright © 2016 cotyembry. All rights reserved.
//

import UIKit
import MediaPlayer

class ViewController: UIViewController, MPMediaPickerControllerDelegate, MPMediaPlayback { //UIWebViewDelegate
    //var webView = WebView()
    
    var isPreparedToPlay: Bool = false
    var currentPlaybackRate: Float = 0.0
    
    var currentPlaybackTime: NSTimeInterval = 0
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

       // webView.delegate? = self
        
        var webView = UIWebView.init(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
        
        var myurl: String = "https://www.google.com"
        var nurl: NSURL = NSURL(string: myurl)!
        var nrequest: NSURLRequest = NSURLRequest(URL: nurl)
        
        
        var urlRequest = NSURLRequest(URL: nurl)
        
        webView.loadRequest(nrequest)
    


        self.view.addSubview(webView)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func loadRequest(request: NSURLRequest) {
        
    }

    
    func mediaPicker(mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        print("did pick media items")
    }
    
    func play() {
        print("in play")
    }
    
    func pause() {
        print("in pause")
    }

    func stop() {
        print("in stop")
    }
    
    func prepareToPlay() {
        print("preparing to play")
    }
    
    func beginSeekingBackward() {
        print(".")
        
    }
    
    func beginSeekingForward() {
        print(".")
    }
    
    func endSeeking() {
        print(".")
    }
    
    
}

