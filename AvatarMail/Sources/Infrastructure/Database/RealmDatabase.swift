//
//  RealmDatabase.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import RealmSwift
import RxSwift


protocol RealmDatabaseDelegate {
    func saveAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String>
    func removeAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String>
    func getAllAvatars() -> Observable<[AvatarInfoObject]>
}


class RealmDatabase: RealmDatabaseDelegate {
    
    init() {
        
    }
    
    public func saveAvatar(_ avatarInfoObject: AvatarInfoObject) -> Observable<String> {
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
                        // DB에 아바타 정보 업데이트
                        realm.add(avatarInfoObject, update: .modified)
                        
                        // DB 변경사항을 옵저버에게 전파 (토스트 메시지 전달)
                        observer.onNext("아바타를 업데이트했습니다.")
                        observer.onCompleted()
                    } else {
                        // DB에 아바타 정보 추가
                        realm.add(avatarInfoObject)
                        
                        // DB 변경사항을 옵저버에게 전파 (토스트 메시지 전달)
                        observer.onNext("새로운 아바타를 추가했습니다.")
                        observer.onCompleted()
                    }
                    return Disposables.create()
                }
                
                return Disposables.create()
            } catch {
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
    
    
    public func getAvatar(withName name: String) -> Observable<AvatarInfoObject?> {
        return Observable.create { observer -> Disposable in
            do {
                let realm = try Realm()
                
                let avatarInfoObject = Array(realm.objects(AvatarInfoObject.self).where {
                    $0.name == name
                }).first
                
                observer.onNext(avatarInfoObject)
                observer.onCompleted()
            } catch {
                observer.onError(RealmDatabaseError.RealmDatabaseError(errorMessage: "아바타 목록을 불러오는 과정에서 문제가 발생했습니다."))
            }
            return Disposables.create()
        }
    }
}


enum RealmDatabaseError: Error {
    case RealmDatabaseNotInitializedError(errorMessage: String?)
    case RealmDatabaseError(errorMessage: String?)
}


