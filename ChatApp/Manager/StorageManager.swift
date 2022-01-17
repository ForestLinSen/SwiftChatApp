//
//  StorageManager.swift
//  ChatApp
//
//  Created by Sen Lin on 22/12/2021.
//

import Foundation
import FirebaseStorage

final class StorageManager{
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    func uploadPictureToStorage(with data: Data, uploadType: StorageUploadPath, fileName: String, completion: @escaping UploadPictureCompletion){
        
        let path: String
        
        switch uploadType {
        case .profileImages:
            path = "\(uploadType.rawValue)/\(fileName)"
        case .chatImages:
            path = "\(uploadType.rawValue)/\(K.currentUserSafeEmail)/\(fileName)"
        }
        
        storage.child(path).putData(data, metadata: nil) { metaData, error in
            guard error == nil else{
                print("Debug: failed to upload to firebase: \(error?.localizedDescription)")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            let reference = self.storage.child(path).downloadURL {url, error in
                guard let url = url else {
                    print("Debug: cannot get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                //print("Debug: download url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    func getProfileImage(path: String, completion: @escaping ((Result<URL, Error>) -> Void)){
        storage.child(path).downloadURL { url, error in
            guard error == nil, let profileUrl = url else {
                print("Debug: Failed to download user image")
                completion(.failure(StorageErrors.failedToGetDownloadURL))
                return
            }
            
            completion(.success(profileUrl))

        }
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
    
    public enum StorageUploadPath: String{
        case profileImages = "profileImages"
        case chatImages = "chatImages"
    }
}
