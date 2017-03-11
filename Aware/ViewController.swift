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
import StoreKit

class ViewController: UIViewController,MFMailComposeViewControllerDelegate,DSDLocationHandlerDelegate,SKProductsRequestDelegate,
SKPaymentTransactionObserver {

    @IBOutlet weak var textfieldName: UITextField!
    @IBOutlet weak var textfieldLocation: UITextField!
    @IBOutlet weak var textfieldTitle: UITextField!
    @IBOutlet weak var textViewDetails: UITextView!
    
    @IBOutlet weak var btnDonate: UIBarButtonItem!
    var productID = ""
    var productsRequest = SKProductsRequest()   //productsRequest is an instance of SKProductsRequest, needed to search for IAP products from your app on iTC.
    var iapProducts = [SKProduct]() //iapProducts is a simple array of SKProducts.
    var nonConsumablePurchaseMade = UserDefaults.standard.bool(forKey: KKEY_PURCHASE_MADE)  //needed to track purchases
//    var coins = UserDefaults.standard.integer(forKey: "coins")
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        setUI()
        startInAppPurchase()
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
    
    @IBAction func btnDonateAction(_ sender: UIBarButtonItem)
    {
        if(sender.tag == KRestoreButtonTag){
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().restoreCompletedTransactions()
        }else{
            if(iapProducts.count>0){
                purchaseMyProduct(product: iapProducts[0])
            }else{
                Utility.showAlertMessage(title: "Server error", subTitle: "Please restart application", messageType: .error)
            }
            
        }
    }
    
    //MARL: User defined action
    func showSendMailErrorAlert() {
        Utility.showAlertMessage(title: "Could Not Send Email", subTitle: "Your device could not send e-mail. Please check e-mail configuration and try again", messageType: .error)
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
    
    //MARK: In App purchase
    // MARK: - MAKE PURCHASE OF A PRODUCT
    func canMakePurchases() -> Bool {
        return SKPaymentQueue.canMakePayments()
    }
    
    //It starts the payment queue and changes our productID variable into the selected productIdentifier
    func purchaseMyProduct(product: SKProduct) {
        if self.canMakePurchases() {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(self)
            SKPaymentQueue.default().add(payment)
            
            print("PRODUCT TO PURCHASE: \(product.productIdentifier)")
            productID = product.productIdentifier
            
            
            // IAP Purchases dsabled on the Device
        } else {
            UIAlertView(title: KALERT_TITLE,
                        message: "Purchases are disabled in your device!",
                        delegate: nil, cancelButtonTitle: "OK").show()
        }
    }
    
    private func startInAppPurchase(){
        if nonConsumablePurchaseMade
        {
            self.setDataAfterInAppPurchaseTransaction(isPurchased: true)            
        }
        else
        {
            self.setDataAfterInAppPurchaseTransaction(isPurchased: false)
        }
        
        // Fetch IAP Products available
        fetchAvailableProducts()
    }
    
    //FETCH AVAILABLE IAP PRODUCTS
    func fetchAvailableProducts()  {
        
        // Put here your IAP Products ID's
        let productIdentifiers = NSSet(objects:DONATE_PRODUCT_ID)
        
        productsRequest = SKProductsRequest(productIdentifiers: productIdentifiers as! Set<String>)
        productsRequest.delegate = self
        productsRequest.start() //start an SKProductsRequest based on identifier, in order for the app to display the info about the IAP products (description and price), which will be processed by below delegate method(productsRequest:didReceive)
    }
    
    //REQUEST IAP PRODUCTS
    func productsRequest (_ request:SKProductsRequest, didReceive response:SKProductsResponse) {
        if (response.products.count > 0) {
            iapProducts = response.products
            
            let firstProduct = response.products[0] as SKProduct
            
            // Get its price from iTunes Connect
            let numberFormatter = NumberFormatter()
            numberFormatter.formatterBehavior = .behavior10_4
            numberFormatter.numberStyle = .currency
            numberFormatter.locale = firstProduct.priceLocale
            
            // Get its price from iTunes Connect
            numberFormatter.locale = firstProduct.priceLocale
            let price2Str = numberFormatter.string(from: firstProduct.price)
            
            // Show its description
            print(firstProduct.localizedDescription + "for just \(price2Str!)")
//            nonConsumableLabel.text = secondProd.localizedDescription + "\nfor just \(price2Str!)"
            // ------------------------------------
        }
    }
    
    private func setDataAfterInAppPurchaseTransaction(isPurchased : Bool){
        if(isPurchased == true){
            nonConsumablePurchaseMade = true
            UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: KKEY_PURCHASE_MADE)
            btnDonate.title = "Restore ₹10"
            btnDonate.tag = KRestoreButtonTag
        }else{
            nonConsumablePurchaseMade = false
            UserDefaults.standard.set(nonConsumablePurchaseMade, forKey: KKEY_PURCHASE_MADE)
            btnDonate.title = "Donate ₹10"
            btnDonate.tag = KDonateButtonTag
        }
        
    }
    
    //Store kit delegate methods
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) {
        // Restore your purchase locally (needed only for Non-Consumable IAP)
        self.setDataAfterInAppPurchaseTransaction(isPurchased: false)
        
        UIAlertView(title: KALERT_TITLE,
                    message: "You've successfully restored your purchase!",
                    delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    // MARK:- IAP PAYMENT QUEUE
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction:AnyObject in transactions {
            if let trans = transaction as? SKPaymentTransaction {
                switch trans.transactionState {
                    
                case .purchased:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    
                     if productID == DONATE_PRODUCT_ID
                     {                        
                        // Save your purchase locally (needed only for Non-Consumable IAP)
                        self.setDataAfterInAppPurchaseTransaction(isPurchased: true)
                        
                        UIAlertView(title: KALERT_TITLE,
                                    message: "You've successfully donate me ₹10! Thank you",
                                    delegate: nil,
                                    cancelButtonTitle: "OK").show()
                    }
                    
                    break
                    
                case .failed:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    Utility.showAlertMessage(title: "Not able to donate. Retry please.", subTitle: "", messageType: .error)

                    break
                case .restored:
                    SKPaymentQueue.default().finishTransaction(transaction as! SKPaymentTransaction)
                    break
                    
                default: break
                }}}
    }
}

