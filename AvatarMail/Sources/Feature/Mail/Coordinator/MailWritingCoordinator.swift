//
//  MailWritingCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit

protocol MailWritingCoordinatorProtocol: Coordinator {
    func closeMailWritingController()
}

class MailWritingCoordinator: MailWritingCoordinatorProtocol {
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    
    public func start() {
        let mailWritingReactor = MailWritingReactor(coordinator: self,
                                                    openAIService: AppContainer.shared.getOpenAIService(),
                                                    database: AppContainer.shared.getRealmDatabase())
        let mailWritingController = MailWritingController(reactor: mailWritingReactor)
        navigationController?.pushViewController(mailWritingController, animated: true)
    }

    
    public func closeMailWritingController() {
        navigationController?.popViewController(animated: true)
    }
}


