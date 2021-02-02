//
//  AccountInfoViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/28/20.
//

import UIKit
import FirebaseAuth

class AccountInfoViewController: UIViewController {

    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var changePasswordButton: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialSetting()
    }
    
    func initialSetting(){
        let userEmail = FirebaseAuth.Auth.auth().currentUser?.email
        
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = imageView.frame.width / 2
        
        let dbImg = DatabaseManager.getDBEmail(email: userEmail!)
        StorageManager.shared.getImageURL(path: dbImg) { (url, error) in
            guard let url = url, error == nil else {
                print("No image found")
                return
            }
            self.updateImageView(url: url)
        }
        
        emailLabel.text = userEmail
        changePasswordButton.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        changePasswordButton.layer.cornerRadius = 10
        changePasswordButton.setTitleColor(#colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0), for: .normal)
    }
    
    func updateImageView(url: URL){
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                return
            }
            let img = UIImage(data: data)
            DispatchQueue.main.async {
                self.imageView.image = img
            }
        }.resume()
    }
    
    @IBAction func changePhotoPressed(_ sender: Any) {
        selectOptions()
    }
    
    @IBAction func changePasswordPressed(_ sender: Any) {
        let alert = UIAlertController(title: "Change Password", message: "Enter a new password", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "new password"
            textField.isSecureTextEntry = true
        }
        alert.addTextField { (textField) in
            textField.placeholder = "re-enter new password"
            textField.isSecureTextEntry = true
        }
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Change", style: .default, handler: { (action) in
            let password1 = alert.textFields![0].text
            let password2 = alert.textFields![1].text
            if password1 == password2 && !password1!.isEmpty {
                FirebaseAuth.Auth.auth().currentUser?.updatePassword(to: password1!, completion: { (error) in
                    if error != nil {
                        let newAlert = UIAlertController(title: "Error", message: error?.localizedDescription, preferredStyle: .alert)
                        newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(newAlert, animated: true, completion: nil)
                    } else {
                        let newAlert = UIAlertController(title: "Password Changed", message: "Password changed successfully", preferredStyle: .alert)
                        newAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(newAlert, animated: true, completion: nil)
                    }
                })
            }
        }))
        present(alert, animated: true, completion: nil)
    }
}


extension AccountInfoViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func selectOptions() {
        let sheet = UIAlertController(title: "Picture", message: "Select an option below", preferredStyle: .actionSheet)
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        sheet.addAction(UIAlertAction(title: "Take Photo", style: .default, handler: { (action) in
            self.cameraPic()
        }))
        sheet.addAction(UIAlertAction(title: "Photo Library", style: .default, handler: { (action) in
            self.libraryPic()
        }))
        present(sheet, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        print(info)
        guard let img = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }
        self.imageView.image = img
        let user = User(email: (FirebaseAuth.Auth.auth().currentUser?.email)!)

        DatabaseManager.shared.newUserPhoto(with: user) { (success) in
            if success {
                guard let image = self.imageView.image, let data = image.pngData() else {
                    return
                }
                let file = user.profiePicture
                print(file)
                StorageManager.shared.uploadPicture(with: data, filename: file) { (url, error) in
                    guard error == nil else {
                        return
                    }
                    UserDefaults.standard.setValue(url, forKey: "profilePicture")
                    print(url)
                }
            }
        }
    }
    
    func cameraPic(){
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func libraryPic(){
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
}
