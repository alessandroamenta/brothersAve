//
//  DataService.swift
//  Le Mood
//
//  Created by MAC on 30/07/2021.
//


import Foundation
import FirebaseFirestore
import Firebase

class DataService{
    static let instance = DataService()
    
    let userReference = Firestore.firestore().collection("users")
    let patientReference = Firestore.firestore().collection("Patients")
    let randomchatReference = Firestore.firestore().collection("randomChats")
    
    
    func uploadProfilePicture(image:UIImage, handler :@escaping(_ success:Bool,_ picUrl:String)->()){
        var downloadLink = ""
        let imageData = image.jpegData(compressionQuality: 0.8)
        let storageRef = Storage.storage().reference().child("Profile Pics").child(("\(Auth.auth().currentUser?.uid ?? "").jpg"))
        _ = storageRef.putData(imageData!, metadata: nil) { (metaData, error) in
            print("upload task finished")
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil
                {
                    print(error!)
                    handler(false, "")
                }
                else
                {
                    downloadLink = (url?.absoluteString)!
                    
                    
                    handler(true,downloadLink)
                }
            })
        }
    }
    
    func uploadPIcture(image:UIImage,handler :@escaping(_ success:Bool,_ picUrl:String)->()){
        var downloadLink = ""
        let imageData = image.jpegData(compressionQuality: 0.7)
        let storageRef = Storage.storage().reference().child("iOS_App_Pics").child(("\(UUID().uuidString).jpg"))
        _ = storageRef.putData(imageData!, metadata: nil) { (metaData, error) in
            print("upload task finished")
            storageRef.downloadURL(completion: { (url, error) in
                if error != nil
                {
                    print(error!)
                    handler(false, "")
                }
                else
                {
                    downloadLink = (url?.absoluteString) ?? ""
                    handler(true,downloadLink)
                }
            })
        }
    }
    func uploadVideos(videoURL:URL,handler :@escaping(_ success:Bool,_ picUrl:String)-> Void){
        var downloadLink = ""
        let metadata = StorageMetadata()
        metadata.contentType = "video/quicktime"
        
        if let videoData = NSData(contentsOf: videoURL) as Data? {
            let storageRef = Storage.storage().reference().child("iOS_App_Video").child(("\(UUID().uuidString).mp4"))
            _ = storageRef.putData(videoData, metadata: metadata) { (metaData, err) in
                print("upload task finished")
                if let err = err {
                    print("Failed to upload movie:", err)
                    handler(false,downloadLink)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("Failed to get download url:", err)
                        handler(false,downloadLink)
                        return
                        
                    }
                    else
                    {
                        downloadLink = (url?.absoluteString) ?? ""
                        handler(true,downloadLink)
                    }
                })
            }
        }
    }
    
    func uploadGifs(selectedGif:URL,handler :@escaping(_ success:Bool,_ picUrl:String)-> Void){
        var downloadLink = ""
        let metadata = StorageMetadata()
        metadata.contentType = "image/gif"
        
        if let videoData = NSData(contentsOf: selectedGif) as Data? {
            let storageRef = Storage.storage().reference().child("iOS_App_Pics").child(("\(UUID().uuidString).gif"))
            _ = storageRef.putData(videoData, metadata: metadata) { (metaData, err) in
                print("upload task finished")
                if let err = err {
                    print("Failed to upload movie:", err)
                    handler(false,downloadLink)
                    return
                }
                
                storageRef.downloadURL(completion: { (url, err) in
                    if let err = err {
                        print("Failed to get download url:", err)
                        handler(false,downloadLink)
                        return
                        
                    }
                    else
                    {
                        downloadLink = (url?.absoluteString) ?? ""
                        handler(true,downloadLink)
                    }
                })
            }
        }
    }
    
}
