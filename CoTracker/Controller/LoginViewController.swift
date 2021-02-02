//
//  LoginViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/22/20.
//

import UIKit
import Firebase
import FirebaseAuth
import GoogleSignIn

class LoginViewController: UIViewController, GIDSignInDelegate {
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    @IBOutlet weak var gSignInButton: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkSignOut()
        initialSetting()
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    func initialSetting(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        GIDSignIn.sharedInstance()?.delegate = self
        
        emailField.delegate = self
        passwordField.delegate = self
        passwordField.isSecureTextEntry = true
        
        signInButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        signInButton.setTitleColor(.white, for: .normal)
        signInButton.layer.cornerRadius = 5
        signInButton.layer.shadowColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        signInButton.layer.shadowOffset = CGSize(width: 1, height: 2)
        signInButton.layer.shadowOpacity = 1
        
    }
    
    func checkSignOut(){
        if FirebaseAuth.Auth.auth().currentUser != nil {
            goNext()
        }
    }
    
    @IBAction func signUpButtonPressed(_ sender: Any) {
        let alert = UIAlertController(title: "SIGN UP", message: "Enter your email address and password.", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "abc@abc.com"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "password"
            textField.isSecureTextEntry = true
        }
        alert.addAction(UIAlertAction(title: "CREATE", style: .default, handler: { (action) in
            let email = alert.textFields![0].text
            let password = alert.textFields![1].text
            if !email!.isEmpty && !password!.isEmpty {
                FirebaseAuth.Auth.auth().createUser(withEmail: email!, password: password!) { [weak self] result, error in
                    guard let strongSelf = self else {
                        return
                    }
                    guard error == nil else {
                        let loginFailAlert = UIAlertController(title: "Failure", message: error?.localizedDescription, preferredStyle: .alert)
                        loginFailAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        strongSelf.present(loginFailAlert, animated: true, completion: nil)
                        return
                    }
                    strongSelf.loginSuccess(email: email!)
                }
            }
        }))
        alert.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)

    }
    
    @IBAction func signInButtonPressed(_ sender: Any) {
        guard let email = emailField.text, !email.isEmpty,
              let password = passwordField.text, !password.isEmpty else {
            return
        }
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] result, error in
                        
            guard let strongSelf = self else {
                return
            }
            guard error == nil else {
                let loginFailAlert = UIAlertController(title: "Login Failed", message: error?.localizedDescription, preferredStyle: .alert)
                loginFailAlert.addAction(UIAlertAction(title: "Try Again", style: .default, handler: nil))
                strongSelf.present(loginFailAlert, animated: true, completion: nil)
                return
            }
            strongSelf.loginSuccess(email: email)
        })
        
    }
 
    func loginSuccess(email: String){
        UserDefaults.standard.setValue(true, forKey: "login")
        UserDefaults.standard.setValue(email, forKey: "email")
        setUserId(email: email)
        
        self.emailField.text = ""
        self.passwordField.text = ""

        goNext()
    }
    
    /// Move to next page when login success
    func goNext(){
        let next = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "tabbar") as! UITabBarController
        next.modalPresentationStyle = .fullScreen
        self.present(next, animated: true, completion: nil)
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        guard error == nil else {
            print("Google SignIn Failed")
            return
        }
        guard let authentication = user.authentication else {
            print("Google authentication failed")
            return
        }
        let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
        FirebaseAuth.Auth.auth().signIn(with: credential) { (result, error) in
            guard error == nil else {
                print("Google credition failed")
                return
            }
            self.loginSuccess(email: user.profile.email)
        }
    }
    
    func setUserId(email: String){
        let splitEmail = email.components(separatedBy: "@")
        UserDefaults.standard.setValue(splitEmail[0], forKey: "userId")
    }    
}

//MARK:- Textfield delegate

extension LoginViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(notification: NSNotification){
        guard let size = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]) as? NSValue else {
            return
        }
        self.view.frame.origin.y = 0 - size.cgRectValue.height
    }
    
    @objc func keyboardWillHide(notification: NSNotification){
        self.view.frame.origin.y = 0
    }
}
