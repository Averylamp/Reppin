//
//  EndViewController.swift
//  Get Rept
//
//  Created by Sebastian Cain on 4/3/16.
//  Copyright © 2016 Avery Lamp. All rights reserved.
//

import UIKit

class EndViewController: UIViewController {
    let gv = GradientView()
    let titlelbl = UILabel()
    let sharelbl = UILabel()
    let fbv = UIImageView()
    let twv = UIImageView()
    let restartbtn = UIButton()
    let homebtn = UIButton()
    
    override func viewWillLayoutSubviews() {
        
        gv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.insertSubview(gv, atIndex: 0)
        
        titlelbl.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 100)
        titlelbl.text = "SETS COMPLETED"
        titlelbl.textColor = UIColor.whiteColor()
        titlelbl.textAlignment = .Center
        titlelbl.font = UIFont(name: "RonduitCapitals-Light", size: 18)
        self.view.addSubview(titlelbl)
        
        
        sharelbl.frame = CGRect(x: 0, y: self.view.frame.height-300, width: self.view.frame.width, height: 20)
        sharelbl.text = "SHARE YOUR RESULTS ON"
        sharelbl.textColor = UIColor.whiteColor()
        sharelbl.textAlignment = .Center
        sharelbl.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        self.view.addSubview(sharelbl)
        
        fbv.frame = CGRect(x: self.view.frame.width/2-60, y: self.view.frame.height-260, width: 40, height: 40)
        fbv.image = UIImage(named: "Facebook-256-2")
        self.view.addSubview(fbv)
        
        twv.frame = CGRect(x: self.view.frame.width/2+20, y: self.view.frame.height-260, width: 40, height: 40)
        twv.image = UIImage(named: "Twitter-Bird-256")
        self.view.addSubview(twv)
        
        restartbtn.frame = CGRect(x: 40, y: self.view.frame.height-180, width: self.view.frame.width-80, height: 60)
        restartbtn.layer.borderWidth = 1
        restartbtn.layer.borderColor = UIColor.whiteColor().CGColor
        restartbtn.layer.cornerRadius = 10
        restartbtn.setTitle("RESTART WORKOUT", forState: .Normal)
        restartbtn.titleLabel?.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        restartbtn.titleLabel?.textColor = UIColor.whiteColor()
        restartbtn.titleLabel?.textAlignment = .Center
        restartbtn.addTarget(self, action: #selector(EndViewController.restartPressed), forControlEvents: UIControlEvents.TouchUpInside)
        restartbtn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.view.addSubview(restartbtn)
        
        homebtn.frame = CGRect(x: 40, y: self.view.frame.height-100, width: self.view.frame.width-80, height: 60)
        homebtn.layer.borderWidth = 1
        homebtn.layer.borderColor = UIColor.whiteColor().CGColor
        homebtn.layer.cornerRadius = 10
        homebtn.setTitle("HOME", forState: .Normal)
        homebtn.titleLabel?.font = UIFont(name: "RonduitCapitals-Light", size: 24)
        homebtn.titleLabel?.textColor = UIColor.whiteColor()
        homebtn.titleLabel?.textAlignment = .Center
        homebtn.addTarget(self, action: #selector(EndViewController.homePressed), forControlEvents: UIControlEvents.TouchUpInside)
        homebtn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        self.view.addSubview(homebtn)
        
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let global = Global.sharedManager() as! Global
//        print("Data \(global.allRepData) Size = \(global.allRepData.count )")
//        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func restartPressed() {
        presentViewController(WorkoutsViewController(), animated: true, completion: nil)
    }
    
    func homePressed() {
        presentViewController(TitleViewController(), animated: true, completion: nil)
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
