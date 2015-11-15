//
//  ViewController.swift
//  Snore
//
//  Created by Dmitry Talisman on 11/15/15.
//  Copyright © 2015 Dmitry Talisman. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {
var audioRecorder: AVAudioRecorder? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func StartMonitoring(sender: AnyObject) {
    }
    
    func record() {
        self.prepareToRecord()
        if let recorder = self.audioRecorder {
            recorder.record()
        }
    }
    
    func prepareToRecord() {
        var error: NSError?
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let soundFileURL: NSURL? = NSURL.fileURLWithPath("\(documentsPath)/recording.caf")
        
        self.audioRecorder = AVAudioRecorder(URL: soundFileURL, settings: recordSettings as [NSObject : AnyObject], error: &error)
        if let recorder = self.audioRecorder {
            recorder.prepareToRecord()
        }
    }

}

