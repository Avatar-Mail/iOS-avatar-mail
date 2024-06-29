//
//  RepliedMailCoordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit


protocol RepliedMailCoordinatorProtocol: Coordinator {
    func closeRepliedMailController()
    func showMailWritingControllerAfterClose()
}

class RepliedMailCoordinator: RepliedMailCoordinatorProtocol {
    
    var navigationController: UINavigationController?
    
    init(navigationController: UINavigationController?) {
        self.navigationController = navigationController
    }
    
    
    public func start() {
        let repliedMailReactor = RepliedMailReactor(coordinator: self,
                                                    openAIService: AppContainer.shared.getOpenAIService())
        let repliedMailController = RepliedMailController(reactor: repliedMailReactor)
        navigationController?.pushViewController(repliedMailController, animated: true)
    }

    
    public func closeRepliedMailController() {
        navigationController?.popViewController(animated: true)
    }
    
    
    public func showMailWritingControllerAfterClose() {
        navigationController?.popViewController(animated: true, completion: { [weak self] in
            guard let self else { return }
            let mailWritingCoordinator = MailWritingCoordinator(navigationController: self.navigationController)
            mailWritingCoordinator.start()
        })
    }
}



