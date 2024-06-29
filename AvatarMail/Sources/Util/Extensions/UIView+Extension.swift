//
//  UIView+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit
import SnapKit

// MARK: - Add Subviews
extension UIView {
    @discardableResult func addSubViews(_ subviews: UIView...) -> UIView {
        subviews.forEach { [weak self] subview in
            guard let self else { return }
            self.addSubview(subview)
        }
        return self
    }
}

extension UIStackView {
    @discardableResult func addArrangedSubViews(_ subviews: UIView...) -> UIStackView {
        subviews.forEach { [weak self] subview in
            guard let self else { return }
            self.addArrangedSubview(subview)
        }
        return self
    }
}


// MARK: - UI
extension UIView {
    func animateClick(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.01) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.01) {
                self.transform = CGAffineTransform.identity
            } completion: { _ in completion() }
        }
    }
    
    func applyShadow(shadowColor: UIColor = UIColor.gray,
                     shadowRadius: CGFloat = 7,
                     shadowOffset: CGSize = .zero,
                     shadowOpacity: Float = 1) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
    }
    
    func applyCornerRadius(_ cornerRadius: CGFloat = 0, maskedCorners: CACornerMask? = nil) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        if let corners = maskedCorners {
            layer.maskedCorners = corners
        }
    }
    
    func applyGradientBackground(colors: [UIColor]) {
        layoutIfNeeded()
        
        // 기존 레이어 제거 (layoutSubviews가 여러번 호출될 때 레이어가 중첩되는 이슈 존재)
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        gradientLayer.frame = self.bounds

        // 기존 레이어의 shadow 복사
        gradientLayer.shadowPath = self.layer.shadowPath
        gradientLayer.shadowColor = self.layer.shadowColor
        gradientLayer.shadowOffset = self.layer.shadowOffset
        gradientLayer.shadowRadius = self.layer.shadowRadius
        gradientLayer.shadowOpacity = self.layer.shadowOpacity
        
        // 기존 레이어의 cornerRadius 복사
        gradientLayer.cornerRadius = self.layer.cornerRadius
        
        self.layer.insertSublayer(gradientLayer, at: 0)
    }
}
