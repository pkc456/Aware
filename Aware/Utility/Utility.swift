//
//  Utility.swift
//
//  Created by Pardeep Chaudhary.
//  Copyright © 2016 Pardeep Chaudhary. All rights reserved.
//

import UIKit
import RMessage

class Utility: NSObject {
    
    static func showAlertMessage(title:String, subTitle:String, messageType:RMessageType){
        RMessage.showNotification(withTitle: title, subtitle: subTitle, type: messageType, customTypeName: nil, callback: nil)
    }
    
    //Show Loading indicator
    static var activityBaseView:UIView=UIView()
    
    static func showLoader() {
        activityBaseView.frame=(APP_DELEGATE.window?.frame)!
        activityBaseView.backgroundColor=UIColor.white
        activityBaseView.alpha=0.6;
        
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.center = activityBaseView.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        activityBaseView.addSubview(activityIndicator)
        activityIndicator.startAnimating()
        
        APP_DELEGATE.window?.addSubview(activityBaseView)
    }
    
    static func hideLoader()
    {
        activityBaseView.removeFromSuperview()
    }
}

//MARK:- UIView controller Extension
extension UIViewController{
    func showAlert(title: String?, message: String?){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action) -> Void in
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
}
