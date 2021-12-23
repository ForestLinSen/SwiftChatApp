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
    
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion){
        storage.child("images/\(fileName)").putData(data, metadata: nil) { metaData, error in
            guard error == nil else{
                print("Debug: failed to upload to firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            let reference = self.storage.child("images/\(fileName)").downloadURL {url, error in
                guard let url = url else {
                    print("Debug: cannot get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadURL))
                    return
                }
                
                let urlString = url.absoluteString
                print("Debug: download url: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public enum StorageErrors: Error{
        case failedToUpload
        case failedToGetDownloadURL
    }
}