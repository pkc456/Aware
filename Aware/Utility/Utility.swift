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
    
}
