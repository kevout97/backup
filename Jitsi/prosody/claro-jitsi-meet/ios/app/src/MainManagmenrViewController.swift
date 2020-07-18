//
//  MainManagmenrViewController.swift
//  jitsi-meet
//
//  Created by Jorge Efrain Sanchez Figueroa on 05/02/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import UIKit
import WebKit
import JitsiMeet
import GoogleSignIn

class MainManagmenrViewController: UIViewController, WKScriptMessageHandler, WKUIDelegate{
  
  var webView: WKWebView!
  fileprivate var pipViewCoordinator: PiPViewCoordinator?
  fileprivate var jitsiMeetView: JitsiMeetView?
  lazy var url = Constants.Main.urlWithWebView
  private lazy var modelView:MainModelView = {
    return MainModelView()
  }()
    
  override func viewDidLoad() {
        super.viewDidLoad()
    self.configureWebView()
    self.modelView.observeNetworkInitializer()
    self.modelView.delegate = self
    GIDSignIn.sharedInstance()?.delegate = self
    GIDSignIn.sharedInstance()?.presentingViewController = self
    //Revisa sesiones en google previas
    GIDSignIn.sharedInstance()?.restorePreviousSignIn()
    NotificationCenter.default.addObserver(self, selector: #selector(reloadWebView(notfication:)), name: Notification.Name("reloadWebView"), object: nil)
    }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(true)
    NotificationCenter.default.removeObserver(self)
    self.modelView.removeObserver()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(true)
    self.loadURL(url: self.url!)
    
  }
  
  @objc private func reloadWebView(notfication: NSNotification) {
    let dictionary = notfication.userInfo
    if pipViewCoordinator == nil{
      guard let url = dictionary?["url"] as? URL else {return}
      self.url = url
      self.loadURL(url: self.url!)
    }else{
      let alert = UIAlertController(title: nil, message: "Ya estas en una conferencia", preferredStyle: .alert)
      let action = UIAlertAction(title: "Ok", style: .default, handler: nil)
      alert.addAction(action)
      self.present(alert, animated: true, completion: nil)
    }
  }
  
  override func viewWillTransition(to size: CGSize,
                                   with coordinator: UIViewControllerTransitionCoordinator) {
      super.viewWillTransition(to: size, with: coordinator)
    
  
      let rect = CGRect(origin: CGPoint.zero, size: size)
    
    if let errorView = self.modelView.errorView{
      errorView.frame = rect
    }
      pipViewCoordinator?.resetBounds(bounds: rect)
  }
  
  private func configureWebView(){
    let configuration = WKWebViewConfiguration()
    let controller = WKUserContentController()
    controller.add(self, name: "IOs")
    configuration.userContentController = controller
    configuration.preferences.javaScriptEnabled = true
    self.webView = WKWebView(frame:.zero, configuration: configuration)
    self.webView.uiDelegate = self
    self.webView.evaluateJavaScript("navigator.userAgent") { (result, error) in
        if error == nil {
          guard let userAgent = result as? String else{return}
          self.webView.customUserAgent = userAgent + Constants.Main.userAgent
        }
    }
    self.webView.allowsBackForwardNavigationGestures = false
    self.view = webView
  }
  
  private func loadURL(url : URL){
    if self.modelView.errorView == nil && self.modelView.errorIsViewOpen == true{
      self.showErrorView()
    }else{
      let request = URLRequest(url: url)
      self.webView.load(request)
    }
  }
  
  fileprivate func cleanUp() {
      jitsiMeetView?.removeFromSuperview()
      jitsiMeetView = nil
      pipViewCoordinator = nil
  }
  
  private func dismissErrorView(){
    if let errorView = self.modelView.errorView{
      errorView.delegate = nil
      self.modelView.errorIsViewOpen = false
      errorView.removeFromSuperview()
    }
    self.modelView.errorView = nil
  }
  
  private func showErrorView(){
    self.modelView.errorView = CCWebViewConnectionErrorView(frame: self.view.bounds)
          if let errorView = self.modelView.errorView{
            self.modelView.errorIsViewOpen = true
            errorView.delegate = self
            self.modelView.errorView?.tryAgainButtonIB.isHidden = true
            self.view.addSubview(errorView)
    }
  }
}

extension MainManagmenrViewController{
  func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
    if message.name == "IOs"{
      self.modelView.joinModel(body: message.body)
    }
  }
  
  func webView(_ webView: WKWebView,
               runJavaScriptAlertPanelWithMessage message: String,
               initiatedByFrame frame: WKFrameInfo,
               completionHandler: @escaping () -> Void) {
      let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
      let title = NSLocalizedString("OK", comment: "OK Button")
      let ok = UIAlertAction(title: title, style: .default) { (action: UIAlertAction) -> Void in
          alert.dismiss(animated: true, completion: nil)
      }
      alert.addAction(ok)
      present(alert, animated: true)
      completionHandler()
  }
}

extension MainManagmenrViewController : CCWebViewConnectionErrorDelegate
{
  func reloadData() {
    self.dismissErrorView()
    self.loadURL(url: self.url!)
  }
  
  func cancel() {
    exit(0)
  }
}

extension MainManagmenrViewController: JitsiMeetViewDelegate {
  
  func conferenceRoomLeave(_ data: [AnyHashable : Any]!) {
    let userType = UserDefaults.standard.string(forKey: "userType")
    if userType?.lowercased() == "guest" {
        if let appDomain = Bundle.main.bundleIdentifier{
        UserDefaults.standard.removePersistentDomain(forName: appDomain)
          self.url = Constants.Main.congratsURL
          self.loadURL(url: self.url!)
      }
    }else{
      self.url = Constants.Main.urlWithWebView
      self.loadURL(url: self.url!)
    }
    
      DispatchQueue.main.async {
          self.pipViewCoordinator?.hide() { _ in
              self.cleanUp()
          }
      }
  }
      
//    func enterPicture(inPicture data: [AnyHashable : Any]!) {
//        DispatchQueue.main.async {
//            self.pipViewCoordinator?.enterPictureInPicture()
//        }
//    }
}

extension MainManagmenrViewController: MainModelViewDelegate{
  func openConference(data: JoinModel) {
    
    self.cleanUp()
    let jitsiMeetView = JitsiMeetView()
    jitsiMeetView.delegate = self
    self.jitsiMeetView = jitsiMeetView
    let text = Constants.Main.initConference
    let url = URL(string: text)
    let dates = JitsiMeetUserInfo()
    dates.displayName = data.name
    dates.email = data.email
    let options = JitsiMeetConferenceOptions.fromBuilder { (builder) in
      builder.serverURL = url
      builder.room = data.confId
      builder.subject = data.conferenceSubject == "" ? data.confId : data.conferenceSubject
      builder.audioOnly = false
      builder.audioMuted = !data.isMicroEnabled
      builder.videoMuted = !data.isCameraEnabled
      builder.userInfo = dates
      builder.welcomePageEnabled = false
    }
    
    DispatchQueue.main.async {
      jitsiMeetView.join(options)
      self.pipViewCoordinator = PiPViewCoordinator(withView: jitsiMeetView)
      self.pipViewCoordinator?.configureAsStickyView(withParentView: self.view)
      jitsiMeetView.alpha = 0
      self.pipViewCoordinator?.resetBounds(bounds: self.view.bounds)
      self.pipViewCoordinator?.show()
    }
  }
  
  func networkChangeStatus(status: Bool) {
    if status{
      if self.pipViewCoordinator != nil{
        self.modelView.errorView = nil
        self.modelView.errorIsViewOpen = false
      }
      if self.modelView.errorIsViewOpen{
        self.modelView.errorView?.tryAgainButtonIB.isHidden = false
      }
    }else{
      if !self.modelView.errorIsViewOpen && self.pipViewCoordinator == nil{
        self.showErrorView()
      }else if !self.modelView.errorIsViewOpen{
        self.modelView.errorView = nil
        self.modelView.errorIsViewOpen = true
      }
    }
  }
}

extension MainManagmenrViewController : GIDSignInDelegate{
  func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
    self.modelView.validateSignInGoogle(didSignInFor: user, withError: error, webview: self.webView)
  }
  func sign(_ signIn: GIDSignIn!, didDisconnectWith user: GIDGoogleUser!, withError error: Error!) {
    print("error")
  }
}
