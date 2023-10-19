//
//  StorageManager.swift
//  MessengerChatApp
//
//  Created by Pulkit Dhirana on 17/10/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
    
    /*
    /images/user-email-com_profile_picture.png
    */
    
    // Uploads picture to firebase and returns completion with url string to download
    
    public typealias uploadPictureCompletion = (Result<String, Error>) -> Void
    
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping uploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil) { [weak self] metadata, error in
            
            guard let strongSelf = self else {
                return
            }
            
            guard error == nil else {
                print("Failed to upload data to firebase for pictures ")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            strongSelf.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned: \(urlString)")
                completion(.success(urlString))
            }
        }
    }
    
    public func downloadURL(for path: String, completion: @escaping (Result<URL,Error>) -> Void){
        let reference = storage.child(path)
        reference.downloadURL { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            
            completion(.success(url))
        }
    }
    
    public enum StorageErrors: Error {
        case failedToUpload
        case failedToGetDownloadUrl
    }
}
