//
//  MusicInformationBusinessLayer.swift
//  CokeStudio
//
//  Created by Pradeep Choudhary on 3/18/17.
//  Copyright © 2017 Pardeep chaudhary. All rights reserved.
//

import Foundation

class HomeBusinessLayer: NSObject
{
    class var sharedInstance: HomeBusinessLayer {
        struct Static {
            static let instance: HomeBusinessLayer = HomeBusinessLayer()
        }
        return Static.instance
    }
    
    func parseArrayJsonData(data: Dictionary<String, Any>) -> (Root) {
        let modelObject: Root = Root(json: data)!
        return modelObject
    }
}
