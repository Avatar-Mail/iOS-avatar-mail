//
//  AvatarSettingCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit

protocol AvatarSettingCoordinatorProtocol: Coordinator {
    func closeAvatarSettingController()
}

class AvatarSettingCoordinator: AvatarSettingCoordinatorProtocol {
    
    var viewParameter: ViewParameter
    
    struct ViewParameter {
        var avatarInfo: AvatarInfo?
    }

    var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?,
        viewParameter: ViewParameter
    ) {
        self.navigationController = navigationController
        self.viewParameter = viewParameter
    }
    
    
    func start() {
        let avatarSettingReactor = AvatarSettingReactor(coordinator: self,
                                                        database: AppContainer.shared.getRealmDatabase(),
                                                        networkService: AppContainer.shared.getNetworkService(),
                                                        audioRecordingManager: AppContainer.shared.getAudioRecordingManager(),
                                                        audioPlayingManager: AppContainer.shared.getAudioPlayingManager(),
                                                        ttsAdapter: AppContainer.shared.getTTSAdapter(),
                                                        storageManager: AppContainer.shared.getStorageManager(),
                                                        avatar: viewParameter.avatarInfo)
        let avatarSettingController = AvatarSettingController(reactor: avatarSettingReactor)
        navigationController?.pushViewController(avatarSettingController, animated: true)
    }
    
    
    func closeAvatarSettingController() {
        navigationController?.popViewController(animated: true)
    }
}
