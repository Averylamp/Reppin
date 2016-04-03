//
//  ReppinViewController.swift
//  Get Rept
//
//  Created by Sebastian Cain on 4/3/16.
//  Copyright © 2016 Avery Lamp. All rights reserved.
//

import UIKit
import AVFoundation


class ReppinViewController: UIViewController {
    var setTarget: Int = 3
    var repTarget: Int = 10
    
    @IBOutlet var cv: CounterView!
    let gv = GradientView()
    let tv = UIView()
    let synth = AVSpeechSynthesizer()
    
    override func viewWillLayoutSubviews() {
        gv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.insertSubview(gv, atIndex: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        let repbtn = UIButton(frame: CGRect(origin: CGPointZero, size: CGSize(width: 100, height: 800)))
        self.view.addSubview(repbtn)
        repbtn.addTarget(self, action: #selector(ReppinViewController.reppppin), forControlEvents: UIControlEvents.TouchUpInside)
        cv.maxReps = repTarget
        cv.maxSets = setTarget
        cv.setNeedsDisplay()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let testVC = storyboard.instantiateViewControllerWithIdentifier("TestVC")
        self.addChildViewController(testVC)
        testVC.view.frame = CGRect(origin: CGPointZero, size: CGSize(width: self.view.frame.width, height: self.view.frame.height / 2))
        self.view.addSubview(testVC.view)
        testVC.didMoveToParentViewController(self)
//        tv.frame = self.view.frame;
//        self.view.addSubview(testVC.view)
        
        let displayLink = CADisplayLink(target: self, selector: #selector(ReppinViewController.update))
        displayLink.frameInterval = 1
        displayLink.addToRunLoop(NSRunLoop.currentRunLoop(), forMode: NSRunLoopCommonModes)
        let global = Global.sharedManager() as! Global
        global.repsPerSet = Int32(repTarget)
        
    }
    
    let startTime = CACurrentMediaTime()
    
    
    func update(){
        
        let globalValues = Global.sharedManager() as! Global
        if cv.reps != Int(globalValues.currentRepCount){
            cv.reps = Int(globalValues.currentRepCount);
//            cv.reps = Int(globalValues.currentRepPerSec);  ??DISPLAY RPS
            reppppin()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func reppppin() {
        var myUtterance : AVSpeechUtterance
        if cv.reps % repTarget == 0 {
            myUtterance = AVSpeechUtterance(string: "\(cv.reps). Nice set! Relax for 15 seconds, then touch the screen to start your next set")
            settttin()
        } else {
            myUtterance = AVSpeechUtterance(string: "\(cv.reps)")
        }
        myUtterance.voice = AVSpeechSynthesisVoice(language: "en-GB")
        myUtterance.rate = 0.5
        synth.speakUtterance(myUtterance)
        
        cv.setNeedsDisplay()
        cv.setNeedsLayout()
    }
    
    func settttin() {
        cv.sets += 1
        cv.reps = 0
        cv.setNeedsDisplay()
        cv.setFinished()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
