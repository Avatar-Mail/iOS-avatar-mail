//
//  StorageManager.swift
//  AvatarMail
//
//  Created by 최지석 on 8/10/24.
//

import Foundation
import UIKit

public protocol StorageManagerDelegate: AnyObject {
    func didFinishPlaying(with fileURL: String?)
}

final class StorageManager {
    
    let fileManager = FileManager.default
    
    init() {
        prepareDirectories()
    }
    
    
    public func getFileURL(fileName: String, type: StorageFileType) -> URL {
        let applicationDirectoryURL = fileManager.urls(for: .applicationSupportDirectory,
                                                       in: .userDomainMask)[0]
        let subDirectoryURL = applicationDirectoryURL.appendingPathComponent(type.rawValue,
                                                                             isDirectory: true)
        let fileURL = subDirectoryURL.appendingPathComponent(fileName, isDirectory:  false)
        
        return fileURL
    }
    
    
    public func save(data: Data, fileName: String, type: StorageFileType) throws {
        let fileURL = getFileURL(fileName: fileName, type: type)
        do {
            try data.write(to: fileURL)
        } catch {
            throw StorageManagerError.FileSaveFailure
        }
    }
    
    
    func prepareDirectories() {
        let applicationDirectoryURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
        
        for type in StorageFileType.allCases {
            let subDirectoryURL = applicationDirectoryURL.appendingPathComponent(type.rawValue, isDirectory: true)
            
            // 디렉터리 존재 여부 확인
            if !fileManager.fileExists(atPath: subDirectoryURL.path) {
                do {
                    try fileManager.createDirectory(at: subDirectoryURL, withIntermediateDirectories: true, attributes: nil)
                } catch {
                    fatalError("FileManager - '\(type.rawValue)' 디렉터리를 생성하는 데 실패했습니다.")
                }
            }
        }
    }
}


enum StorageFileType: String, CaseIterable {
    case audio = "audio_files"
}


enum StorageManagerError: Error {
    case FileSaveFailure
    
    var errorDescription: String? {
        switch self {
        case .FileSaveFailure:
            return "파일을 저장하는 데 실패했습니다."
        }
    }
}
