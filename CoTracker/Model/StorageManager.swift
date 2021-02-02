//
//  StorageManager.swift
//  CoTracker
//
//  Created by Jongmin Lee on 1/3/21.
//

import Foundation
import FirebaseStorage

class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    /// Upload account profile image to Firebase storage
    /// - Parameters:
    ///   - data: Image file
    ///   - filename: filename png extension
    ///   - completion: (url, Error)
    public func uploadPicture(with data: Data, filename: String, completion: @escaping (String, Error?) -> Void){
        storage.child("images/\(filename)").putData(data, metadata: nil) { (data, error) in
            guard error == nil else {
                print("failed to upload data to firebase")
                completion("", error)
                return
            }
            
            self.storage.child("images/\(filename)").downloadURL { (url, error) in
                guard let url = url else {
                    print("failed to download firebase data url")
                    completion("", error)
                    return
                }
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(urlString, nil)
            }
        }
    }
    
    /// Get image file url from Firebase storage
    /// - Parameters:
    ///   - path: image file name
    ///   - completion: (url, Error)
    public func getImageURL(path: String, completion: @escaping (URL?, Error?) -> Void){
        let finalPath = "images/" + path
        let ref = storage.child(finalPath)
        ref.downloadURL { (url, error) in
            guard let url = url, error == nil else {
                completion(nil, error)
                return
            }
            completion(url, nil)
        }
    }
    
//    public func uploadMessagePhoto(with data: Data, filename: String, completion: @escaping (String, Error?) -> Void){
//        storage.child("message_images/\(filename)").putData(data, metadata: nil) { (data, error) in
//            guard error == nil else {
//                print("failed to upload data to firebase")
//                completion("", error)
//                return
//            }
//            
//            self.storage.child("message_images/\(filename)").downloadURL { (url, error) in
//                guard let url = url else {
//                    print("failed to download firebase data url")
//                    completion("", error)
//                    return
//                }
//                let urlString = url.absoluteString
//                print("download url returned: \(urlString)")
//                completion(urlString, nil)
//            }
//        }
//    }
}
