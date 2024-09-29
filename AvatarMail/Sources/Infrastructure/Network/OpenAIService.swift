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
    func sendMail(mail: Mail, avatarInfo: AvatarInfo) -> Observable<OpenAIResponse>
    func sendMail2(mail: Mail, avatarInfo: AvatarInfo) -> Observable<OpenAIResponse>
    func sendMail3(mail: Mail, avatarInfo: AvatarInfo) -> Observable<OpenAIResponse>
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
    
    
    public func sendMail(mail: Mail,
                         avatarInfo: AvatarInfo
    ) -> Observable<OpenAIResponse> {
        
        print("OpenAIService : \(String(describing: avatarInfo))")
        
        // 아바타 세팅
        var avatarInfoSettings: [ChatQuery.ChatCompletionMessageParam] = []
        
        if let characteristic = avatarInfo.characteristic {
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너의 성격은 \(String(describing: avatarInfo))")!)
        }
        
        if let parlance = avatarInfo.parlance {
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너의 말투는 대괄호 속의 말투와 같다. [\(String(describing: parlance))]")!)
        }
        
        if let ageGroup = avatarInfo.ageGroup {
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너의 나이대는 \(String(describing: ageGroup))이다.")!)
        }
        
        if let avatarRole = avatarInfo.relationship.avatar {
            avatarInfoSettings.append(.init(role: .system,
                                            content: "너는 사용자의 \(String(describing: avatarRole))이다.")!)
        }
        
        if let userRole = avatarInfo.relationship.user {
            avatarInfoSettings.append(.init(role: .system,
                                            content: "사용자는 너의 \(String(describing: userRole))이다.")!)
        }
        
        // 시스템 설정
        let commonSettings: [ChatQuery.ChatCompletionMessageParam] = [
            // 시스템 설정
            .init(role: .system,
                  content: "너는 너의 성격, 말투, 나이대, 사용자와의 관계를 바탕으로, 사용자가 작성한 편지에 대한 답장 편지를 작성해야 한다.")!,
            .init(role: .system,
                  content: "답장 편지의 내용은 사용자의 입력을 참고하여, 사용자가 입력한 편지에 대한 답장을 작성해야 한다.")!,
            .init(role: .system,
                  content: "사용자가 보낸 편지의 내용을 그대로 복사하는 것이 아니라, 사용자의 편지의 내용에 대한 답장을 작성해야 한다.")!,
            .init(role: .system,
                  content: "답장 편지를 보내는 대상의 이름은 '\(mail.senderName)'이다.")!,
            .init(role: .system,
                  content: "답장 편지에는 너의 이름인 '\(mail.recipientName)'이 포함되면 안 된다.")!,
            .init(role: .system,
                  content: "답장 편지에는 너의 이름이 아니라, 보내는 대상의 이름이 포함되어야 한다.")!,
            .init(role: .system,
                  content: "답장 편지에는 대괄호 속의 너의 말투가 반영되어야 한다.")!,
            .init(role: .system,
                  content: "편지의 내용은 200자 이상이어야 한다.")!,
            .init(role: .system,
                  content: "편지의 내용은 최대한 자연스러워야 한다.")!,
            // 실제 사용자 입력
            .init(role: .user,
                  content: "\(mail.content)")!,
        ]
        
        let messages = avatarInfoSettings + commonSettings
        
        let query = ChatQuery(
            messages: messages,
            model: .gpt4_o,
            maxTokens: 300
        )

        guard let openAI else {
            fatalError("API client has not yet been setup.")
        }
        
        return Observable.create { observer -> Disposable in
            openAI.chats(query: query) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let result):
                    let content = result.choices.first?.message.content?.string ?? ""
                    let response = OpenAIResponse(content: content)
                    
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    public func sendMail2(mail: Mail,
                          avatarInfo: AvatarInfo
    ) -> Observable<OpenAIResponse> {

        let prompt: [ChatQuery.ChatCompletionMessageParam] = [
            
            .init(role: .system,
                  content: """
                    Your name is {\(mail.recipientName)}.

                    You need to write a reply letter to the letter written by the recipient, which is <INPUT_MAIL>.

                    The recipient's name is {\(mail.senderName)}.

                    Your reply should be addressed to {\(mail.senderName)}.

                    Your characteristics are outlined below:
                    <CHARACTERISTICS>
                    (1) Age Group: { \(avatarInfo.ageGroup ?? "NONE") }
                    (2) Personality: { \(avatarInfo.characteristic ?? "NONE") }
                    (3) Parlance: { \(avatarInfo.parlance ?? "NONE") }
                    (4) Relationship:
                      - You: { \(avatarInfo.relationship.avatar ?? "NONE") }
                      - Recipient: { \(avatarInfo.relationship.user ?? "NONE") }
                    </CHARACTERISTICS>

                    If any characteristic is 'NONE', infer the missing traits based on the available information.

                    Your reply letter should reflect your age group, personality, parlance, and relationship with the recipient, as described in the <CHARACTERISTICS>.

                    Make sure to adhere to the following conditions when writing your reply:

                    <CONDITION>
                    (1) Include only the recipient's name in the letter; do not include your own name, '\(mail.recipientName)'.
                    (2) Address the content of the letter in <INPUT_MAIL> written by the recipient.
                    (3) The letter must be at least 200 characters long.
                    (4) Write the reply in the same language as <INPUT_MAIL>.
                    (5) Ensure the content flows naturally and coherently.
                    </CONDITION>

                    Write a reply letter based on the above information.
                    """)!,
            // 실제 사용자 입력
            .init(role: .user,
                  content: """
                    <INPUT_MAIL>
                    \(mail.content)
                    </INPUT_MAIL>
                    """)!,
        ]
        
        let query = ChatQuery(
            messages: prompt,
            model: .gpt4_o,
            maxTokens: 300
        )

        guard let openAI else {
            fatalError("API client has not yet been setup.")
        }
        
        return Observable.create { observer -> Disposable in
            openAI.chats(query: query) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let result):
                    let content = result.choices.first?.message.content?.string ?? ""
                    let response = OpenAIResponse(content: content)
                    
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
    
    
    public func sendMail3(mail: Mail, avatarInfo: AvatarInfo) -> Observable<OpenAIResponse> {
        let prompt: [ChatQuery.ChatCompletionMessageParam] = [
            .init(role: .system,
                  content: """
                  <Instructions>

                      Your name is { \(mail.recipientName) }.
                      You should write a reply to a letter sent by "{\(mail.senderName)}", provided as <INPUT_MAIL>.

                      Your reply letter should reflect the described <CHARACTERISTICS> such as age group, personality, parlance, and relationship.
                      If any characteristic is 'NONE', infer the missing traits based on the available information.
                      <CHARACTERISTICS>
                          <AgeGroup>{ \(avatarInfo.ageGroup ?? "NONE") }</AgeGroup>
                          <Personality>{ \(avatarInfo.characteristic ?? "NONE") }</Personality>
                          <Parlance>{ \(avatarInfo.parlance ?? "NONE") }</Parlance>
                          <Relationship>
                              <You>{ \(avatarInfo.relationship.avatar ?? "NONE") }</You>
                              <Recipient>{ \(avatarInfo.relationship.user ?? "NONE") }</Recipient>
                          </Relationship>
                      </CHARACTERISTICS>

                      Please adhere to the following conditions while writing your reply:
                      <CONDITION>
                          <Item>(1) Include only the recipient's name in the letter; do not include your own name, '\(mail.recipientName)'.</Item>
                          <Item>(2) Write the reply in the same language as the original <INPUT_MAIL>.</Item>
                          <Item>(3) Ensure the content flows naturally and is coherent.</Item>
                          <Item>(4) Tailor your writing style to match the tone and parlance of the <CHARACTERISTICS>.</Item>
                          <Item>(5) Be considerate of the context provided in <INPUT_MAIL> to craft a meaningful and relevant reply.</Item>
                          <Item>(6) Do not add any tags or markup to the content of the letter itself.</Item>
                          <Item>(7) Do not use '\(mail.senderName)' in the greeting or closing of the letter; write only the main content without specific address to the recipient's name.</Item>
                          <Item>(8) Avoid using any expressions like 'to ~' or 'from ~' at the beginning or end of the letter.</Item>
                      </CONDITION>

                      Write a reply letter based on the above information.
                  
                  </Instructions>
                  """)!,
            .init(role: .user,
                  content: """
                    <INPUT_MAIL>
                    \(mail.content)
                    </INPUT_MAIL>
                  """)!,
        ]
        
        let query = ChatQuery(
            messages: prompt,
            model: .gpt4_o,
            maxTokens: 500
        )

        guard let openAI else {
            fatalError("API client has not yet been setup.")
        }
        
        return Observable.create { observer -> Disposable in
            openAI.chats(query: query) { [weak self] result in
                guard let self else { return }
                
                switch result {
                case .success(let result):
                    let content = result.choices.first?.message.content?.string ?? ""
                    let response = OpenAIResponse(content: content)
                    
                    observer.onNext(response)
                    observer.onCompleted()
                case .failure(let error):
                    observer.onError(error)
                }
            }
            
            return Disposables.create()
        }
    }
}


enum OpenAIServiceError: Error {
    case OpenAIServiceNotInitializedError(errorMessage: String?)
    case OpenAIServiceError(errorMessage: String?)
}



//Your name is {\(mail.recipientName)}.
//
//You have to write a reply letter to the letter written by the recipient, which is <INPUT_MAIL>
//
//The recipient's name is {\(mail.senderName)}.
//
//You have to write a reply letter to {\(mail.senderName)}.
//
//Your characteristics are as stated in <CHARACTERISTICS>.
//
//Your reply letter should match your age group, personality, parlance, and relationship with the recipient, as described in the <CHARACTERISTICS>.
//
//If 'NONE' is provided, infer the rest of the traits based on the available characteristics.
//
//<CHARACTERISTICS>
//(1) Age Group : { \(avatarInfo.ageGroup ?? "NONE") }
//(2) Personality : { \(avatarInfo.characteristic ?? "NONE") }
//(3) Parlance : { \(avatarInfo.parlance ?? "NONE") }.
//(4) RelationShip : { \(avatarInfo.parlance ?? "NONE") }.
//  - You : { \(avatarInfo.relationship.avatar ?? "NONE") }
//  - Recipient : { \(avatarInfo.relationship.user ?? "NONE") }
//</CHARACTERISTICS>
//
//Also, your reply letter must meet the conditions specified in the <CONDITION> below.
//
//<CONDITION>
//(1) The reply letter should include only the recipient's name, and not your own.
//(2) Do not include your name, '\(mail.recipientName)' in the letter.
//(3) The reply letter should address the content of the letter within the <INPUT_MAIL> written by the recipient.
//(4) The content of the letter must be at least 200 characters long.
//(5) The reply letter must be written in the same language as the <INPUT_MAIL>.
//(6) The content of the letter should flow as naturally as possible.
//</CONDITION>
//
//Write a reply letter based on the above information.
