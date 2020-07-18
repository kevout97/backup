//
//  MainModelView+.swift
//  jitsi-meet
//
//  Created by Jorge Efrain Sanchez Figueroa on 28/05/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation

  protocol MainModelViewDelegate: class {
    func openConference(data : JoinModel)
    func networkChangeStatus(status : Bool)
  }

enum ExternalCalendar : String{
  case google = "GOOGLE_CALENDAR"
  case microsoft = "OFFICE_365"
  case apple = ""
}

enum EventType : String {
  case StartConferente = "startconference"
  case JoinConference = "joinconference"
  case LoginUser = "loginuser"
  case OauthLogin = "oauthlogin"
  case OauthLogout = "oauthlogout"
  case LogoutUser = "logout"
}

