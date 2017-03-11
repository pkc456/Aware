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
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    //MARL: User defined action
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)                
        sendMailErrorAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        
        self.present(sendMailErrorAlert, animated: true, completion: nil)
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
         return true
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        switch result {
        case .cancelled:
            print("Mail cancelled")
        case .saved:
            print("Mail saved")
        case .sent:
            print("Mail sent")
        case .failed:
            print("Mail send failure: \(error?.localizedDescription)")
        }
        
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
        print(addDic)
        print(andLocation)
        
        let keys = addDic.keys.joined(separator: "-")
        let values = addDic.values.joined(separator: "-")

        textfieldLocation.text = values
        
        let sendMailErrorAlert = UIAlertController(title: keys, message: values, preferredStyle: .alert)
        sendMailErrorAlert.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(sendMailErrorAlert, animated: true, completion: nil)
        
        DSDLocationHandler.sharedInstance.stopLocationUpdate()
        
        /*
        let num = (andLocation.coordinate.longitude as NSNumber).floatValue
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 4
        formatter.minimumFractionDigits = 4
        let str = formatter.stringFromNumber(num)
        let num1 = (andLocation.coordinate.latitude as NSNumber).floatValue
        let str1 = formatter.stringFromNumber(num1)
        let latlongDic = ["lat":str1!, "long":str!] as NSDictionary
        HMUtilityClass.saveObjectInUserDefault(latlongDic, key: "LatLong")
        
        let model = HMLocationModel(restDic: addDic as NSDictionary, lat: str1 , long: str,isdefaultLocation: false)
        HMUtilityClass.saveObjectInUserDefault(model, key: "AddressModel")
        */
    }
}

