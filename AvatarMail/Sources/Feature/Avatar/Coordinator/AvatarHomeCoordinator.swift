//
//  AvatarHomeCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit

protocol AvatarHomeCoordinatorProtocol: Coordinator {
    func showAvatarSettingController(with avatar: AvatarInfo?)
}

class AvatarHomeCoordinator: AvatarHomeCoordinatorProtocol {

    var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?
    ) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let avatarHomeReactor = AvatarHomeReactor(coordinator: self,
                                                  database: AppContainer.shared.getRealmDatabase())
        let avatarHomeController = AvatarHomeController(reactor: avatarHomeReactor)
        navigationController?.pushViewController(avatarHomeController, animated: true)
    }
    
    
    func showAvatarSettingController(with avatar: AvatarInfo?) {
        print(avatar?.name ?? "None")
        let viewParameter = AvatarSettingCoordinator.ViewParameter(avatarInfo: avatar)
        let avatarSettingCoordinator = AvatarSettingCoordinator(navigationController: navigationController,
                                                                viewParameter: viewParameter)
        avatarSettingCoordinator.start()
    }
}


