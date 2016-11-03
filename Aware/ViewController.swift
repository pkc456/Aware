//
//  ViewController.swift
//  Aware
//
//  Created by Pardeep Chaudhary on 03/11/16.
//  Copyright © 2016 Pardeep Chaudhary. All rights reserved.
//

import UIKit
import MessageUI

class ViewController: UIViewController,MFMailComposeViewControllerDelegate {

    @IBOutlet weak var textfieldName: UITextField!
    @IBOutlet weak var textfieldLocation: UITextField!
    @IBOutlet weak var textfieldTitle: UITextField!
    @IBOutlet weak var textviewDetails: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func btnGetLocationAction(_ sender: UIButton) {
    }

    @IBAction func btnSendAction(_ sender: UIBarButtonItem) {
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        self.present(sendMailErrorAlert, animated: true, completion: nil)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["pkc456@gmail.com"])
        mailComposerVC.setSubject("AWARE APP:- \(textfieldTitle.text)")
        
        let details = "Hi, \n I am writing this on the behalf of Aware app. Details are as follows:- \n \n \(textviewDetails.text)"
        mailComposerVC.setMessageBody(details, isHTML: false)
        
        return mailComposerVC
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}

