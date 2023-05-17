//
//  CacheManager.swift
//  TailSlate
//
//  Created by Muhammad Ahmad on 06/09/2022.
//

import Foundation
 
class CacheManager {
 
    //MARK: - Var...
    static let shared = CacheManager()
    private let fileManager = FileManager.default
    private lazy var mainDirectoryUrl: URL = {
        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
        return documentsUrl
    }()

    //MARK: - Functions...
     
    ///getFileWith...
    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
 
        let file = directoryFor(stringUrl: stringUrl)
        guard !fileManager.fileExists(atPath: file.path) else { completionHandler(Result.success(file)); return }
        DispatchQueue.global().async {
            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) { videoData.write(to: file, atomically: true); DispatchQueue.main.async { completionHandler(Result.success(file)) } }
            else { DispatchQueue.main.async { completionHandler(Result.failure("Can't download video"))} }
        }
    }

    ///directoryFor....
    private func directoryFor(stringUrl: String) -> URL {
        let fileURL = URL(string: stringUrl)!.lastPathComponent, file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
        return file
    }
}


//MARK: Enum - Result...
public enum Result<T> {
    case success(T)
    case failure(String)
}
