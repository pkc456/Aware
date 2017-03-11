//
//  DSDLocationHandler.swift
//  DoorStepDelivery
//
//  Created by rahul chaudhary on 9/22/15.
//  Copyright (c) 2015 rahul chaudhary. All rights reserved.
//

import UIKit
import CoreLocation

protocol DSDLocationHandlerDelegate
{
    func locationHandler(locationHandler:DSDLocationHandler, didGetLocationAddress addDic: Dictionary<String,String>, andLocation: CLLocation)
//     func locationAuthorizedStatus(locationHandler:DSDLocationHandler, didChangeAuthorizationStatus status: CLAuthorizationStatus)
}

class DSDLocationHandler: NSObject, CLLocationManagerDelegate {
    
    // MARK:    Shared Instance
    
    static let sharedInstance = DSDLocationHandler()
    let locationManager = CLLocationManager()
    var delegate: DSDLocationHandlerDelegate?
    
    // MARK:
    
    func startLocationUpdate()
    {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        
        if(locationManager.responds(to: #selector(CLLocationManager.requestWhenInUseAuthorization))){
            if #available(iOS 9.0, *) {
                locationManager.requestLocation()
            } else {
                locationManager.requestAlwaysAuthorization()
            }
        }
        

        if CLLocationManager.locationServicesEnabled()
        {
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func stopLocationUpdate()
    {
        locationManager.stopUpdatingLocation()
    }
    
    //MARK: CLLocation Delegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        
        let locationArray = locations as NSArray
        let locationObj = locationArray.lastObject as! CLLocation
        
        stopLocationUpdate()
        fetchAddressFromLocation(location: locationObj)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("location fail with error: \(error.localizedDescription)")
    
    }
    
    private func locationManager(manager: CLLocationManager, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        switch status {
            
        case .notDetermined:
            // If status has not yet been determied, ask for authorization
                manager.requestWhenInUseAuthorization()
                   case .authorizedWhenInUse:
            // If authorized when in use
            manager.startUpdatingLocation()
        case .authorizedAlways:
            // If always authorized
            manager.startUpdatingLocation()
        case .restricted: break
            // If restricted by e.g. parental controls. User can't enable Location Services
            //pkc
//             HMUtilityClass.sharedInstance.showAlertTitle(KEY_AppAlertTitle, message:RESTRICT_FETCH_LOCATION)
          
        case .denied: break
            // If user denied your app access to Location Services, but can grant access from Settings.app
            
            //navigate to application setting
            //pkc
//                  HMUtilityClass.sharedInstance.showAlertTitle(KEY_AppAlertTitle, message: "To enable, please go to Settings and turn on Location Service, for this app")
                //UIApplication.sharedApplication().openURL(NSURL(string:UIApplicationOpenSettingsURLString)!)
        }
    }
    
   
    
    //MARK: fetch address from location
    
    func fetchAddressFromLocation(location:CLLocation)
    {
       
        CLGeocoder().reverseGeocodeLocation(location, completionHandler: {(placemarks, error) -> Void in
            
            if error != nil {
              //  HMUtilityClass.sharedInstance.showAlertTitle(KEY_AppAlertTitle, message: error!.localizedDescription)
             
                return
            }
            
            if placemarks!.count > 0 {
                let pm = placemarks![0] 
                if pm.postalCode != nil
                {
                    print(pm.subLocality ?? "")// street address, eg. 1 Infinite Loop
                    print(pm.locality ?? "")// city, eg. Cupertino
                    print(pm.administrativeArea ?? "")// state, eg. CA
                    print(pm.postalCode ?? "")// zipcode 110014
                }
                
                var addressDic: Dictionary<String,String> = [String : String]()

                if (pm.subLocality != nil)
                {
                    addressDic["street"] = pm.subLocality
                }
                
                if (pm.locality != nil)
                {
                    addressDic["cityName"] = pm.locality
                }
                
                if (pm.administrativeArea != nil)
                {
                    addressDic["state"] = pm.administrativeArea
                }
                
                if (pm.postalCode != nil)
                {
                    addressDic["zipcode"] = pm.postalCode
                }
                
                if (self.delegate != nil) {
                    self.delegate!.locationHandler(locationHandler: self, didGetLocationAddress:addressDic, andLocation:location)
                }
            }
            else {
//                 HMUtilityClass.sharedInstance.showAlertTitle(KEY_AppAlertTitle, message: UNABLE_FETCH_LOCATION)
               
            }
        })
    }
}
