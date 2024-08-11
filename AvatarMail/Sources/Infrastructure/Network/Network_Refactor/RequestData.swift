//
//  RequestData.swift
//  AvatarMail
//
//  Created by 최지석 on 8/10/24.
//

import Foundation

public protocol RequestPathProtocol {
    var rawValue: String { get }
}


public enum RequestMethod: RawRepresentable {
    public typealias RawValue = String
    
    case get
    case post
    case put
    case delete
    case patch
    
    public var rawValue: String {
        switch self {
        case .get:
            "GET"
        case .post:
            "POST"
        case .put:
            "PUT"
        case .delete:
            "DELETE"
        case .patch:
            "PATCH"
        }
    }
    
    public init?(rawValue: String) {
        switch rawValue {
        case "GET":
            self = .get
        case "POST":
            self = .post
        case "PUT":
            self = .put
        case "DELETE":
            self = .delete
        case "PATCH":
            self = .patch
        default:
            return nil
        }
    }
}


public struct RequestData {
    public var path: RequestPathProtocol
    public var method: RequestMethod
    public var parameters: [String: Any]
    public var queryItems: [URLQueryItem]?
    public var additionalHeaders: [String: String]?
    public var uploadFiles: [[String: Any]]?

    public init(
        path: RequestPathProtocol,
        method: RequestMethod,
        parameters: [String: Any],
        queryItems: [URLQueryItem]?,
        additionalHeaders: [String: String]?,
        uploadFiles: [[String: Any]]?
    ) {
        self.path = path
        self.method = method
        self.parameters = parameters
        self.queryItems = queryItems
        self.additionalHeaders = additionalHeaders
        self.uploadFiles = uploadFiles
    }
}
