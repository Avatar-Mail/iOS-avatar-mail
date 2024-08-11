//
//  TTSRequest.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation
import Alamofire

public class TTSRequest: RequestProtocol {

    public let requestTimeOut: TimeInterval = 20
    
    public let resourceTimeOut: TimeInterval = 60
    
    public let requestData: RequestData
    
    
    public init(requestData: RequestData) {
        self.requestData = requestData
    }

    public func getRequestURLString() -> String {
        let baseURLString = "BASE_URL"
        let fullURLString = baseURLString + requestData.path.rawValue
        return fullURLString
    }
    
    public func getHeader(additionalHeaders: [String : String]?) -> [String: String] {
        var header: [String: String] = [:]
        
        header.updateValue("application/json", forKey: "User-Agent")
        header.updateValue("TEMP_AUTH_TOKEN", forKey: "Authorization")  // FIXME: Auth 토큰 설정 필요
        
        let apnsToken = "TEMP_APNS_TOKEN"  // FIXME: APNs 토큰 설정 필요
        header.updateValue(apnsToken, forKey: "Device-Token")
        
        if let additionalHeaders = requestData.additionalHeaders {
            for param in additionalHeaders {
                header.updateValue(param.value, forKey: param.key)
            }
        }
        
        return header
    }
    
    public func getEncoding(method: RequestMethod) -> Alamofire.ParameterEncoding {
        switch method {
        default:
            return JSONEncoding.default
        }
    }
}
