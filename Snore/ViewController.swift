//
//  ViewController.swift
//  Snore
//
//  Created by Dmitry Talisman on 11/15/15.
//  Copyright © 2015 Dmitry Talisman. All rights reserved.
//

import UIKit
import AVFoundation
import Charts

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate {
    var audioPlayer: AVAudioPlayer?
    var audioRecorder: AVAudioRecorder?
    var numberOfChannels : Int?
    var recording = false
    
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var stopButton: UIButton!
    @IBOutlet var playButton: UIButton!
    
    
    @IBOutlet var chartView: LineChartView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        playButton.enabled = false
        stopButton.enabled = false
        
        chartView.noDataText = "No Recording"
        chartView.descriptionText = ""
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! NSString
        let soundFileURL: NSURL? = NSURL.fileURLWithPath("\(documentsPath)/recording.caf")
        let recordSettings = [AVEncoderAudioQualityKey: AVAudioQuality.Min.rawValue,
            AVEncoderBitRateKey: 16,
            AVNumberOfChannelsKey: 2,
            AVSampleRateKey: 44100.0]
        
        
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
        } catch {
            print("audioSession error in SetCategory() call")
        }
        
        numberOfChannels = audioSession.outputNumberOfChannels
        print ("Number of out channels: \(numberOfChannels)");
        
        do {
            audioRecorder =  try AVAudioRecorder(URL: soundFileURL!, settings: recordSettings as! [String : AnyObject])
        } catch {
            print("audioSession error")
        }
        
        audioRecorder?.prepareToRecord()
        
        let leftAxis = chartView.leftAxis;
        leftAxis.customAxisMax = 100.0
        leftAxis.customAxisMin = 0.0
        leftAxis.startAtZeroEnabled = true
        leftAxis.gridLineDashLengths = [5.0, 5.0]
        leftAxis.drawLimitLinesBehindDataEnabled = true
        chartView.leftAxis.enabled = true
        chartView.rightAxis.enabled = false
        
        let ll1 = ChartLimitLine(limit: 15.0, label:"Trashhold");
        ll1.lineWidth = 3.0;
        ll1.lineDashLengths = [5, 5];
        ll1.labelPosition = ChartLimitLine.ChartLimitLabelPosition.RightTop
        ll1.valueFont = UIFont.systemFontOfSize(10)
        
        leftAxis.addLimitLine(ll1)
        
        chartView.animate(xAxisDuration:2.5, easingOption:ChartEasingOption.EaseInOutBounce);
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func StartMonitoring(sender: AnyObject) {
        recording = true
        recordAudio(sender)
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            var idx = 0;
            //self.chartView.data = ChartData()
            while (self.recording) {
                self.checkLevel(idx)
                sleep(2)
                idx++;
            }
        }
    }
    
    @IBAction func StopMonitoring(sender: AnyObject) {
        recording = false
        stopRecording(sender)
    }
    
    func recordAudio(sender: AnyObject) {
        if audioRecorder?.recording == false {
            recordButton.enabled = false
            playButton.enabled = false
            stopButton.enabled = true
            audioRecorder?.meteringEnabled = true;
            audioRecorder?.record()
            self.chartView.clear()
        }
    }
    
    func stopRecording(sender: AnyObject) {
        stopButton.enabled = false
        playButton.enabled = true
        recordButton.enabled = true
        
        if audioRecorder?.recording == true {
            audioRecorder?.stop()
        } else {
            audioPlayer?.stop()
        }
    }
    
    func checkLevel(idx:Int) {
        
        audioRecorder?.updateMeters()
        
        let avg = audioRecorder?.averagePowerForChannel(0)
        let max = audioRecorder?.peakPowerForChannel(0)
        let avgVal = db2Linear( Double((avg!)))
        let maxVal = db2Linear( Double((max!)))
        print ("AVG:\(String(format: "%.1f",avg!)) [\(String(format: "%.1f",avgVal))] MAX:\(String(format: "%.1f",max!)) [\(String(format: "%.1f",maxVal))]")
        
        let avgEntry = ChartDataEntry(value: avgVal, xIndex: idx)
        let maxEntry = ChartDataEntry(value: maxVal, xIndex: idx)
        if (chartView.data == nil) {
            let avgChartDataSet = LineChartDataSet(yVals:[avgEntry], label: "AVG Level")
            avgChartDataSet.setColor(UIColor.blueColor())
            //chartDataSet.setCircleColor(UIColor.redColor())
            avgChartDataSet.lineWidth = 2
            avgChartDataSet.circleRadius = 3
            avgChartDataSet.drawFilledEnabled = true
            avgChartDataSet.drawCirclesEnabled = false
            avgChartDataSet.drawValuesEnabled = false
            avgChartDataSet.drawCubicEnabled = true
            chartView.data = LineChartData(xVals: ["0"], dataSet: avgChartDataSet)
            
            let maxChartDataSet = LineChartDataSet(yVals:[maxEntry], label: "MAX Level")
            maxChartDataSet.setColor(UIColor.yellowColor())
            //chartDataSet.setCircleColor(UIColor.redColor())
            maxChartDataSet.lineWidth = 2
            maxChartDataSet.circleRadius = 3
            maxChartDataSet.drawFilledEnabled = false
            maxChartDataSet.drawCirclesEnabled = false
            maxChartDataSet.drawValuesEnabled = false
            maxChartDataSet.drawCubicEnabled = true
            chartView.data?.addDataSet(maxChartDataSet)
            
        } else {
            chartView.data?.dataSets[0].addEntry(avgEntry)
            chartView.data?.dataSets[1].addEntry(maxEntry)
            
            chartView.data?.addXValue(idx.description)
            chartView.notifyDataSetChanged()
            dispatch_async(dispatch_get_main_queue()) {
                self.chartView.setNeedsDisplay()
            }
        }
    }
    
    @IBAction func playAudio(sender: AnyObject) {
        if audioRecorder?.recording == false {
            stopButton.enabled = true
            recordButton.enabled = false
            
            do {
                audioPlayer = try AVAudioPlayer(contentsOfURL: (audioRecorder?.url)!)
            } catch {
                print("audioPlayer error")
            }
            
            audioPlayer?.delegate = self
            audioPlayer?.play()
            
        }
    }
    
    
    
    //-----Delegates------------------------
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer, successfully flag: Bool) {
        recordButton.enabled = true
        stopButton.enabled = false
    }
    
    func audioPlayerDecodeErrorDidOccur(player: AVAudioPlayer) {
        print("Audio Play Decode Error")
    }
    
    func audioRecorderDidFinishRecording(recorder: AVAudioRecorder, successfully flag: Bool) {
    }
    
    func audioRecorderEncodeErrorDidOccur(recorder: AVAudioRecorder) {
        print("Audio Record Encode Error")
    }
    
    
    //-----Utils 
    // TODO: cache values
    func db2Linear (decibels:Double) -> Double {
        var level:Double        // The linear 0.0 .. 1.0 value we need.
        let minDecibels:Double = -80.0 // Or use -60dB, which I measured in a silent room.
        let maxDecibels:Double = 10.0  // Or use -60dB, which I measured in a silent room.
        
        
        if (decibels < minDecibels) { level = 0.0 }
        else if (decibels > maxDecibels) { level = 1 }
        else {
            let minAmp          = pow(10.0, 0.05 * minDecibels);
            let inverseAmpRange = 1.0 / (1.0 - minAmp);
            let amp             = pow(10.0, 0.05 * decibels);
            let adjAmp          = (amp - minAmp) * inverseAmpRange;
            
            level = pow(adjAmp, 0.5);
        }
        
        return level * 100
    }
    
    
}


extension Double {
    func toString() -> String {
        return String(format: "%.1f",self)
    }
}


