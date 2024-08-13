//
//  TTSAdapter.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation
import RxSwift

public protocol TTSAdapterProtocol {
    func saveAvatar(avatarID: String, audioURLs: [URL]) -> Observable<ResponseData<EmptyData>>
    func sendMail(mailID: String, avatarID: String, content: String) -> Observable<ResponseData<EmptyData>>
    func getNarrationAudioFile(mailID: String) -> Observable<ResponseData<Data>>
}

public final class TTSAdapter: TTSAdapterProtocol {
    
    private let networkService: RefactoredNetworkServiceProtocol
    
    public init(networkService: RefactoredNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func saveAvatar(avatarID: String, audioURLs: [URL]) -> Observable<ResponseData<EmptyData>> {
        
        let path: TTSRequestPath = .saveAvatar
        
        let uploadFiles: [[String: Any]] = audioURLs.map { url in
            let fileName = url.lastPathComponent
            let data = try! Data(contentsOf: url)
            
            return [
                "contents": data,
                "fileName": fileName
            ]
        }
        
        let requestData = RequestData(path: path, 
                                      method: .post,
                                      parameters: ["avatar_id": avatarID],
                                      queryItems: nil,
                                      additionalHeaders: nil,
                                      uploadFiles: uploadFiles)
        
        let request = TTSRequest(requestData: requestData)
        
        return networkService.multipartUpload(request)
    }
    
    
    public func sendMail(mailID: String, avatarID: String, content: String) -> Observable<ResponseData<EmptyData>> {
        let path: TTSRequestPath = .sendMail
        
        let parameters: [String: Any] = [
            "mail_id": mailID,
            "avatar_id": avatarID,
            "content": content
        ]
        
        let requestData = RequestData(path: path,
                                      method: .post,
                                      parameters: parameters,
                                      queryItems: nil,
                                      additionalHeaders: nil,
                                      uploadFiles: nil)
        
        let request = TTSRequest(requestData: requestData)
        
        return networkService.request(request)
    }
    
    
    public func getNarrationAudioFile(mailID: String) -> Observable<ResponseData<Data>> {
        let path: TTSRequestPath = .getMail(mailID: mailID)
        
        let requestData = RequestData(path: path,
                                      method: .get,
                                      parameters: [:],
                                      queryItems: nil,
                                      additionalHeaders: nil,
                                      uploadFiles: nil)
        
        let request = TTSRequest(requestData: requestData)
        
        return networkService.multipartDownload(request)
    }
}
