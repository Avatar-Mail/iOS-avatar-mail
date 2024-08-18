//
//  UIButton+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import UIKit

extension UIButton {
    public func setButtonTitle(title: String,
                               color: UIColor,
                               font: UIFont) {
        setTitle(title, for: .normal)
        setTitleColor(color, for: .normal)
        titleLabel?.font = font
    }
}
