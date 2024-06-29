//
//  Coordinator.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit

protocol Coordinator {
    var navigationController: UINavigationController? { get set }
    func start()
}
