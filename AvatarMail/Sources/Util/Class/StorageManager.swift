//
//  StorageManager.swift
//  AvatarMail
//
//  Created by 최지석 on 8/10/24.
//

import Foundation
import UIKit

public protocol StorageManagerProtocol: AnyObject {
    func getFileURL(fileName: String, type: StorageFileType) -> URL
    func save(data: Data, fileName: String, type: StorageFileType) throws
    func delete(fileName: String, type: StorageFileType) throws
}

final class StorageManager: StorageManagerProtocol {
    
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
    
    
    public func delete(fileName: String, type: StorageFileType) throws {
        let fileURL = getFileURL(fileName: fileName, type: type)
        do {
            if fileManager.fileExists(atPath: fileURL.path) {
                try fileManager.removeItem(at: fileURL)
            } else {
                throw StorageManagerError.FileNotFound
            }
        } catch {
            throw StorageManagerError.FileDeleteFailure
        }
    }
    
    
    private func prepareDirectories() {
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


public enum StorageFileType: String, CaseIterable {
    case audio = "audio_files"
}


public enum StorageManagerError: Error {
    case FileSaveFailure
    case FileDeleteFailure
    case FileNotFound
    
    var errorDescription: String? {
        switch self {
        case .FileSaveFailure:
            return "파일을 저장하는 데 실패했습니다."
        case .FileDeleteFailure:
            return "파일을 삭제하는 데 실패했습니다."
        case .FileNotFound:
            return "존재하지 않는 파일입니다."
        }
    }
}
