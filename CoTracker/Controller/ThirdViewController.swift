//
//  ThirdViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 1/3/21.
//

import UIKit
import MessageKit

class ThirdViewController: UIViewController {

    @IBOutlet weak var enterButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetting()
        DatabaseManager.shared.getAllMessages { (messages) in
            MessageDataModel.allMessages = messages
        }
    }
    
    func initialSetting(){
        enterButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        enterButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
        enterButton.layer.shadowOffset = CGSize(width: 1, height: 2)
        enterButton.layer.shadowColor = #colorLiteral(red: 0.3333333433, green: 0.3333333433, blue: 0.3333333433, alpha: 1)
        enterButton.layer.cornerRadius = 5
        enterButton.layer.shadowOpacity = 1
    }

}



