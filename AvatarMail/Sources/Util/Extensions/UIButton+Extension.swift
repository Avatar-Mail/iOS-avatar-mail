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
                               fontSize: CGFloat,
                               fontWeight: UIFont.Weight) {
        setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        tintColor = color
    }
}
