//
//  ChatViewController.swift
//  CoTracker
//
//  Created by Jongmin Lee on 1/3/21.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import FirebaseAuth

struct Messages: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

struct Sender: SenderType {
    var photoURL: String
    var senderId: String
    var displayName: String
}

struct Media: MediaItem{
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
}

extension MessageKind {
    var description: String {
        switch self {
        case .text(_):
            return "text"
        case .attributedText(_):
            return "attributedText"
        case .photo(_):
            return "photo"
        case .video(_):
            return "video"
        case .location(_):
            return "location"
        case .emoji(_):
            return "emoji"
        case .audio(_):
            return "audio"
        case .contact(_):
            return "contact"
        case .linkPreview(_):
            return "linkPreview"
        case .custom(_):
            return "custom"
        }
    }
}

class ChatViewController: MessagesViewController {
    
    let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = .current
        return formatter
    }()
    
    var sender: Sender? {
        guard let email = UserDefaults.standard.string(forKey: "email"),
              let userName = UserDefaults.standard.string(forKey: "userId")
        else {
            return nil
        }
        return Sender(photoURL: "", senderId: email, displayName: userName)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        backButtonSetting()
        messageViewSetting()
        //        cameraButtonSetting()
    }
    
    func backButtonSetting(){
        let backButton = UIBarButtonItem()
        backButton.title = "Back"
        self.navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
    }
    
    func messageViewSetting(){
        DatabaseManager.shared.getAllMessages { (Messages) in
            DispatchQueue.main.async {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            }
            
        }
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    //    func cameraButtonSetting(){
    //        let button = InputBarButtonItem()
    //        button.setImage(UIImage(systemName: "camera.fill"), for: .normal)
    //        button.setSize(CGSize(width: 35, height: 35), animated: false)
    //        button.onTouchUpInside { (item) in
    //            self.selectPhotoSheet()
    //        }
    //        messageInputBar.setLeftStackViewWidthConstant(to: 35, animated: false)
    //        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    //    }
    //
    //    func selectPhotoSheet(){
    //        let sheet = UIAlertController(title: "Send A Photo", message: "Select an option below", preferredStyle: .actionSheet)
    //        sheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (action) in
    //            let picker = UIImagePickerController()
    //            picker.sourceType = .camera
    //            picker.delegate = self
    //            picker.allowsEditing = true
    //            self.present(picker, animated: true)
    //        }))
    //
    //        sheet.addAction(UIAlertAction(title: "Library", style: .default, handler: { (action) in
    //            let picker = UIImagePickerController()
    //            picker.sourceType = .photoLibrary
    //            picker.delegate = self
    //            picker.allowsEditing = true
    //            self.present(picker, animated: true)
    //        }))
    //
    //        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
    //
    //        present(sheet, animated: true)
    //    }
    
}

// MARK:- MessageKit extension

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    func currentSender() -> SenderType {
        if let sender = sender {
            return sender
        }
        fatalError("Sender is nil")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return MessageDataModel.allMessages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return MessageDataModel.allMessages.count
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(string: message.sender.displayName)
    }
    
    // sender name
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    // sender's profile picture
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        avatarView.image = UIImage(systemName: "person.circle")
        avatarView.backgroundColor = .white
        let userEmail = message.messageId.split(separator: "_")
        let dbImg = DatabaseManager.getDBEmail(email: String(userEmail[0]))
        
        var img = UIImage(systemName: "person.circle")
        
        StorageManager.shared.getImageURL(path: dbImg) { (url, error) in
            guard let url = url, error == nil else {
                return
            }
            URLSession.shared.dataTask(with: url) { (data, response, error) in
                guard let data = data, error == nil else {
                    return
                }
                //let img = UIImage(data: data)
                img = UIImage(data: data)
                DispatchQueue.main.async {
                    //                    avatarView.set(avatar: Avatar(image: img))
                    //                    messagesCollectionView.reloadData()
                    //                    avatarView.image = img
                    //                    if MessageDataModel.allMessages[indexPath[0]].sender.senderId == message.sender.senderId {
                    //                        avatarView.set(avatar: Avatar(image: img))
                    //                    }
                }
            }.resume()
        }
        //        if MessageDataModel.allMessages[indexPath[0]].sender.senderId == message.sender.senderId {
        //            avatarView.set(avatar: Avatar(image: img))
        //        }
        avatarView.set(avatar: Avatar(image: img))
        
    }
    
}

// MARK:- MessageKit InputBarAccessoryViewDelegate

extension ChatViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let sender = self.sender, let messageId = getMessageId() else {
            return
        }
        let newMessage: [String: Any] = ["sender": sender.displayName,
                                         "senderEmail": sender.senderId,
                                         "messageId":messageId,
                                         "sendDate":dateFormatter.string(from: Date()),
                                         "message": text,
                                         "messageType":"text"]
        
        DatabaseManager.shared.sendMessage(message: newMessage) { (success) in
            if success {
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToLastItem(animated: true)
            } else {
                print("message send failed")
            }
        }
        self.messageInputBar.inputTextView.text = ""
        self.messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func getMessageId() -> String? {
        // data, senderEmail
        let date = getDateString(date: Date())
        guard let userEmail = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        let newId = "\(userEmail)_\(date)"
        print(newId)
        return newId
    }
    
    func getDateString(date: Date) -> String {
        return self.dateFormatter.string(from: date)
    }
    
}

//MARK:- Photo message

//extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
//    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
//        picker.dismiss(animated: true, completion: nil)
//    }
//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        guard let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage,
//              let data = image.pngData(),
//              let email = UserDefaults.standard.string(forKey: "email"),
//              let sender = self.sender,
//              let messageId = getMessageId() else {
//            return
//        }
//
//        let filename = photoMessageID(email: email)
//
//        StorageManager.shared.uploadMessagePhoto(with: data, filename: filename) { (url, error) in
//            guard error == nil else {
//                print("Photo message failure")
//                return
//            }
//
//            print("Photo message url: \(url)")
//
//            let newMessage: [String: Any] = ["sender": sender.displayName,
//                                             "senderEmail": sender.senderId,
//                                            "messageId": messageId,
//                                            "sendDate": self.dateFormatter.string(from: Date()),
//                                            "message": url,
//                                            "messageType":"photo"]
//
//
//            DatabaseManager.shared.sendMessage(message: newMessage) { (success) in
//                if success {
//                    print("send photo message success")
//                } else {
//                    print("send photo message fail")
//                }
//            }
//        }
//    }
//
//    func photoMessageID(email: String) -> String {
//        var splitEmail = email.replacingOccurrences(of: "@", with: "_")
//        splitEmail = splitEmail.replacingOccurrences(of: ".", with: "_")
//        splitEmail = splitEmail + dateFormatter.string(from: Date())
//        splitEmail = splitEmail + ".png"
//        return splitEmail
//    }
//}
