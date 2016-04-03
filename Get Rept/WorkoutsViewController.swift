//
//  WorkoutsViewController.swift
//  Get Rept
//
//  Created by Sebastian Cain on 4/2/16.
//  Copyright © 2016 Avery Lamp. All rights reserved.
//

import UIKit

class WorkoutsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    let wtv = UITableView()
    let gv = GradientView()
    let workoutTitles = ["BABY", "MEDIOCRE", "TOUGH", "HARDCORE", "ENDURANCE"]
    let workoutSets = [2, 3, 3, 4, 1]
    let workoutReps = [5, 10, 15, 20, 60]
    
    override func viewWillLayoutSubviews() {
        super.viewDidLoad()
        gv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.insertSubview(gv, atIndex: 0)
        
        wtv.frame = CGRect(x: 0, y: 80, width: self.view.frame.width, height: self.view.frame.height-80)
        wtv.delegate = self
        wtv.dataSource = self
        wtv.registerClass(UITableViewCell.classForKeyedArchiver(), forCellReuseIdentifier: "cell")
        wtv.backgroundColor = UIColor.clearColor()
        wtv.separatorStyle = .None
        self.view.addSubview(wtv)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .Default, reuseIdentifier: "cell")
        cell.backgroundColor = UIColor.clearColor()
        let row = indexPath.row
        
        let lbl = UILabel(frame: CGRect(x: 40, y: 2, width: self.view.frame.width-80, height: 58))
        lbl.text = workoutTitles[row]
        lbl.font = UIFont(name: "RonduitCapitals-Light", size: 14)
        lbl.textAlignment = .Left
        lbl.textColor = UIColor.whiteColor()
        cell.addSubview(lbl)
        
        let lbl2 = UILabel(frame: CGRect(x: 40, y: 2, width: self.view.frame.width-80, height: 58))
        lbl2.text = "\(workoutSets[row]) sets, \(workoutReps[row]) reps"
        lbl2.font = UIFont(name: "RonduitCapitals-Light", size: 10)
        lbl2.textAlignment = .Right
        lbl2.textColor = UIColor(white: 1, alpha: 0.5)
        cell.addSubview(lbl2)
        
        let bs = UIView(frame: CGRect(x: 20, y: 59, width: self.view.frame.width-40, height: 1))
        bs.backgroundColor = UIColor(white: 1, alpha: 0.3)
        bs.clipsToBounds = true
        cell.addSubview(bs)
        
        return cell
    }
    
    
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60.0
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let vc = ReppinViewController()
        vc.repTarget = workoutReps[indexPath.row]
        vc.setTarget = workoutSets[indexPath.row]
        presentViewController(vc, animated: true, completion: nil)
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
