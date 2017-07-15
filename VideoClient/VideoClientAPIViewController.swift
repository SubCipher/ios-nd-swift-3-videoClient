//
//  VideoClientAPIViewController.swift
//  VideoClient
//
//  Created by Krishna Picart on 6/22/17.
//  Copyright © 2017 StepwiseDesigns. All rights reserved.
//

import UIKit
import SafariServices
import AVFoundation

class VideoClientAPIViewController: UIViewController, SFSafariViewControllerDelegate {
    
    weak var delegate: SFSafariViewControllerDelegate?
    let videoClientAPImethods = VideoClientAPImethods()
    
    //youtube constants used to build URLS
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var connectionStatus: UIView!
    
    
    var runCount = 0
    let deviceSettings = VideoClientDeviceSettings.sharedInstance()
    var constructedURLwithTypes: VideoClientDataModel.urlRequestMethodWithType!
    
    @IBOutlet weak var postVideoOutlet: UIButton!
    
    var authCode:String = ""
    
    var reachability: VideoClientNetworkReachability? = VideoClientNetworkReachability.networkReachabilityForInternetConnection()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicatorView.isHidden = true
        postVideoOutlet.isEnabled = false
        
        checkReachability()
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityDidChange(_:)), name: NSNotification.Name(rawValue: ReachabilityDidChangeNotificationName), object:nil)
        _ = reachability?.startNotifier()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
    }
    
    //MARK:- Authentication token Reqest
    //references docs
    //https://developer.apple.com/documentation/safariservices/sfsafariviewcontroller
    //https://stackoverflow.com/questions/38818786/safariviewcontroller-how-to-grab-oauth-token-from-url
    
    
    @IBAction func authentication(_ sender: Any) {
        
        
        let youTubeAuthenticationMethod = URL(string: "\(apiURLs.googleAuthURL)&\(apiParams.responseType)&\(apiClientCreds.clientID)&\(apiScopeURL.upload)&\(apiURLs.redirect+":\(apiClientCreds.scheme)")")
        
        //MARK:- authentication method using Safari view controller w/ helper function to parse accesscode
        NotificationCenter.default.addObserver(self, selector: #selector(accessCodeRequest(_:)), name: Notification.Name("codeRequest"), object: nil)
        
        let safariVC = SFSafariViewController(url: youTubeAuthenticationMethod!)
        safariVC.delegate = self
        self.present(safariVC, animated: true, completion: nil)
    }
    
    @objc func accessCodeRequest(_ notification : Notification) {
        
        guard let codeDataAsURL = notification.object as? URL! else {
            return
        }
        dismiss(animated: false, completion: nil)
        
        authCode =  videoClientAPImethods.filterCodeResponse(codeDataAsURL.absoluteString) { (success, error) in
            
            guard error == nil else {
                
                self.postVideoOutlet.isEnabled = false
                let actionSheet = UIAlertController(title: "Code Request", message: error?.localizedDescription, preferredStyle: .alert)
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(actionSheet,animated: true, completion: nil)
                return
            }
            self.postVideoOutlet.isEnabled = true
        }
    }
    
    
    //MARK:- Authorization Request For Token
    @IBAction func postVideoActionButton(_ sender: Any) {
        
        guard (deviceSettings.outputURL) != nil else {
            postVideoOutlet.isEnabled = false
            
            let actionSheet = UIAlertController(title: "Video", message: "no video selection made", preferredStyle: .alert)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet,animated: true, completion: nil)
            return
        }
        
        activityIndicatorView.isHidden = false
        activityIndicatorView.startAnimating()
        postVideoOutlet.isEnabled = false
        
        let tokenExchangeCode = "code=\(authCode)"
        
        let methodForTokenExchange = "\(apiURLs.baseURL)\(apiMethods.tokenExchangeMethod)\(tokenExchangeCode)&\(apiClientCreds.clientID)&\(apiURLs.redirect):\(apiClientCreds.scheme)&\(apiParams.tokenExchangeGrantType)"
        
        constructedURLwithTypes = VideoClientDataModel.urlRequestMethodWithType(methodForTokenExchange,VideoClientDataModel.httpMethod.POST)
        videoClientAPImethods.methodRequest(constructedURLwithTypes!) {(success,error) in
            
            
            if success == false{
                self.activityIndicatorView.stopAnimating()
                self.activityIndicatorView.isHidden = true
                
                let actionSheet = UIAlertController(title: "MethodRequest", message: error?.localizedDescription, preferredStyle: .alert)
                
                actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                self.present(actionSheet,animated: true, completion: nil)
                
            } else {
                
                let uploadURLasString = "\(apiURLs.baseURL)\(apiMethods.uploadVideoMethod)\(apiParams.uploadPart)"
                
                self.constructedURLwithTypes = VideoClientDataModel.urlRequestMethodWithType(uploadURLasString,VideoClientDataModel.httpMethod.POST)
                
                //add typeSwitch to parse upload request other POST request
                self.constructedURLwithTypes.typeSwitch = 1
                
                self.videoClientAPImethods.methodRequest(self.constructedURLwithTypes!){ (success,error) in
                    
                    guard (error == nil) else {
                        self.activityIndicatorView.stopAnimating()
                        self.activityIndicatorView.isHidden = true
                        
                        let actionSheet = UIAlertController(title: "upload MethodRequest", message: error?.localizedDescription, preferredStyle: .alert)
                        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                        self.present(actionSheet,animated: true, completion: nil)
                        
                        return
                    }
                    
                    self.activityIndicatorView.stopAnimating()
                    self.activityIndicatorView.isHidden = true
                    
                    let actionSheet = UIAlertController(title: "upload MethodRequest", message: "video upload complete", preferredStyle: .alert)
                    
                    actionSheet.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                    self.present(actionSheet,animated: true, completion: nil)
                }
            }
        }
    }
}

extension VideoClientAPIViewController {
    
    //MARK: - network reachability
    
    func checkReachability() {
        guard let networkState = reachability else { return }
        
        //this uses the "slim-line" view running along the lower half of main view to indicate network status
        //green = found connection / red = no connection
        
        if networkState.isReachable {
            
            connectionStatus.backgroundColor = UIColor.init(red: 0.0, green: 1.0, blue: 0.0, alpha: 0.5)
        } else {
            connectionStatus.backgroundColor = UIColor.init(red: 1.0, green: 0.0, blue: 0.0, alpha: 0.5)
            
            //MARK: failed connection alert
            let actionSheet = UIAlertController(title: "NETWORK ERROR", message: "Your Internet Connection Cannot Be Detected", preferredStyle: .alert)
            
            actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(actionSheet,animated: true, completion: nil)
        }
    }
    
    func reachabilityDidChange(_ notification: Notification){
        checkReachability()
    }
}
