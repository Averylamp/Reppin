//
//  CounterView.swift
//  Flo
//
//  Created by John Qian on 3/27/16.
//  Copyright © 2016 John Qian. All rights reserved.
//

import UIKit

let π:CGFloat = CGFloat(M_PI)
let setSpacing = 0.05
let repSpacing = 0.005

class CounterView: UIView {
    
    var counterLabel = UILabel()
    var setLabel = UILabel()
    var counterSubLabel = UILabel()
    var setSubLabel = UILabel()
    var startTime: NSDate?
    var timer = NSTimer()
    var timerLabel = UILabel()
    var startbtn = UIButton()
    var reps = 0
    var sets = 0
    var maxReps = 0
    var maxSets = 0
    
//    var maxReps: Int = 20 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//    
//    var reps: Int = 10 {
//        didSet {
//            if (reps == maxReps) {
//                sets += 1;
//                reps = 0;
//            }
//            counterLabel.text = String(reps)
//            setNeedsDisplay()
//        }
//    }
//    var maxSets: Int = 3 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
//    var sets: Int = 2 {
//        didSet {
//            setNeedsDisplay()
//        }
//    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        fmlinit()
    }
    
    override init(frame f: CGRect) {
        super.init(frame: f)
        fmlinit()
    }
    
    func fmlinit(){
        startTime = NSDate()
        
        setLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.frame.width/6, y: 0), size: CGSize(width: self.frame.width/3, height: self.frame.height-20)))
        setLabel.textColor = UIColor.whiteColor()
        setLabel.textAlignment = .Center
        setLabel.font = UIFont(name: "RonduitCapitals-Light", size: 42)
        setLabel.text = "0"
        setLabel.alpha = 0
        self.addSubview(setLabel)
        
        setSubLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.frame.width/6, y: self.frame.height/2+15), size: CGSize(width: self.frame.width/3, height:15)))
        setSubLabel.textColor = UIColor.whiteColor()
        setSubLabel.textAlignment = .Center
        setSubLabel.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        setSubLabel.text = "SETS"
        setSubLabel.alpha = 0
        self.addSubview(setSubLabel)
        
        counterLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.frame.width/2, y: 0), size:CGSize(width: self.frame.width/3, height: self.frame.height-20)))
        counterLabel.textColor = UIColor.whiteColor()
        counterLabel.textAlignment = .Center
        counterLabel.font = UIFont(name: "RonduitCapitals-Light", size: 42)
        counterLabel.text = "0"
        counterLabel.alpha = 0
        self.addSubview(counterLabel)
        
        counterSubLabel = UILabel(frame: CGRect(origin: CGPoint(x: self.frame.width/2, y: self.frame.height/2+15), size: CGSize(width: self.frame.width/3, height:15)))
        counterSubLabel.textColor = UIColor.whiteColor()
        counterSubLabel.textAlignment = .Center
        counterSubLabel.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        counterSubLabel.text = "REPS"
        counterSubLabel.alpha = 0
        self.addSubview(counterSubLabel)
        
        timerLabel = UILabel(frame: CGRect(origin: CGPoint(x: 0, y: self.frame.height-50), size:CGSize(width: self.frame.width, height: 50)))
        timerLabel.textColor = UIColor.whiteColor()
        timerLabel.textAlignment = .Center
        timerLabel.font = UIFont(name: "RonduitCapitals-Light", size: 32)
        timerLabel.text = "0.0"
        timerLabel.alpha = 0
        self.addSubview(timerLabel)
        
        timer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: #selector(CounterView.timerFire), userInfo: nil, repeats: true)
        
        
        startbtn = UIButton(frame: CGRect(x: 60, y: 60, width: 80, height: 80))
        startbtn.layer.borderWidth = 1
        startbtn.layer.borderColor = UIColor.whiteColor().CGColor
        startbtn.layer.cornerRadius = 10
        startbtn.setTitle("START", forState: .Normal)
        startbtn.titleLabel?.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        startbtn.titleLabel?.textColor = UIColor.whiteColor()
        startbtn.titleLabel?.textAlignment = .Center
        startbtn.addTarget(self, action: #selector(CounterView.startPressed), forControlEvents: UIControlEvents.TouchUpInside)
        self.addSubview(startbtn)
    }
    
    override func drawRect(rect: CGRect) {
        let center = CGPoint(x: bounds.width/2, y: bounds.height/2)
        let radius: CGFloat = max(bounds.width, bounds.height)/2
        let arcWidth: CGFloat = 2
        
        for i in 0...maxSets - 1 {
            let setIncrement = 3.0*π/2.0/CGFloat(maxSets)
            let repIncrement = (setIncrement - 2 * CGFloat(setSpacing)) / CGFloat(maxReps)
            
            if (i < sets) {
                let startAngle: CGFloat = 3*π/4 + CGFloat(i) * CGFloat(setIncrement) + CGFloat(setSpacing)
                let endAngle: CGFloat = startAngle + CGFloat(setIncrement) - CGFloat(setSpacing) * 2
                
                let path = UIBezierPath(arcCenter: center, radius: radius - arcWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                
                path.lineWidth = arcWidth
                
                UIColor.whiteColor().colorWithAlphaComponent(0.9).setStroke()
                path.stroke()
            } else {
                for j in 0...maxReps - 1 {
                    let startAngle: CGFloat = 3*π/4 + CGFloat(i) * CGFloat(setIncrement) + CGFloat(setSpacing) + CGFloat(j) * CGFloat(repIncrement) + CGFloat(repSpacing)
                    let endAngle: CGFloat = startAngle + CGFloat(repIncrement) - CGFloat(repSpacing) * 2
                    
                    let path = UIBezierPath(arcCenter: center, radius: radius - arcWidth/2, startAngle: startAngle, endAngle: endAngle, clockwise: true)
                    
                    path.lineWidth = arcWidth
                    
                    if i == sets && j < reps {
                        UIColor.whiteColor().colorWithAlphaComponent(0.9).setStroke()
                    } else {
                        UIColor.whiteColor().colorWithAlphaComponent(0.3).setStroke()
                    }
                    path.stroke()
                }
            }
        }
        setLabel.text = "\(Int(sets))"
        counterLabel.text = "\(Int(reps))"
    }
    
    func startPressed() {
        let global = Global.sharedManager() as! Global
        global.STATE = global.PERSON_TRACKING
        setLabel.alpha = 1
        setSubLabel.alpha = 1
        counterLabel.alpha = 1
        counterSubLabel.alpha = 1
        timerLabel.alpha = 1
        startbtn.alpha = 0
        startTime = NSDate()
    }
    
    func setFinished() {
        setLabel.alpha = 0
        setSubLabel.alpha = 0
        counterLabel.alpha = 0
        counterSubLabel.alpha = 0
        timerLabel.alpha = 0
        startbtn.alpha = 1
        startTime = NSDate()
    }
    
    func timerFire() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle
        let time = NSDate().timeIntervalSinceDate(startTime!)
        let timeString = "\(floor(time*10)/10.0)"
        timerLabel.text = timeString
    }
}
