//
//  CCWebViewConnectionError.swift
//  Business
//
//  Created by Carlos Rodriguez on 6/20/19.
//  Copyright © 2019 AMCO. All rights reserved.
//

import Foundation
import UIKit

protocol CCWebViewConnectionErrorDelegate: class {

    func reloadData()
    func cancel()
}


open class CCWebViewConnectionErrorView: UIView {
    
    @IBOutlet var contentView: UIView!
    
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var tryAgainButtonIB: UIButton!
    @IBOutlet weak var cancelButtonIB: UIButton!
    
    
    var delegate: CCWebViewConnectionErrorDelegate?
    
    override init (frame : CGRect) {
        super.init(frame : frame)
        self.commonInitialization()
    }
    
    required public init?(coder aDecoder: NSCoder) {
      super.init(coder: aDecoder)
    }
    
    @objc func commonInitialization(){
        let view = Bundle.main.loadNibNamed("CCWebViewConnectionErrorView", owner: self, options: nil)?.first as! UIView
        view.frame = self.bounds
        self.addSubview(view)
        self.titleLabel.text = NSLocalizedString("kStringNoNetwork", comment: "")
		    self.infoLabel.text = NSLocalizedString("kStringInfoNoNetwork", comment: "")
    	  self.tryAgainButtonIB.setTitle(NSLocalizedString("kStringTryAgainNetwork", comment: ""), for: .normal)
    	  self.cancelButtonIB.setTitle(NSLocalizedString("kStringCancel", comment: ""), for: .normal)
    }

    @IBAction func tryAgainButtonPress(_ sender: UIButton) {
        self.delegate?.reloadData()
    }
    
    
    @IBAction func cancelButtonPress(_ sender: UIButton) {
        self.delegate?.cancel()
    }
}
