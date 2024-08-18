//
//  TTSRequest.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation
import Alamofire
import FirebaseFirestore


public class TTSRequest: RequestProtocol {

    public let requestTimeOut: TimeInterval = 20
    
    public let resourceTimeOut: TimeInterval = 60
    
    public let requestData: RequestData
    
    
    public init(requestData: RequestData) {
        self.requestData = requestData
    }

    public func getRequestURLString() -> String {
        guard let baseURLString = Bundle.main.infoDictionary?["BaseURL"] as? String else {
            fatalError("BASE_SERVER_URL has not yet been set.")
        }
        
        let uploadedBaseURL = FirestoreDatabase.shared.getCachedBaseServerURL()
        
        // firestore에 서버에서 업로드한 BASE_SERVER_URL이 존재하면 해당 URL을 사용하고,
        // 없으면 Info.plist 파일에 존재하는 URL을 사용한다.
        if let uploadedBaseURL {
            let fullURLString = uploadedBaseURL + requestData.path.rawValue
            return fullURLString
        } else {
            let fullURLString = baseURLString + requestData.path.rawValue
            return fullURLString
        }
    }
    
    public func getHeader(additionalHeaders: [String : String]?) -> [String: String] {
        var header: [String: String] = [:]
        
        header.updateValue("application/json", forKey: "User-Agent")
        header.updateValue("TEMP_AUTH_TOKEN", forKey: "Authorization")  // FIXME: Auth 토큰 설정 필요
        header.updateValue(String.deviceID, forKey: "Device-Id")
        
        if let additionalHeaders = requestData.additionalHeaders {
            for param in additionalHeaders {
                header.updateValue(param.value, forKey: param.key)
            }
        }
        
        return header
    }
    
    public func getEncoding(method: RequestMethod) -> Alamofire.ParameterEncoding {
        switch method {
        case .get:
            return URLEncoding.default
        case .post, .delete, .put, .patch:
            return JSONEncoding.default
        }
    }
    
    public func getMultipartFormInfoList(uploadFiles: [[String : Any]]) -> [MultipartFormDataInfo] {
        var multipartFormInfoList: [MultipartFormDataInfo] = []
        
        for file in uploadFiles {
            guard let audioData = file["contents"] as? Data,
                  let fileName = file["fileName"] as? String else { return [] }
            
            let info = MultipartFormDataInfo(data: audioData,
                                             name: "input_voice_files",
                                             fileName:  fileName,
                                             mimeType: "audio/m4a")
            
            multipartFormInfoList.append(info)
        }
        
        return multipartFormInfoList
    }
}
