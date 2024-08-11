//
//  RequestProtocol.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation
import Alamofire

public protocol RequestProtocol {
    var requestTimeOut: TimeInterval { get }
    var resourceTimeOut: TimeInterval { get }
    var requestData: RequestData { get }
    func getRequestURLString() -> String
    func getHeader(additionalHeaders: [String: String]?) -> [String: String]
    func getEncoding(method: RequestMethod) -> ParameterEncoding
    func getParamaters(_ parameters: [String: Any]) -> [String: Any]
    func getURLRequestConvertible() throws -> URLRequestConvertible
    func getMultipartFormInfoList(uploadFiles: [[String: Any]]) -> [MultipartFormDataInfo]
    
    typealias MultipartFormDataInfo = (data: Data, name: String, fileName: String?, mimeType: String?)
}


extension RequestProtocol {
    
    public func getURLRequestConvertible() throws -> URLRequestConvertible {
        
        let urlString = getRequestURLString()
        guard var urlComponents: URLComponents = URLComponents(string: urlString) else {
            fatalError("URLComponents 생성 중 에러가 발생했습니다.")
        }
        
        if let queryItems: [URLQueryItem] = requestData.queryItems, queryItems.isNotEmpty {
            urlComponents.queryItems = queryItems
        }
        
        guard let url: URL = urlComponents.url else {
            fatalError("잘못된 URL에 대한 접근이 발생했습니다.")
        }
        
        var request: URLRequest = URLRequest(url: url)
        request.httpMethod = requestData.method.rawValue
        request.allHTTPHeaderFields = getHeader(additionalHeaders: requestData.additionalHeaders)
        request.timeoutInterval = requestTimeOut
        let encoding: ParameterEncoding = getEncoding(method: requestData.method)
        let parameters = getParamaters(requestData.parameters)
        
        return try encoding.encode(request, with: parameters)
    }
    
    public func getParamaters(_ parameters: [String: Any]) -> [String: Any] {
        var params : [String: Any] = parameters
        // TODO: 디폴트로 들어가야 하는 파라미터 추가
        return params
    }
    
    public func getMultipartFormInfoList(uploadFiles: [[String: Any]]) -> [MultipartFormDataInfo] {
        return []
    }
}
