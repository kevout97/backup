//
//  MainModelView.swift
//  jitsi-meet
//
//  Created by Jorge Efrain Sanchez Figueroa on 17/02/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import Reachability
import GoogleSignIn
import WebKit

class MainModelView{
  
  var joinModel = JoinModel()
  weak var delegate:MainModelViewDelegate?
  var errorView : CCWebViewConnectionErrorView?
  var errorIsViewOpen = false
  private var reachability : Reachability!
  
  func joinModel(body : Any){
    guard let str = body as? String else {return}
    guard let data = str.data(using: .utf8) else {return}
      if let dic = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any]{
        guard let type = dic["type"] as? String else {return}
        self.joinModel.actionType = type.lowercased()
        guard let eventType = EventType(rawValue: self.joinModel.actionType) else {return}
        switch eventType {
        case .StartConferente, .JoinConference:
          guard let payload = dic["payload"] as? NSDictionary else {return}
          guard let name = payload["name"] as? String else {return}
          guard let email = payload["email"] as? String else {return}
          guard let userType = payload["type"] as? String else {return}
          
          if UserDefaults.standard.string(forKey: "userType")?.lowercased() != "user"{
            UserDefaults.standard.set(name, forKey: "displayName")
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set(userType, forKey: "userType")
            guard let language = payload["lang"] as? String else {return}
            guard let virtualNumber = payload["phone_v"] as? String else {return}
            self.joinModel.language = language
            self.joinModel.virtualNumber = virtualNumber
            UserDefaults.standard.set(self.joinModel.language, forKey: "language")
            UserDefaults.standard.set(self.joinModel.virtualNumber, forKey: "virtualNumber")
          }
    
          guard let confid = payload["confId"] as? String else {return}
          guard let micro = payload["micro"] as? Bool else {return}
          guard let camera = payload["camera"] as? Bool else {return}
          self.joinModel.name = name
          self.joinModel.email = email
          self.joinModel.userType = userType
          self.joinModel.confId = confid
          self.joinModel.isCameraEnabled = camera
          self.joinModel.isMicroEnabled = micro
          if let conferenceSubject = payload["conferenceSubject"] as? String{
            self.joinModel.conferenceSubject = conferenceSubject
          }
          UserDefaults.standard.set(self.joinModel.isCameraEnabled, forKey: "startWithVideoMuted")
          UserDefaults.standard.set(self.joinModel.isMicroEnabled, forKey: "startWithAudioMuted")
          print(payload)
          self.delegate?.openConference(data: self.joinModel)
          break
          
        case .LoginUser:
          guard let payload = dic["payload"] as? NSDictionary else {return}
          guard let name = payload["name"] as? String else {return}
          guard let email = payload["email"] as? String else {return}
          guard let userType = payload["type"] as? String else {return}
          guard let language = payload["lang"] as? String else {return}
          guard let virtualNumber = payload["phone_v"] as? String else {return}
          self.joinModel.virtualNumber = virtualNumber
          self.joinModel.language = language
          self.joinModel.name = name
          self.joinModel.email = email
          self.joinModel.userType = userType
          UserDefaults.standard.set(self.joinModel.language, forKey: "language")
          UserDefaults.standard.set(self.joinModel.virtualNumber, forKey: "virtualNumber")
          UserDefaults.standard.set(self.joinModel.name, forKey: "displayName")
          UserDefaults.standard.set(self.joinModel.email, forKey: "email")
          UserDefaults.standard.set(self.joinModel.userType, forKey: "userType")
          break
          
        case .OauthLogin, .OauthLogout:
          guard let payload = dic["payload"] as? NSDictionary else {return}
          guard let externalCalendar = payload["externalCalendarType"] as? String else {return}
           guard let calendarType = ExternalCalendar(rawValue: externalCalendar) else {return}
          if eventType == .OauthLogin {
            self.loginExternalCalendar(with: calendarType)
          }else {
            self.logoutExternalCalendar(with: calendarType)
          }
          break
        case .LogoutUser:
          if let appDomain = Bundle.main.bundleIdentifier{
            UserDefaults.standard.removePersistentDomain(forName: appDomain)
          }
          break
        }
      }
  }
  
  private func loginExternalCalendar(with calendar : ExternalCalendar){
    switch calendar {
    case .google:
      GIDSignIn.sharedInstance()?.signOut()
      GIDSignIn.sharedInstance()?.signIn()
    case .microsoft:
      print("microsoft calendar")
    case .apple:
      print("ical calendar configure")
    }
  }
  
  private func logoutExternalCalendar(with calendar : ExternalCalendar){
      switch calendar {
      case .google:
        GIDSignIn.sharedInstance()?.signOut()
      case .microsoft:
        print("microsoft calendar logout")
      case .apple:
        print("apple calendar logout")
      }
    }
    
  func validateSignInGoogle(didSignInFor user: GIDGoogleUser!, withError error: Error!, webview : WKWebView){
    if let error = error {
      if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
        print("Usuario cerro sesion o no ha iniciado en Google")
      } else {
        print("\(error.localizedDescription)")
        let externalCalendarError = """
                                       {externalCalendarType: "GOOGLE_CALENDAR"}
                                    """
        self.sendEventNativeToJS(webview: webview, action: "OAuthReject", parameters: externalCalendarError)
      }
      return
    }
    guard let token = user.serverAuthCode else {return}
    let externalCalendatToken = """
                                  {externalCalendarType: "GOOGLE_CALENDAR", code: "\(token)"}
                                """
    self.sendEventNativeToJS(webview: webview, action: "OAuthCode", parameters: externalCalendatToken)
  }
  
  private func sendEventNativeToJS(webview : WKWebView, action : String, parameters : String){
    webview.evaluateJavaScript("document.ClaroConnectWebViewNotifier.execute('\(action)',\(parameters))", completionHandler: nil)
  }
  
  func observeNetworkInitializer(){
    self.reachability = try! Reachability()
    NotificationCenter.default.addObserver(self, selector: #selector(self.reachabilityChanged), name: NSNotification.Name.reachabilityChanged, object: nil)
    do{
      try self.reachability.startNotifier()
    }
    catch{
      print("Error ocurrido: ")
    }
  }
  
  @objc func reachabilityChanged(note: Notification){
    let reachability = note.object as! Reachability
    switch reachability.connection {
    case .cellular,.wifi:
      self.delegate?.networkChangeStatus(status: true)
      break
    case .none,.unavailable:
      self.delegate?.networkChangeStatus(status: false)
  }
 }
  
  func removeObserver(){
    NotificationCenter.default.removeObserver(self)
  }
}
