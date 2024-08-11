//
//  NetworkServiceRefactor.swift
//  AvatarMail
//
//  Created by 최지석 on 8/11/24.
//

import Foundation
import RxSwift
import Alamofire

public struct ResponseData<T: Codable>: Codable {
    public var isSuccess: Bool?
    public var message: String?
    public var code: Int?
    public var data: T?
    public var header: [String: String]?
    
    public init(isSuccess: Bool?, message: String?, code: Int?, data: T?, header: [String: String]?) {
        self.isSuccess = isSuccess
        self.message = message
        self.code = code
        self.data = data
        self.header = header
    }
}

public enum ResponseResult<T: Codable> {
    // isSuccess: Bool?
    // message: String?
    // code: Int?
    // data: T?
    // header: [String: String]?
    case success(Bool?, String?, Int?, T?, [String: String]?)
    // message: String?
    // code: Int?
    case error(String?, Int?)
}


public protocol RefactoredNetworkServiceProtocol {
    func request<T: Codable>(_ request: RequestProtocol) -> Observable<ResponseData<T>>
    
}

public final class RefactoredNetworkService: RefactoredNetworkServiceProtocol {
    
    private let defaultRequestTimeout: TimeInterval = 30
    private let fileRequestTimeout: TimeInterval = 60
    
    let sharedSession: Session = {
        let sessionConfiguration = URLSessionConfiguration.af.default
        sessionConfiguration.httpMaximumConnectionsPerHost = 10
        var configuration = Session(configuration: sessionConfiguration)
        return configuration
    }()
    
    public init() { }
    
    
    public func request<T: Codable>(_ request: RequestProtocol) -> Observable<ResponseData<T>> {
        return getDataTask(request)
    }
    
    
    private func getDataTask<T: Codable> (_ request: RequestProtocol) -> Observable<ResponseData<T>> {
        return Observable<ResponseData<T>>.create { [weak self] (observer) -> Disposable in
            guard let self else { return Disposables.create() }
            
            let requestConvertible: URLRequestConvertible = try! request.getURLRequestConvertible()
            
            sharedSession.sessionConfiguration.timeoutIntervalForRequest = request.requestTimeOut
            sharedSession.sessionConfiguration.timeoutIntervalForResource = request.resourceTimeOut
            
            let dataTask = sharedSession.request(requestConvertible)
                .validate()
                .response { [weak self] response in
                    guard let self else { return }
                    let requestQueue = DispatchQueue(label: "alamofire.queue")
                    requestQueue.async { [weak self] in
                        guard let self else { return }
                        
                        networkLog(response)
                        
                        let responseResult: ResponseResult<T> = getResponseResult(response: response)
                        
                        switch responseResult {
                        case .success(let isSuccess, let message, let code, let data, let header):
                            
                            let responseData = ResponseData(isSuccess: isSuccess,
                                                            message: message,
                                                            code: code,
                                                            data: data,
                                                            header: header)
                            
                            observer.onNext(responseData)
                            observer.onCompleted()
                        case .error(let message, let code):
                            observer.onError(RefactoredNetworkServiceError(message: message, code: code))
                        }
                    }
                }.resume()
            
            return Disposables.create {
                dataTask.cancel()
            }
        }.observe(on: MainScheduler.instance)
    }
    
    
    private func networkLog(_ response: AFDataResponse<Data?>) {
        guard let request = response.request,
              let method = request.method,
              let data = response.data,
              let httpURLResponse = response.response else { return }
        
        var message: String = "[REQUEST] <\(method)>: \(request)"
        if let header = request.allHTTPHeaderFields {
            message += "\n[HEADER]: \(header)"
        }
        message += "\n[RESPONSE]: \(httpURLResponse)"
        message += "\n[DATA]: \(data)"
        
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
            if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .withoutEscapingSlashes]),
               let jsonString = String(data: jsonData, encoding: .utf8) {
                message = "\n[RESULT]: \(jsonString)"
                print(message)
            } else {
                message = "\n[ERROR]: JSON 파싱 중 에러가 발생했습니다."
                print(message)
            }
        } catch {
            message += "[ERROR]: JSON 변환 중 에러가 발생했습니다."
            print(message)
        }
    }
    
    
    private func getResponseResult<T: Codable>(response: AFDataResponse<Data?>) -> ResponseResult<T> {
        // 서버의 상태 코드
        var code: Int? = response.response?.statusCode
        
        switch response.result {
        case .success(let responseData):
            // 응답 헤더
            let responseHeader: [String: String]? = response.response?.headers.dictionary
            
            // 데이터가 nil인지 확인
            guard let data = responseData else {
                return ResponseResult.error("서버의 Response Data가 null입니다.", code)
            }
            
            do {
                // 데이터를 ServerResponse<T>로 디코딩
                let responseBody = try JSONDecoder().decode(ServerResponseBody<T>.self, from: data)
                
                // 응답 코드가 존재하는지 확인
                if let responseCode = responseBody.code.value {
                    // 응답 코드가 200-299 범위에 있는지 확인
                    switch responseCode {
                    case 200..<300:
                        return ResponseResult.success(responseBody.isSuccess,
                                                      responseBody.message,
                                                      responseBody.code,
                                                      responseBody.data,
                                                      responseHeader)
                    default:
                        return ResponseResult.error(responseBody.message,
                                                    responseBody.code)
                    }
                } else {
                    return ResponseResult.error("Response Code가 null입니다.", code)
                }
            } catch {
                // 디코딩 중 에러가 발생했을 때의 처리
                return ResponseResult.error("JSON 디코딩 중 오류가 발생했습니다. -error: \(error.localizedDescription)", code)
            }
            
        case .failure(let error):
            // 요청이 실패했을 때의 처리
            return ResponseResult.error("서버 요청을 실패했습니다. -error: \(error.localizedDescription)", code)
        }
    }
}
    
    
public struct RefactoredNetworkServiceError: Error, Codable, Equatable {
    var message: String?
    var code: Int?
    
    public init(message: String? = nil, code: Int? = nil) {
        self.message = message
        self.code = code
    }
    
    public init(error: Error) {
        let networkServiceError = error as? RefactoredNetworkServiceError
        self.message = networkServiceError?.message
        self.code = networkServiceError?.code
    }
}


public struct ServerResponseBody<T: Codable>: Codable {
    public var isSuccess: Bool?
    public var message: String?
    public var code: Int?
    public var data: T?
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        self.isSuccess = try? container.decodeIfPresent(Bool.self, forKey: .isSuccess)
        self.message = try? container.decodeIfPresent(String.self, forKey: .message)
        self.code = try? container.decodeIfPresent(Int.self, forKey: .code)
        self.data = try? container.decodeIfPresent(T.self, forKey: .data)
    }
}
