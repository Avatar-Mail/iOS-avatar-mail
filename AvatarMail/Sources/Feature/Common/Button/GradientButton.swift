//
//  GradientButton.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import UIKit


final class GradientButton: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
    public func setButtonTitle(title: String,
                               titleColor: UIColor = .white,
                               fontSize: CGFloat = 20,
                               fontWeight: UIFont.Weight = .bold) {
        super.setTitle(title, for: .normal)
        titleLabel?.font = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        tintColor = .white
    }
    
    
    public func setButtonShadow(shadowColor: UIColor,
                                shadowRadius: CGFloat,
                                shadowOffset: CGSize,
                                shadowOpacity: Float) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
    }
}
