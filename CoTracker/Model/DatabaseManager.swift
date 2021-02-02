//
//  DatabaseManager.swift
//  CoTracker
//
//  Created by Jongmin Lee on 12/30/20.
//

import Foundation
import FirebaseDatabase

class DatabaseManager {
    static let shared = DatabaseManager()
    private let database = Database.database().reference()

    var temp = [[String: Any]]()
    
    public func newUserPhoto(with user: User, completion: @escaping (Bool) -> Void ){
        database.child(user.dbEmail).setValue(["email": user.email,
                                             "userName":user.getUserName]) { (error, ref) in
            guard error == nil else {
                print("fail to wrie to database")
                completion(false)
                return
            }
            completion(true)
        }
    }
        
    static func getDBEmail(email: String) -> String {
        var splitEmail = email.replacingOccurrences(of: "@", with: "_")
        splitEmail = splitEmail.replacingOccurrences(of: ".", with: "_")
        splitEmail = splitEmail + "_profile.png"
        return splitEmail
    }
    
    
}

//MARK:- DatabaseManager Message function extension
extension DatabaseManager {
    
    /// Get all messages from Firebase realtime database
    /// - Parameter completion: [Messages] or []
    public func getAllMessages(completion: @escaping ([Messages]) -> Void){
        database.child("Messages").observe( .value) { (snapshot) in
            MessageDataModel.allMessages = []
            MessageDataModel.fetchedMessages = []
            guard let value = snapshot.value as? [[String: Any]] else {
                completion([])
                return
            }
            for i in value {
                self.appendData(aMessage: i)
            }
            completion(MessageDataModel.allMessages)
        }
    }
    
    
    /// Send Message. Saves the messages in child "Message" in realtime database
    /// - Parameters:
    ///   - message: [String : Any]
    ///   - completion: Bool
    public func sendMessage(message: [String: Any], completion: @escaping (Bool) -> Void){
        self.database.child("Messages").observeSingleEvent(of: .value) { (snapshot) in
            print(snapshot.exists())
            if !snapshot.exists(){
                MessageDataModel.fetchedMessages.append(message)
                self.database.child("Messages").setValue(MessageDataModel.fetchedMessages){ (error, ref) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
            else {
                guard var Messages = snapshot.value as? [[String: Any]] else {
                    completion(false)
                    return
                }
                Messages.append(message)
                self.database.child("Messages").setValue(Messages){ (error, ref) in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
            }
        }
    }
    
    public func syncMessage(){
        database.child("Messages").keepSynced(true)
    }
    
    /// Transform the fetched message data to Message type in MessageDataModel
    /// - Parameter aMessage: [String : Any]
    func appendData(aMessage: [String: Any]){
        guard let sender = aMessage["sender"] as? String,
              let senderEmail = aMessage["senderEmail"] as? String,
              let sendDate = aMessage["sendDate"] as? String,
              let messageId = aMessage["messageId"] as? String,
              let message = aMessage["message"] as? String,
              let messageType = aMessage["messageType"] as? String
        else {
            return
        }
        let dictMessage = ["sender": sender,
                            "senderEmail": senderEmail,
                            "sendDate": sendDate,
                            "messageId": messageId,
                            "message": message,
                            "messageType": messageType]
        
        let newSender = Sender(photoURL: "",
                            senderId: senderEmail,
                            displayName: sender)
        
        let newMessage = Messages(sender: newSender,
                               messageId: messageId,
                               sentDate: Date(),
                               kind: .text(message))
        MessageDataModel.fetchedMessages.append(dictMessage)
        MessageDataModel.allMessages.append(newMessage)
    }
}

struct User {
    let email: String
    
    var dbEmail: String {
        var splitEmail = email.replacingOccurrences(of: "@", with: "_")
        splitEmail = splitEmail.replacingOccurrences(of: ".", with: "_")
        return splitEmail
    }
    
    var getUserName: String {
        let splitEmail = email.components(separatedBy: "@")
        return splitEmail[0]
    }
    
    var profiePicture: String {
        return "\(dbEmail)_profile.png"
    }
}
