//
//  TitleViewController.swift
//  
//
//  Created by Sebastian Cain on 4/2/16.
//
//

import UIKit

class TitleViewController: UIViewController, UITextFieldDelegate {
    
    let gv = GradientView()
    @IBOutlet var user: UITextField!
    @IBOutlet var pass: UITextField!
    @IBOutlet var loginbtn: UIButton!
    @IBOutlet var signupbtn: UIButton!
    @IBOutlet var iv: UIImageView!
    
    override func viewWillLayoutSubviews() {
        gv.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height)
        self.view.insertSubview(gv, atIndex: 0)
        
        user.attributedPlaceholder = NSAttributedString(string: "user", attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
        user.delegate = self
        pass.attributedPlaceholder = NSAttributedString(string: "pass", attributes: [NSForegroundColorAttributeName:UIColor(white: 1.0, alpha: 0.5)])
        pass.delegate = self
        
        loginbtn.layer.cornerRadius = 10
        loginbtn.layer.borderWidth = 1
        loginbtn.layer.borderColor = UIColor.whiteColor().CGColor
        loginbtn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        
        signupbtn.layer.cornerRadius = 10
        signupbtn.layer.borderWidth = 1
        signupbtn.layer.borderColor = UIColor.whiteColor().CGColor
        signupbtn.titleEdgeInsets = UIEdgeInsets(top: 3, left: 0, bottom: 0, right: 0)
        
        iv.image = UIImage(named: "weightlifting")
        iv.contentMode = UIViewContentMode.ScaleAspectFit
        iv.alpha = 0.2
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(self.view.frame.height)
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func loginpressed(sender: AnyObject) {
        presentViewController(WorkoutsViewController(), animated: true, completion: nil)
    }

    @IBAction func signuppressed(sender: AnyObject) {
        presentViewController(WorkoutsViewController(), animated: true, completion: nil)
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
