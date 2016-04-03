//
//  QuestionnaireViewController.swift
//  Get Rept
//
//  Created by Sebastian Cain on 4/3/16.
//  Copyright © 2016 Avery Lamp. All rights reserved.
//

import UIKit

class QuestionnaireViewController: UIViewController, UITextFieldDelegate {
    let gv = GradientView()
    let titlelbl = UILabel()
    let q1lbl = UILabel()
    let q1tf = UITextField()
    let q2lbl = UILabel()
    let q2tf = UITextField()
    let q3lbl = UILabel()
    let q3tf = UITextField()
    let startbtn = UIButton()
    
    override func viewWillLayoutSubviews() {
        
        gv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.insertSubview(gv, atIndex: 0)
        
        titlelbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        titlelbl.text = "questionnaire"
        titlelbl.textColor = UIColor.whiteColor()
        titlelbl.textAlignment = .Center
        titlelbl.font = UIFont(name: "RonduitCapitals-Light", size: 24)
        self.view.addSubview(titlelbl)
        
        q1lbl.frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: 30)
        q1lbl.text = "WHAT IS YOUR GOAL?"
        q1lbl.textColor = UIColor.whiteColor()
        q1lbl.textAlignment = .Center
        q1lbl.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        self.view.addSubview(q1lbl)
        
        q1tf.frame = CGRect(x: 0, y: 110, width: self.view.frame.width, height: 30)
        q1tf.attributedPlaceholder = NSAttributedString(string: "MY GOALS ARE...", attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
        q1tf.borderStyle = .None
        q1tf.textAlignment = .Center
        q1tf.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        q1tf.textColor = UIColor.whiteColor()
        q1tf.delegate = self
        self.view.addSubview(q1tf)
        
        q2lbl.frame = CGRect(x: 0, y: 180, width: self.view.frame.width, height: 60)
        q2lbl.numberOfLines = 2
        q2lbl.text = "WHAT WILL HAPPEN WHEN\nYOU REACH YOUR GOALS?"
        q2lbl.textColor = UIColor.whiteColor()
        q2lbl.textAlignment = .Center
        q2lbl.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        self.view.addSubview(q2lbl)
        
        q2tf.frame = CGRect(x: 0, y: 240, width: self.view.frame.width, height: 30)
        q2tf.attributedPlaceholder = NSAttributedString(string: "I WILL...", attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
        q2tf.borderStyle = .None
        q2tf.textAlignment = .Center
        q2tf.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        q2tf.textColor = UIColor.whiteColor()
        q2tf.delegate = self
        self.view.addSubview(q2tf)
        
        q3lbl.frame = CGRect(x: 0, y: 310, width: self.view.frame.width, height: 60)
        q3lbl.numberOfLines = 2
        q3lbl.text = "HOW WILL YOU FEEL WHEN\nYOU REACH YOUR GOAL?"
        q3lbl.textColor = UIColor.whiteColor()
        q3lbl.textAlignment = .Center
        q3lbl.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        self.view.addSubview(q3lbl)
        
        q3tf.frame = CGRect(x: 0, y: 370, width: self.view.frame.width, height: 30)
        q3tf.attributedPlaceholder = NSAttributedString(string: "I'LL FEEL...", attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
        q3tf.borderStyle = .None
        q3tf.textAlignment = .Center
        q3tf.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        q3tf.textColor = UIColor.whiteColor()
        q3tf.delegate = self
        self.view.addSubview(q3tf)
        
        startbtn.frame = CGRect(x: 40, y: self.view.frame.height-100, width: self.view.frame.width-80, height: 60)
        startbtn.layer.borderWidth = 1
        startbtn.layer.borderColor = UIColor.whiteColor().CGColor
        startbtn.layer.cornerRadius = 10
        startbtn.setTitle("let's go", forState: .Normal)
        startbtn.titleLabel?.font = UIFont(name: "RonduitCapitals-Light", size: 24)
        startbtn.titleLabel?.textColor = UIColor.whiteColor()
        startbtn.titleLabel?.textAlignment = .Center
        startbtn.addTarget(self, action: #selector(QuestionnaireViewController.startPressed), forControlEvents: UIControlEvents.TouchUpInside)
        startbtn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.view.addSubview(startbtn)
    }
    
    func startPressed() {
        presentViewController(WorkoutsViewController(), animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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
