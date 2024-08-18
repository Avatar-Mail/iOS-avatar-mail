//
//  FirestoreDatabase.swift
//  AvatarMail
//
//  Created by 최지석 on 8/17/24.
//

import Foundation
import FirebaseFirestore
import RxSwift


protocol FirestoreDatabaseProtocol {
    func loadBaseServerURL() async
    func loadBaseServerURL(completion: @escaping () -> Void)
    func getCachedBaseServerURL() -> String?
}


class FirestoreDatabase: FirestoreDatabaseProtocol {
    
    static let shared = FirestoreDatabase()
    
    var database: Firestore
    var docRef: DocumentReference
    var baseServerURL: String? = nil
    
    init() {
        self.database = Firestore.firestore()
        self.docRef = database.collection("server-info").document("config")
    }
    
    func loadBaseServerURL(completion: @escaping () -> Void) {
        docRef.getDocument { (document, error) in
            if let document = document, document.exists {
                if let url = document.get("url") as? String {
                    print("[Firestore] BASE_SERVER_URL: \(String(describing: url))")
                    self.baseServerURL = url
                    completion()
                } else {
                    print("[Firestore] Error: 업로드 된 url이 존재하지 않습니다.")
                    completion()
                }
            } else {
                print("[Firestore] Error: Document가 존재하지 않습니다.")
                completion()
            }
        }
    }
    
    func loadBaseServerURL() async {
        do {
            let document = try await docRef.getDocument()
            
            if let url = document.get("url") as? String {
                print("[Firestore] BASE_SERVER_URL: \(url)")
                self.baseServerURL = url
            } else {
                print("[Firestore] Error: 업로드 된 url이 존재하지 않습니다.")
            }
        } catch {
            print("[Firestore] Error: Document를 불러오는 데 실패했습니다. - \(error.localizedDescription)")
        }
    }
    
    func getCachedBaseServerURL() -> String? {
        return baseServerURL
    }
}


enum FirestoreDatabaseError: Error {
    case FirestoreDatabaseNotInitializedError(errorMessage: String?)
    case FirestoreDatabaseError(errorMessage: String?)
}

