//
//  ForthTableViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/24/20.
//

import UIKit
import Firebase
import MessageUI

class ForthTableViewController: UITableViewController {

    @IBOutlet weak var userId: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        showUserId()
    }
    
    func showUserId(){
        userId.text = "Hello, \(UserDefaults.standard.string(forKey: "userId") ?? "")"
    }
    
    @IBAction func helpFeedbackPressed(_ sender: Any) {
        sendMail()
    }
    
    @IBAction func signOutPressed(_ sender: Any) {
        let auth = Auth.auth()
        do {
            try auth.signOut()
            UserDefaults.standard.setValue(false, forKey: "login")
            UserDefaults.standard.setValue("", forKey: "email")
//            UserDefaults.standard.setValue("", forKey: "userId")
//            UserDefaults.standard.setValue("", forKey: "profilePicture")
            self.dismiss(animated: true, completion: nil)
        } catch {
            print("Sign out error")
        }
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 1
        }else if section == 1{
            return 3
        } else {
            return 1
        }
    }
}


extension ForthTableViewController: MFMailComposeViewControllerDelegate{
    
    func sendMail(){
        if MFMailComposeViewController.canSendMail() {
            let email = MFMailComposeViewController()
            email.mailComposeDelegate = self
            email.setToRecipients(["tltmzmaos@gmail.com"])
            email.setSubject("[CoTracker] Help / Feedback")
            email.setMessageBody("", isHTML: false)
            
            present(email, animated: true, completion: nil)
            
        } else {
            print("email is not available")
            return
        }
    }
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}
