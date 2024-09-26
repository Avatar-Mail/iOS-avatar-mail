//
//  AvatarSettingReactor.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import ReactorKit

class AvatarSettingReactor: Reactor {

    enum Action {
        // Logic
        case loadSampleTexts
        case changeSampleText
        case avatarNameDidChange(name: String)
        case avatarAgeDidChange(age: String?)
        case avatarSelfRoleDidChange(avatarRole: String?)
        case avatarUserRoleDidChange(userRole: String?)
        case avatarCharacteristicDidChange(characteristic: String?)
        case avatarParlanceDidChange(parlance: String?)
        case saveAvatar
        case downloadAudioFile(url: URL, contents: String)
        case startRecording(recordingContents: String?)
        case stopRecording
        case startPlaying(recording: AudioRecording)
        case stopPlaying
        case setPlayingCellIndexPath(indexPath: IndexPath?)
        case showToast(text: String)
        case addToTempDeletedAudioFilesAndHide(fileName: String)
        case removeAllTempDeletedAudioFiles
        case removeAllTempSavedAudioFiles
        // Navigation
        case closeAvatarSettingController
    }
    
    enum Mutation {
        case setSampleTexts(texts: [String])
        case setSelectedSampleText(text: String)
        case setAvatarName(name: String)
        case setAvatarAge(age: String?)
        case setAvatarSelfRole(avatarRole: String?)
        case setAvatarUserRole(userRole: String?)
        case setAvatarCharacteristic(characteristic: String?)
        case setAvatarParlance(parlance: String?)
        case setIsRecording(isRecording: Bool)
        case setIsPlaying(isPlaying: Bool)
        case setPlayingCellIndexPath(indexPath: IndexPath?)
        case setStoppedPlayingCellIndexPath(indexPath: IndexPath?)
        case addRecording(recording: AudioRecording)
        case removeRecording(fileName: String)
        case setAvatarHasSaved(hasSaved: Bool)
        case addTempSavedAudioFile(fileName: String)
        case addTempDeletedAudioFile(fileName: String)
        case setToastMessage(text: String)
    }
    
    struct State {
        var sampleTexts: [String]           // 음성 녹음용 샘플 텍스트 배열
        var selectedSampleText: String      // 선택된 샘플 텍스트
        
        var id: String                      // ID
        var name: String                    // 이름
        var age: String?                    // 나이
        var avatarRole: String?             // 아바타의 역할(관계)
        var userRole: String?               // 사용자의 역할(관계)
        var characteristic: String?         // 성격
        var parlance: String?               // 말투
        var recordings: [AudioRecording]    // 음성 녹음 파일들
        
        var isRecording: Bool               // 녹음 중인지 여부
        var isPlaying: Bool                 // 재생 중인지 여부
        
        var hasAvatarSaved: Bool            // 아바타 저장 여부
        
        var tempSavedAudioFiles:   [String] // 임시 저장 오디오 파일 (아바타가 저장되지 않으면 파일 시스템에서 제거)
        var tempDeletedAudioFiles: [String] // 임시 삭제 오디오 파일 (기존 음성 파일 삭제 후, 아바타 저장 시 파일 시스템에서 제거)
        
        @Pulse var playingCellIndexPath: IndexPath?         // 재생 중인 파일 indexPath (재생 중인 파일이 없으면 nil)
        @Pulse var stoppedPlayingCellIndexPath: IndexPath?  // 재생이 끝난 파일 indexPath (재생이 끝난 파일이 없으면 nil)
        @Pulse var toastMessage: String?
    }
    
    var initialState: State
    
    
    // MARK: - Initialization
    var coordinator: AvatarSettingCoordinator
    var database: RealmDatabaseProtocol
    var networkService: NetworkServiceProtocol
    var audioRecordingManager: AudioRecordingManager
    var audioPlayingManager: AudioPlayingManager
    var ttsAdapter: TTSAdapterProtocol
    var storageManager: StorageManagerProtocol
    
    init(
        coordinator: AvatarSettingCoordinator,
        database: RealmDatabaseProtocol,
        networkService: NetworkServiceProtocol,
        audioRecordingManager: AudioRecordingManager,
        audioPlayingManager: AudioPlayingManager,
        ttsAdapter: TTSAdapterProtocol,
        storageManager: StorageManagerProtocol,
        avatar: AvatarInfo?
    ) {
        self.coordinator = coordinator
        self.database = database
        self.networkService = networkService
        self.audioRecordingManager = audioRecordingManager
        self.audioPlayingManager = audioPlayingManager
        self.ttsAdapter = ttsAdapter
        self.storageManager = storageManager

        self.initialState = State(sampleTexts: [],
                                  selectedSampleText: "샘플 텍스트가 없습니다.",
                                  id: avatar?.id ?? UUID().uuidString,
                                  name: avatar?.name ?? "",
                                  age: avatar?.ageGroup,
                                  avatarRole: avatar?.relationship.avatar,
                                  userRole: avatar?.relationship.user,
                                  characteristic: avatar?.characteristic,
                                  parlance: avatar?.parlance, 
                                  recordings: avatar?.recordings ?? [],
                                  isRecording: false,
                                  isPlaying: false,
                                  hasAvatarSaved: false,
                                  tempSavedAudioFiles: [],
                                  tempDeletedAudioFiles: [])
        
        self.audioPlayingManager.delegate = self
    }
    
    
    // MARK: - mutate
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        // Logic
        case let .avatarNameDidChange(name: name):
            return Observable.just(Mutation.setAvatarName(name: name))
        case let .avatarAgeDidChange(age: age):
            return Observable.just(Mutation.setAvatarAge(age: age))
        case let .avatarSelfRoleDidChange(avatarRole: avatarRole):
            return Observable.just(Mutation.setAvatarSelfRole(avatarRole: avatarRole))
        case let .avatarUserRoleDidChange(userRole: userRole):
            return Observable.just(Mutation.setAvatarUserRole(userRole: userRole))
        case let .avatarCharacteristicDidChange(characteristic: characteristic):
            return Observable.just(Mutation.setAvatarCharacteristic(characteristic: characteristic))
        case let .avatarParlanceDidChange(parlance: parlance):
            return Observable.just(Mutation.setAvatarParlance(parlance: parlance))
        case let .startRecording(recordingContents: recordingContents):
            return startRecording(recordingContents: recordingContents)
        case .stopRecording:
            return stopRecording()
        case let .startPlaying(recording: recording):
            return startPlaying(recording: recording)
        case .stopPlaying:
            return stopPlaying()
        case let .setPlayingCellIndexPath(indexPath: indexPath):
            return Observable.of(
                Mutation.setPlayingCellIndexPath(indexPath: indexPath),
                Mutation.setStoppedPlayingCellIndexPath(indexPath: currentState.playingCellIndexPath)
            )
        case .saveAvatar:
            let avatar = AvatarInfo(id: UUID().uuidString,
                                    name: currentState.name,
                                    ageGroup: currentState.age,
                                    relationship: Relationship(avatar: currentState.avatarRole,
                                                               user: currentState.userRole),
                                    characteristic: currentState.characteristic,
                                    parlance: currentState.parlance,
                                    recordings: currentState.recordings)
            return saveAvatar(avatar)
        case .loadSampleTexts:
            return loadSampleTexts()
        case .changeSampleText:
            return changeSelectedSampleText(sampleTexts: currentState.sampleTexts)
        case let .downloadAudioFile(url, contents):
            return downloadAudioFile(url: url, avatarName: currentState.name, contents: contents)
        case let .addToTempDeletedAudioFilesAndHide(fileName):
            return Observable.of(
                Mutation.addTempDeletedAudioFile(fileName: fileName),
                Mutation.removeRecording(fileName: fileName)
            )
        case .removeAllTempDeletedAudioFiles:
            return removeAllTempDeletedAudioFiles(audioFileNames: currentState.tempDeletedAudioFiles)
        case .removeAllTempSavedAudioFiles:
            return removeAllTempSavedAudioFiles(audioFileNames: currentState.tempSavedAudioFiles)
        case let .showToast(text):
            return Observable.just(Mutation.setToastMessage(text: text))
        // Navigation
        case .closeAvatarSettingController:
            coordinator.closeAvatarSettingController()
            return .empty()
        }
    }
    
    
    // MARK: - reduce
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setSampleTexts(texts: texts):
            newState.sampleTexts = texts
        case let .setSelectedSampleText(text: text):
            newState.selectedSampleText = text
        case let .setAvatarName(name: name):
            newState.name = name
        case let .setAvatarAge(age: age):
            newState.age = age
        case let .setAvatarSelfRole(avatarRole: avatarRole):
            newState.avatarRole = avatarRole
        case let .setAvatarUserRole(userRole: userRole):
            newState.userRole = userRole
        case let .setAvatarCharacteristic(characteristic: characteristic):
            newState.characteristic = characteristic
        case let .setAvatarParlance(parlance: parlance):
            newState.parlance = parlance
        case let .setIsRecording(isRecording: isRecording):
            newState.isRecording = isRecording
        case let .addRecording(recording: recording):
            newState.recordings = state.recordings + [recording]
        case let .removeRecording(fileName: fileName):
            newState.recordings = state.recordings.filter { $0.fileName != fileName }
        case let .setIsPlaying(isPlaying: isPlaying):
            newState.isPlaying = isPlaying
        case let .setPlayingCellIndexPath(indexPath: indexPath):
            newState.playingCellIndexPath = indexPath
        case let .setStoppedPlayingCellIndexPath(indexPath: indexPath):
            newState.stoppedPlayingCellIndexPath = indexPath
        case let .setAvatarHasSaved(hasSaved: hasSaved):
            newState.hasAvatarSaved = hasSaved
        case let .addTempSavedAudioFile(fileName: fileName):
            newState.tempSavedAudioFiles = state.tempSavedAudioFiles + [fileName]
        case let .addTempDeletedAudioFile(fileName: fileName):
            newState.tempDeletedAudioFiles = state.tempDeletedAudioFiles + [fileName]
        case let .setToastMessage(text: text):
            newState.toastMessage = text
        }
        
        return newState
    }
    
    
    private func loadSampleTexts() -> Observable<Mutation> {
        do {
            guard let path = Bundle.main.path(forResource: "SampleText", ofType: "json") else {
                return Observable.just(.setToastMessage(text: "JSON 파일 경로를 찾을 수 없습니다."))
            }
            
            let jsonString = try String(contentsOfFile: path)
            let decoder = JSONDecoder()
            
            guard let data = jsonString.data(using: .utf8) else {
                return Observable.just(.setToastMessage(text: "JSON 문자열을 데이터로 변환하는 데 실패했습니다."))
            }
            
            do {
                let sampleTextModel = try decoder.decode(SampleText.self, from: data)
                
                // 화면에 표시할 랜덤 샘플 텍스트 선택
                if let randomSampleText = sampleTextModel.samples.randomElement() {
                    return Observable.of(
                        Mutation.setSelectedSampleText(text: randomSampleText),
                        Mutation.setSampleTexts(texts: sampleTextModel.samples)
                    )
                } else {
                    return Observable.just(.setToastMessage(text: "샘플 텍스트를 가져오는 데 실패했습니다."))
                }
            } catch let error {
                print("JSON Parsing Error: \(error.localizedDescription)")
                return Observable.just(.setToastMessage(text: "샘플 텍스트 JSON 파일을 파싱하는 데 실패했습니다: \(error.localizedDescription)"))
            }
        } catch let error {
            print("File Read Error: \(error.localizedDescription)")
            return Observable.just(.setToastMessage(text: "JSON 파일을 불러오는 데 실패했습니다: \(error.localizedDescription)"))
        }
    }
    
    
    private func changeSelectedSampleText(sampleTexts: [String]) -> Observable<Mutation> {
        if let randomSampleText = sampleTexts.randomElement() {
            return Observable.just(.setSelectedSampleText(text: randomSampleText))
        } else {
            return Observable.just(.setToastMessage(text: "샘플 텍스트를 가져오는 데 실패했습니다."))
        }
    }
    
    
    private func saveAvatar(_ avatar: AvatarInfo) -> Observable<Mutation> {
        
        guard avatar.name.isNotEmpty else {
            return Observable.just(.setToastMessage(text: "아바타 이름을 입력하세요."))
        }
        
        let avatarObject = AvatarInfoObject(avatar: avatar)
        
        return database.saveAvatar(avatarObject)
            .flatMap { toastMessage in
                
                self.ttsAdapter.saveAvatar(avatarID: avatar.id,
                                           audioURLs: avatar.recordings.map { self.storageManager.getFileURL(fileName: $0.fileName, type: .audio) } )
                .flatMap { response in
                    return Observable.of(
                        Mutation.setToastMessage(text: toastMessage),
                        Mutation.setAvatarHasSaved(hasSaved: true)
                    )
                }
                .catch { error in
                    let networkError = RefactoredNetworkServiceError(error: error)
                    return Observable.of(
                        Mutation.setToastMessage(text: networkError.message ?? "서버에 편지를 보내는 과정에서 문제가 발생했습니다.")
                    )
                }
            }
            .catch { error in
                if let error = error as? RealmDatabaseError {
                    switch error {
                    case .RealmDatabaseNotInitializedError(let message):
                        return Observable.just(Mutation.setToastMessage(text: message ?? "RealmDatabaseNotInitializedError"))
                    case .RealmDatabaseError(let message):
                        return Observable.just(Mutation.setToastMessage(text: message ?? "RealmDatabaseError"))
                    }
                } else {
                    return Observable.just(Mutation.setToastMessage(text: "Unknown RealmDatabaseError"))
                }
            }
    }
    
    private func startRecording(recordingContents: String?) -> Observable<Mutation> {
        
        if let recordingContents, !recordingContents.isEmpty {
            let result = audioRecordingManager.startRecording(contents: recordingContents,
                                                              with: currentState.name)
            
            switch result {
            case .success(_):
                return Observable.just(.setIsRecording(isRecording: true))
            case .failure(_):
                return Observable.just(.setToastMessage(text: "녹음하는데 실패했습니다."))
            }
        } else {
            return Observable.just(.setToastMessage(text: "녹음할 문장을 먼저 입력해주세요."))
        }
    }
    
    private func stopRecording() -> Observable<Mutation> {
        
        if currentState.isRecording {
            let result = audioRecordingManager.stopRecording()
            
            switch result {
            case .success(let recording):
                return Observable.of(
                    .setIsRecording(isRecording: false),
                    .addRecording(recording: recording),
                    .addTempSavedAudioFile(fileName: recording.fileName),
                    .setToastMessage(text: "정상적으로 녹음을 완료했습니다.")
                )
            case .failure(_):
                return Observable.of(
                    .setIsRecording(isRecording: false),
                    .setToastMessage(text: "녹음하는 데 실패했습니다.")
                )
            }
        } else {
            return Observable.of(
                .setIsRecording(isRecording: false),
                .setToastMessage(text: "현재 녹음 중이 아닙니다.")
            )
        }
    }
    
    private func startPlaying(recording: AudioRecording) -> Observable<Mutation> {
        
        let fileURL = storageManager.getFileURL(fileName: recording.fileName, type: .audio)
        let result = audioPlayingManager.startPlaying(url: fileURL)
            
        switch result {
        case .success(_):
            return Observable.just(.setIsPlaying(isPlaying: true))
        case .failure(_):
            return Observable.just(.setToastMessage(text: "파일을 재생하는데 실패했습니다."))
        }
    }
    
    private func stopPlaying() -> Observable<Mutation> {
        
        if currentState.isPlaying {
            let result = audioPlayingManager.stopPlaying()
            
            switch result {
            case .success:
                return Observable.of(
                    .setIsPlaying(isPlaying: false)
                )
            case .failure(_):
                return Observable.of(
                    .setIsRecording(isRecording: false),
                    .setToastMessage(text: "재생하는 데 실패했습니다.")
                )
            }
        } else {
            return Observable.of(
                .setIsRecording(isRecording: false),
                .setToastMessage(text: "현재 재생 중이 아닙니다.")
            )
        }
    }

    private func downloadAudioFile(url: URL, avatarName: String, contents: String) -> Observable<Mutation> {
        return Observable<AudioRecording>.create { [weak self] observer in
            guard let self = self else {
                observer.onCompleted()
                return Disposables.create()
            }

            // iCloud 파일에 접근하기 위한 권한 확보
            let fileCoordinator = NSFileCoordinator()
            var error: NSError? = nil

            fileCoordinator.coordinate(readingItemAt: url, options: [], error: &error) { (newURL) in
                if newURL.startAccessingSecurityScopedResource() {
                    defer {
                        newURL.stopAccessingSecurityScopedResource()
                    }

                    do {
                        let data = try Data(contentsOf: newURL)
                        let fileID = UUID().uuidString
                        let fileName = "\(contents).m4a"
                        let currentDate = Date()

                        try self.storageManager.save(data: data, fileName: fileName, type: .audio)
                        print("[download] 오디오 파일을 다운로드하는 데 성공했습니다.")

                        observer.onNext(AudioRecording(id: fileID,
                                                       fileName: fileName,
                                                       contents: contents,
                                                       createdDate: currentDate,
                                                       duration: 0.0))
                        observer.onCompleted()
                    } catch {
                        print("[download] 오디오 파일을 다운로드하는 데 실패했습니다. - error: \(error)")
                        observer.onError(error)
                    }
                } else {
                    print("[download] 파일에 접근할 권한이 없습니다.")
                    observer.onError(NSError(domain: "AccessError", code: -1, userInfo: [NSLocalizedDescriptionKey: "파일에 접근할 권한이 없습니다."]))
                }
            }

            if let error = error {
                print("[download] 파일 접근 중 오류 발생 - error: \(error)")
                observer.onError(error)
            }

            return Disposables.create()
        }
        .flatMap { audioRecording in
            Observable.of(
                Mutation.addRecording(recording: audioRecording),
                Mutation.setToastMessage(text: "오디오 파일을 다운로드하는 데 성공했습니다.")
            )
        }
        .catch { error in
            Observable.of(Mutation.setToastMessage(text: "오디오 파일을 다운로드하는 데 실패했습니다. - error: \(error.localizedDescription)"))
        }
    }

    private func removeAllTempDeletedAudioFiles(audioFileNames: [String]) -> Observable<Mutation> {
        for fileName in audioFileNames {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self else { return }
                
                do {
                    try storageManager.delete(fileName: fileName, type: .audio)
                } catch {
                    return  // 예외 처리 필요
                }
            }
        }
        return .empty()
    }
    
    private func removeAllTempSavedAudioFiles(audioFileNames: [String]) -> Observable<Mutation> {
        for fileName in audioFileNames {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self else { return }
                
                do {
                    try storageManager.delete(fileName: fileName, type: .audio)
                } catch {
                    return  // 예외 처리 필요
                }
            }
        }
        return .empty()
    }
}



extension AvatarSettingReactor: AudioPlayingManagerDelegate {
    func didFinishPlaying(with fileURL: String?) {
        print("End playing")
        self.action.onNext(.stopPlaying)
        self.action.onNext(.setPlayingCellIndexPath(indexPath: nil))
    }
}
