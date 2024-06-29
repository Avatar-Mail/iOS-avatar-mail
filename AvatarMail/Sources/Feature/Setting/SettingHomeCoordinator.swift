//
//  SettingHomeCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import Foundation
import UIKit

protocol SettingHomeCoordinatorProtocol: Coordinator {}

class SettingHomeCoordinator: SettingHomeCoordinatorProtocol {

    var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?
    ) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let settingHomeController = SettingHomeController()
        navigationController?.pushViewController(settingHomeController, animated: true)
    }
}



