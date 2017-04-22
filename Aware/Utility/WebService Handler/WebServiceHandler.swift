//
//  WebServiceHandler.swift
//

//MARK:- README
/*
 // I have created one generic method (apiRequest) for Api call.
 // Create individual method for each dedicated api call like I do
*/

import UIKit
import Alamofire

class WebServiceHandler: NSObject {

    class var sharedInstance: WebServiceHandler {
        struct Static {
            static let instance: WebServiceHandler = WebServiceHandler()
        }
        return Static.instance
    }
    
    // MARK: Common Request
    func apiGetRequest( method: Alamofire.HTTPMethod, url: String, completion:@escaping ( _ finished: Bool, _ response: AnyObject?) ->Void) {
        
        Alamofire.request(url, method: method).responseJSON { response in
            if let JSON = response.result.value {
                completion(true, JSON as AnyObject?)
            } else {
                completion(false, response.result.error as AnyObject?)
            }
        }
    }
    
    
    func apiPostRequest( method: Alamofire.HTTPMethod, parameters:Parameters, url: String, completion:@escaping ( _ finished: Bool, _ response: AnyObject?) ->Void) {

        Alamofire.request(url, method: method, parameters: parameters, encoding: JSONEncoding.default, headers: nil).responseJSON { (response) in
            if let JSON = response.result.value {
                completion(true, JSON as AnyObject?)
            } else {
                completion(false, response.result.error as AnyObject?)
            }
        }
    }
    
    
    // MARK: Fetch music information
    func postAwareInformation(parameters:Parameters, successBlock:@escaping ( _ result : Root) -> Void,failureBlock:@escaping (_ error:NSError)->Void)
    {
        Utility.showLoader()    //Show loader indicator. This loader indicator is created in Utility class without the use of third party
        let musicInfoUrl = BASE_URL + URL_ADD_AWARE_DETAILS

        self.apiPostRequest(method: .post, parameters: parameters, url: musicInfoUrl) { (finished, response) in
            if(finished){
                if let dictionaryPlayout = response{
                    let awareInformationModelObject = HomeBusinessLayer.sharedInstance.parseArrayJsonData(data: dictionaryPlayout as! Dictionary<String, Any>)
                    
                    successBlock(awareInformationModelObject)
                }
                Utility.hideLoader()
            }else{
                let error = response as! NSError
                failureBlock(error)
                Utility.hideLoader()
            }
        }
        
    }
    
}
