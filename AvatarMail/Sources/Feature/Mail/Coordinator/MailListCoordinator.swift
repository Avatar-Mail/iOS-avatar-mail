//
//  MailListCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import Foundation
import UIKit

protocol MailListCoordinatorProtocol: Coordinator {
    func closeMailListController()
    func showRepliedMailController(with mail: Mail)
    func openMailWritingController()
}

class MailListCoordinator: MailListCoordinatorProtocol {
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    
    public func start() {
        let mailListReactor = MailListReactor(coordinator: self,
                                              database: AppContainer.shared.getRealmDatabase(),
                                              ttsAdapter: AppContainer.shared.getTTSAdapter())
        let mailWritingController = MailListController(reactor: mailListReactor)
        navigationController?.pushViewController(mailWritingController, animated: true)
    }

    
    public func closeMailListController() {
        navigationController?.popViewController(animated: true)
    }
    
    
    public func showRepliedMailController(with mail: Mail) {
        let viewParameter = RepliedMailCoordinator.ViewParameter(mail: mail)
        let repliedMailCoordinator = RepliedMailCoordinator(navigationController: navigationController,
                                                            viewParameter: viewParameter)
        repliedMailCoordinator.start()
    }
    
    
    public func openMailWritingController() {
        let mailWritingCoordinator = MailWritingCoordinator(navigationController: navigationController)
        mailWritingCoordinator.start()
    }
}


