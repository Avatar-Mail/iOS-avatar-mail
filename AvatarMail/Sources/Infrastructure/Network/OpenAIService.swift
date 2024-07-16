//
//  OpenAIService.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import OpenAI
import RxSwift


protocol OpenAIServiceProtocol {
    func sendMail(senderName: String, content: String, recipientName: String, avatarInfo: AvatarInfo?) -> Observable<String>
    func checkRepliedMailExists() -> Observable<Bool>
    func getRepliedMail() -> Observable<Mail?>
}

final class OpenAIService: OpenAIServiceProtocol {
    
    private var openAI: OpenAI?
    
    private var repliedMail: Mail?
    
    init() {
        guard let apiKey = Bundle.main.infoDictionary?["APIKey"] as? String else {
            fatalError("APIKey has not yet been set.")
        }
        openAI = OpenAI(apiToken: apiKey)
    }
    
    
    public func sendMail(senderName: String,
                         content: String,
                         recipientName: String,
                         avatarInfo: AvatarInfo?
    ) -> Observable<String> {
        
        print("OpenAIService : \(String(describing: avatarInfo))")
        
        // 아바타 나이대, 성격, 말투 세팅
        var avatarInfoSettings: [ChatQuery.ChatCompletionMessageParam] = []
        
        if let avatarInfo {
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너의 성격은 \(String(describing: avatarInfo.characteristic))")!)
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너의 말투는 대괄호 속의 말투와 같다. [\(String(describing: avatarInfo.parlance))]")!)
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너의 나이대는 \(String(describing: avatarInfo.ageGroup))이다.")!)
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너는 사용자의 \(String(describing: avatarInfo.relationship.avatar))이다.")!)
            avatarInfoSettings.append(.init(role: .system,
                                            content: "사용자는 너의 \(String(describing: avatarInfo.relationship.user))이다.")!)
        }
        
        let commonSettings: [ChatQuery.ChatCompletionMessageParam] = [
            // 시스템 설정
            .init(role: .system,
                  content: "너는 너의 성격, 말투, 나이대, 사용자와의 관계를 바탕으로, 사용자가 작성한 편지에 대한 답장 편지를 작성해야 한다.")!,
            .init(role: .system,
                  content: "답장 편지의 내용은 사용자의 입력을 참고하여, 사용자가 입력한 편지에 대한 답장을 작성해야 한다.")!,
            .init(role: .system,
                  content: "사용자가 보낸 편지의 내용을 그대로 복사하는 것이 아니라, 사용자의 편지의 내용에 대한 답장을 작성해야 한다.")!,
            .init(role: .system,
                  content: "답장 편지를 보내는 대상의 이름은 '\(senderName)'이다.")!,
            .init(role: .system,
                  content: "답장 편지에는 너의 이름인 '\(recipientName)'이 포함되면 안 된다.")!,
            .init(role: .system,
                  content: "답장 편지에는 너의 이름이 아니라, 보내는 대상의 이름이 포함되어야 한다.")!,
            .init(role: .system,
                  content: "답장 편지에는 대괄호 속의 너의 말투가 반영되어야 한다.")!,
            .init(role: .system,
                  content: "모든 문장에 줄바꿈이 이루어져야 한다.")!,
            .init(role: .system,
                  content: "'.' 뒤에는 줄바꿈이 이루어져야 한다.")!,
            .init(role: .system,
                  content: "편지의 내용은 200자 이상이어야 한다.")!,
            .init(role: .system,
                  content: "편지의 내용은 최대한 자연스러워야 한다.")!,
            // 실제 사용자 입력
            .init(role: .user,
                  content: "\(content)")!,
        ]
        
        let messages = avatarInfoSettings + commonSettings
        
        let query = ChatQuery(
            messages: messages,
            model: .gpt4_o,
            maxTokens: 20
        )

        guard let openAI else {
            fatalError("API client has not yet been setup.")
        }
        
        return Observable.create { observer -> Disposable in
            openAI.chats(query: query) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let result):
                    let returnMessage = result.choices.first?.message.content?.string ?? ""
                    
                    self.repliedMail = Mail(
                        recipientName: senderName,
                        content: content,
                        senderName: recipientName,
                        date: Date()    
                    )
                    
                    self.repliedMail?.content = returnMessage
                    
                    observer.onNext("성공적으로 메일이 전달되었습니다.")
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    public func checkRepliedMailExists() -> Observable<Bool> {
        return Observable.create { [weak self] observer -> Disposable in
            guard let self else {
                fatalError("API service has not yet been setup.")
            }
            let repliedMailExists = repliedMail != nil
            observer.onNext(repliedMailExists)
            observer.onCompleted()
            
            return Disposables.create()
        }
    }
    
    
    public func getRepliedMail() -> Observable<Mail?>{
        let observable = Observable.create { [weak self] observer -> Disposable in
            guard let self else {
                fatalError("API service has not yet been setup.")
            }
            observer.onNext(repliedMail)
            observer.onCompleted()
            
            return Disposables.create()
        }
        
        return observable
    }
}

