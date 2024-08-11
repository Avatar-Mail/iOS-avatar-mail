//
//  TTSAdapter.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation
import RxSwift

public protocol TTSAdapterProtocol {
    func sendMail(mailID: String, avatarID: String, content: String) -> Observable<ResponseData<EmptyData>>
    func getMail(mailID: String) -> Observable<ResponseData<EmptyData>>
}

public final class TTSAdapter: TTSAdapterProtocol {
    
    private let networkService: RefactoredNetworkServiceProtocol
    
    public init(networkService: RefactoredNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
//    public func saveAvatar(avatarID: String, inputVoiceFiles: [String: Any]) {
//        
//        let path: TTSRequestPath = .saveAvatar
//        
//        let requestData = RequestData(path: path, 
//                                      method: .post,
//                                      queryItems: nil,
//                                      additionalHeaders: nil,
//                                      uploadFiles: inputVoiceFiles)
//        
//    }
    
    
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
    
    
    public func getMail(mailID: String) -> Observable<ResponseData<EmptyData>> {
        let path: TTSRequestPath = .sendMail
        
        let parameters: [String: Any] = [
            "mail_id": mailID
        ]
        
        let requestData = RequestData(path: path,
                                      method: .get,
                                      parameters: parameters,
                                      queryItems: nil,
                                      additionalHeaders: nil,
                                      uploadFiles: nil)
        
        let request = TTSRequest(requestData: requestData)
        
        return networkService.request(request)
    }
}
