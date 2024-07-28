//
//  MailHomeCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit

protocol MailHomeCoordinatorProtocol: Coordinator {
    func showMailWritingController()
    func showRepliedMailController()
}

class MailHomeCoordinator: MailHomeCoordinatorProtocol {

    var navigationController: UINavigationController?
    
    init(
        navigationController: UINavigationController?
    ) {
        self.navigationController = navigationController
    }
    
    
    func start() {
        let mailReactor = MailHomeReactor(coordinator: self,
                                          openAIService: AppContainer.shared.getOpenAIService())
        let mailController = MailHomeController(reactor: mailReactor)
        navigationController?.pushViewController(mailController, animated: true)
    }
    
    
    func showMailWritingController() {
        let mailWritingCoordinator = MailWritingCoordinator(navigationController: navigationController)
        mailWritingCoordinator.start()
    }
    
    
    func showRepliedMailController() {
        let repliedMailCoordinator = RepliedMailCoordinator(navigationController: navigationController)
        repliedMailCoordinator.start()
    }
}

