//
//  Macros.swift
//  app
//
//  Created by Jorge Efrain Sanchez Figueroa on 11/02/20.
//  Copyright © 2020 Facebook. All rights reserved.
//

import Foundation
import UIKit

struct Constants {
  
  struct Main {
    static let userAgent = " [D-iOS; ClaroConnect/\(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? UIDevice.current.systemVersion)]"
    static let urlWithWebView = URL(string: "https://beta.claroconnect.com/iam/management")
    static let congratsURL = URL(string: "https://beta.claroconnect.com/iam/congrats")
    static let initConference = "https://beta.claroconnect.com/"
  }
  
}
