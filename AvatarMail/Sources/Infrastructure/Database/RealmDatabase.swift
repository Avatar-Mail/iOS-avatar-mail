//
//  RealmDatabase.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import RealmSwift
import RxSwift


protocol RealmDatabaseProtocol {
    // avatar
    func saveAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String>
    func removeAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String>
    func getAllAvatars() -> Observable<[AvatarInfoObject]>
    func getAvatar(withName name: String) -> Observable<AvatarInfoObject>
    
    // mail
    func saveMail(_ mailObject: MailObject) -> Observable<Void>
    func getAllMails() -> Observable<[MailObject]>
    func removeMail(_ mailObject: MailObject) -> Observable<Void>
}


class RealmDatabase: RealmDatabaseProtocol {
    
    init() {
        
    }
    
    
    public func saveAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String> {
        
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                try realm.write {
                    let existingAvatar = realm.object(ofType: AvatarInfoObject.self, forPrimaryKey: avatarInfoObject.name)
                    
                    // 기존에 생성된 아바타가 존재하는 경우
                    if let existingAvatar {
                        // 기존 아바타의 필드 업데이트
                        existingAvatar.ageGroup = avatarInfoObject.ageGroup
                        existingAvatar.avatarRole = avatarInfoObject.avatarRole
                        existingAvatar.userRole = avatarInfoObject.userRole
                        existingAvatar.characteristic = avatarInfoObject.characteristic
                        existingAvatar.parlance = avatarInfoObject.parlance
                        
                        // 기존 녹음 파일 삭제 후 새로 추가
                        existingAvatar.recordings.removeAll()
                        existingAvatar.recordings.append(objectsIn: avatarInfoObject.recordings)
                        
                        // DB에 아바타 정보 업데이트
                        realm.add(existingAvatar, update: .modified)
                        
                        observer.onNext("아바타를 업데이트했습니다.")
                    } else {
                        // DB에 아바타 정보 추가
                        realm.add(avatarInfoObject)
                        observer.onNext("새로운 아바타를 추가했습니다.")
                    }
                    observer.onCompleted()
                }
            } catch let error as NSError {
                print("Realm Error: \(error.localizedDescription), \(error.userInfo)")
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "아바타를 추가/업데이트하는 과정에서 문제가 발생했습니다."))
            }
            
            return Disposables.create()
        }
    }

    
    public func removeAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                try realm.write { [weak self] in
                    guard let self else {
                        observer.onError(RealmDatabaseError.RealmDatabaseNotInitializedError(errorMessage: "Realm DB가 초기화되지 않았습니다."))
                        return Disposables.create()
                    }
                    
                    let existingAvatar = realm.object(ofType: AvatarInfoObject.self, forPrimaryKey: avatarInfoObject.name)
                    
                    // 기존에 생성된 아바타가 존재하는 경우
                    if let existingAvatar {
                        // DB에서 아바타 정보 삭제
                        realm.delete(existingAvatar)
                        
                        // DB 변경사항을 옵저버에게 전파 (토스트 메시지 전달)
                        observer.onNext("아바타를 삭제했습니다.")
                        observer.onCompleted()
                    } else {
                        observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "이미 존재하지 않는 아바타입니다."))
                    }
                    return Disposables.create()
                }
            } catch {
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "아바타를 삭제하는 과정에서 문제가 발생했습니다."))
            }
            
            return Disposables.create()
        }
    }
    
    
    public func getAllAvatars() -> Observable<[AvatarInfoObject]> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                let avatarInfoObjects = Array(realm.objects(AvatarInfoObject.self))
                
                observer.onNext(avatarInfoObjects)
                observer.onCompleted()
            } catch {
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "아바타 목록을 불러오는 과정에서 문제가 발생했습니다."))
            }
            return Disposables.create()
        }
    }
    
    
    public func getAvatar(withName name: String) -> Observable<AvatarInfoObject> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                let avatarInfoObject = Array(realm.objects(AvatarInfoObject.self).where {
                    $0.name == name
                }).first
                
                if let avatarInfoObject {
                    observer.onNext(avatarInfoObject)
                    observer.onCompleted()
                } else {
                    observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "존재하지 않는 아바타입니다."))
                }
            } catch {
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "아바타 목록을 불러오는 과정에서 문제가 발생했습니다."))
            }
            return Disposables.create()
        }
    }
    
    
    public func saveMail(_ mailObject: MailObject) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                try realm.write {
                    realm.add(mailObject)
                    observer.onNext(())
                    observer.onCompleted()
                }
            } catch let error as NSError {
                print("Realm Error: \(error.localizedDescription)")
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "편지를 저장하는 과정에서 문제가 발생했습니다."))
            }
        
            return Disposables.create()
        }
    }
    
    
    public func getAllMails() -> Observable<[MailObject]> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                let mailObjects = Array(realm.objects(MailObject.self))
                
                observer.onNext(mailObjects)
                observer.onCompleted()
            } catch {
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "편지 목록을 불러오는 과정에서 문제가 발생했습니다."))
            }
            return Disposables.create()
        }
    }
    
    
    public func removeMail(_ mailObject: MailObject) -> Observable<Void> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                try realm.write { [weak self] in
                    guard let self else {
                        observer.onError(RealmDatabaseError.RealmDatabaseNotInitializedError(errorMessage: "Realm DB가 초기화되지 않았습니다."))
                        return Disposables.create()
                    }
                    
                    let existingMail = realm.object(ofType: MailObject.self, forPrimaryKey: mailObject.id)
                    
                    // 기존에 생성된 편지가 존재하는 경우
                    if let existingMail {
                        // DB에서 편지 정보 삭제
                        realm.delete(existingMail)
                        
                        // DB 변경사항을 옵저버에게 전파 (토스트 메시지 전달)
                        observer.onNext(())
                        observer.onCompleted()
                    } else {
                        observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "이미 존재하지 않는 편지입니다."))
                    }
                    return Disposables.create()
                }
            } catch {
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "편지를 삭제하는 과정에서 문제가 발생했습니다."))
            }
            
            return Disposables.create()
        }
    }
}


enum RealmDatabaseError: Error {
    case RealmDatabaseNotInitializedError(errorMessage: String?)
    case RealmDatabaseError(errorMessage: String?)
}


