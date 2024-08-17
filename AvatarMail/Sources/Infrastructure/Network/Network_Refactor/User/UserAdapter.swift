//
//  UserAdapter.swift
//  AvatarMail
//
//  Created by 최지석 on 8/17/24.
//

import Foundation
import RxSwift

public protocol UserAdapterProtocol {
    func sendFCMToken(fcmToken: String) -> Observable<ResponseData<EmptyData>>
}

public final class UserAdapter: UserAdapterProtocol {
    
    private let networkService: RefactoredNetworkServiceProtocol
    
    public init(networkService: RefactoredNetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    public func sendFCMToken(fcmToken: String) -> Observable<ResponseData<EmptyData>> {
        let path: UserRequestPath = .sendApnsToken
        
        let parameters: [String: Any] = [
            "fcm_token": fcmToken
        ]
        
        let requestData = RequestData(path: path,
                                      method: .post,
                                      parameters: parameters,
                                      queryItems: nil,
                                      additionalHeaders: nil,
                                      uploadFiles: nil)
        
        let request = UserRequest(requestData: requestData)
        
        return networkService.request(request)
    }
}

