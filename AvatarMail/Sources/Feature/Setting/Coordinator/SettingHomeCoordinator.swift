//
//  SettingHomeCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import Foundation
import UIKit

protocol SettingHomeCoordinatorProtocol: Coordinator {
    func presentEndPointSettingModal()
}

class SettingHomeCoordinator: SettingHomeCoordinatorProtocol {

    var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?
    ) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        
        let appVersion = Bundle.main.infoDictionary?["AppVersion"] as? String ?? "None"
            
        let settingHomeReactor = SettingHomeReactor(coordinator: self,
                                                    appVersion: appVersion)
        let settingHomeController = SettingHomeController(reactor: settingHomeReactor)
        navigationController?.pushViewController(settingHomeController, animated: true)
    }
    
    func presentEndPointSettingModal() {
        
    }
}



