//
//  ViewController.swift
//  Aware
//
//  Created by Pardeep Chaudhary on 03/11/16.
//  Copyright © 2016 Pardeep Chaudhary. All rights reserved.
//

import UIKit
import MessageUI
import CoreLocation
import RMessage

class ViewController: UIViewController,MFMailComposeViewControllerDelegate,DSDLocationHandlerDelegate {

    @IBOutlet weak var textfieldName: UITextField!
    @IBOutlet weak var textfieldLocation: UITextField!
    @IBOutlet weak var textfieldTitle: UITextField!
    @IBOutlet weak var textViewDetails: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUI()
    }
    
    private func setUI(){
        textViewDetails.layer.cornerRadius = 6.0
        textViewDetails.layer.borderColor = UIColor.lightGray.cgColor
        textViewDetails.layer.borderWidth = 1.0
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: IBActions
    @IBAction func btnGetLocationAction(_ sender: UIButton) {
        self.enableLocationServices()
    }

    @IBAction func btnSendAction(_ sender: UIBarButtonItem) {
        
        if(isValid()){
            let mailComposeViewController = configuredMailComposeViewController()
            if MFMailComposeViewController.canSendMail() {
                self.present(mailComposeViewController, animated: true, completion: nil)
            } else {
                self.showSendMailErrorAlert()
            }
        }else{
            
        }
    }
    
    //MARL: User defined action
    func showSendMailErrorAlert() {
        Utility.showAlertMessage(title: "Could Not Send Email", subTitle: "Your device could not send e-mail.  Please check e-mail configuration and try again", messageType: .error)
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(["pkc456@gmail.com"])
        mailComposerVC.setSubject("AWARE APP:- \(textfieldTitle.text!)")
        
        let details = "Hi, \n I \(textfieldName.text!); writing this on the behalf of Aware app from \(textfieldLocation.text!). Details are as follows:- \n \n \(textViewDetails.text!)"
        mailComposerVC.setMessageBody(details, isHTML: false)
        
        return mailComposerVC
    }
    
    func isValid()->Bool{
        var valid = true
        var title = ""
        
        if(textfieldName.text?.isEmpty)!{
            valid = false
            title = "Enter your name"
        }else if(textfieldLocation.text?.isEmpty)!{
            valid = false
            title = "Enter your location manually or tap 'Get Me' button to detect your location"
        }else if(textfieldTitle.text?.isEmpty)!{
            valid = false
            title = "Enter the title of your suggestion/complaint"
        }else if(textViewDetails.text?.isEmpty)!{
            valid = false
            title = "Enter the detials of your suggestion/complaint"
        }
        
        if(valid == false){
            Utility.showAlertMessage(title: title, subTitle: "", messageType: .error)
        }
        
         return valid
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?)
    {
        var title = ""
        var subtitle = ""
        var type : RMessageType = .normal
        switch result {
            case .cancelled:
                title = "Mail cancelled"
                subtitle = "You have cancelled the email"
                type = .warning
            case .saved:
                title = "Mail saved"
                subtitle = "You have saved the email"
                    type = .normal
            case .sent:
                title = "Mail sent"
                subtitle = "Thanks, your feedback/complaint is recieved"
                type = .success
            case .failed:
                title = "Mail send failure"
                subtitle = "Oops, your email is not send"
                type = .error
        }
        Utility.showAlertMessage(title: title, subTitle: subtitle, messageType: type)
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    //MARK: Location handle
    func enableLocationServices()
    {
        DSDLocationHandler.sharedInstance.delegate = self
        DSDLocationHandler.sharedInstance.startLocationUpdate()
    }
    
    //DSDLocationHandlerDelegate
    func locationHandler(locationHandler:DSDLocationHandler, didGetLocationAddress addDic: Dictionary<String,String>, andLocation: CLLocation)
    {
//        let keys = addDic.keys.joined(separator: "-")
        let values = addDic.values.joined(separator: "-")
        textfieldLocation.text = values
        
        DSDLocationHandler.sharedInstance.stopLocationUpdate()
    }
}

