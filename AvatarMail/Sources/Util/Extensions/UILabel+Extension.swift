//
//  UILabel+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import UIKit

extension UILabel {
    func configureWith(_ text: String,
                       color: UIColor,
                       alignment: NSTextAlignment,
                       font: UIFont) {
        self.font = font
        self.text = text
        self.textColor = color
        self.textAlignment = alignment
    }
}
