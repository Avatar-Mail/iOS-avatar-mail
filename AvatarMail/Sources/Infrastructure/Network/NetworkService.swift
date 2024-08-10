//
//  NetworkService.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import Foundation
import RxSwift
import RxCocoa

protocol NetworkServiceProtocol {
    func getNarrationAudio(avatarID: String,
                           mailContents: String,
                           sampleVoiceURL: URL,
                           serverURL: URL) -> Observable<URL>
    
    func sendAvatarAudioFiles(avatarID: String,
                              audioURLs: [URL],
                              serverURL: URL) -> Observable<Void>
}


final class NetworkService: NetworkServiceProtocol {
    
    public static let shared = NetworkService()
    
    private init() {}
    
    
    func getNarrationAudio(avatarID: String,
                           mailContents: String,
                           sampleVoiceURL: URL,
                           serverURL: URL) -> Observable<URL> {
        
        print("[SEND MAIL START]")
        
        return Observable.create { [weak self] observer -> Disposable in
            
            guard let self else {
                observer.onError(NetworkServiceError.networkServiceCreationFailure)
                return Disposables.create()
            }
            
            var request = URLRequest(url: serverURL)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let parameters = ["text": mailContents, "avatar_id": avatarID]
            var paths = [sampleVoiceURL]
            
            request.httpBody = createBody(with: parameters, filePathKey: "input_voice_file", paths: paths, boundary: boundary)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data else {
                    observer.onError(NetworkServiceError.networkServiceResponseError)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    observer.onError(NetworkServiceError.networkServiceResponseError)
                    return
                }
                
                // Extract file name from response headers
                
                if let contentDisposition = (response as? HTTPURLResponse)?.allHeaderFields["Content-Disposition"] as? String,
                   let fileName = self.extractFileName(from: contentDisposition) {
                    let documentPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    let fileURL = documentPath.appendingPathComponent(fileName)
                    
                    do {
                        try data.write(to: fileURL)
                        print("\(fileURL) saved.")
                        // 서버로부터의 응답이 성공적으로 완료되었음을 옵저버에게 알림
                        observer.onNext(fileURL)
                        observer.onCompleted()
                    } catch {
                        observer.onError(error)
                    }
                } else {
                    observer.onError(NetworkServiceError.networkServiceFileNameNotFoundError)
                    return
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
    
    
    func sendAvatarAudioFiles(avatarID: String,
                              audioURLs: [URL],
                              serverURL: URL) -> RxSwift.Observable<Void> {
        print("[SEND AUDIO FILES START]")
        
        return Observable.create { [weak self] observer -> Disposable in
            
            guard let self = self else {
                observer.onError(NetworkServiceError.networkServiceCreationFailure)
                return Disposables.create()
            }
            
            var request = URLRequest(url: serverURL)
            request.httpMethod = "POST"
            
            let boundary = UUID().uuidString
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            
            let parameters = ["avatar_id": avatarID]
            
            request.httpBody = createBody(with: parameters, filePathKey: "input_voice_files", paths: audioURLs, boundary: boundary)
            
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    observer.onError(error)
                    return
                }
                
                guard let data = data else {
                    observer.onError(NetworkServiceError.networkServiceResponseError)
                    return
                }
                
                if let httpStatus = response as? HTTPURLResponse, httpStatus.statusCode != 200 {
                    observer.onError(NetworkServiceError.networkServiceResponseError)
                } else {
                    observer.onNext(())
                    observer.onCompleted()
                }
            }
            task.resume()
            
            return Disposables.create {
                task.cancel()
            }
        }
    }
}


extension NetworkService {
    
    private func createBody(with parameters: [String: String]?, filePathKey: String, paths: [URL], boundary: String) -> Data {
        
        var body = Data()

        if let parameters = parameters {
            for (key, value) in parameters {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
                body.appendString("\(value)\r\n")
            }
        }

        for path in paths {
            let filename = path.lastPathComponent
            let data = try! Data(contentsOf: path)
            let mimetype = "audio/m4a"

            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(filename)\"\r\n")
            body.appendString("Content-Type: \(mimetype)\r\n\r\n")
            body.append(data)
            body.appendString("\r\n")
        }

        body.appendString("--\(boundary)--\r\n")
        
        return body
    }
    
    private func extractFileName(from contentDisposition: String) -> String? {
        let components = contentDisposition.components(separatedBy: ";")
        for component in components {
            let trimmedComponent = component.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmedComponent.starts(with: "filename=") {
                let fileName = trimmedComponent.replacingOccurrences(of: "filename=", with: "")
                return fileName.trimmingCharacters(in: CharacterSet(charactersIn: "\""))
            }
        }
        return nil
    }
}

enum NetworkServiceError: Error {
    case networkServiceCreationFailure
    case networkServiceResponseError
    case networkServiceFileNameNotFoundError
}
