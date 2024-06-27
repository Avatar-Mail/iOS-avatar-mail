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
    
    func addShadow() {
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOffset = .zero
        layer.shadowOpacity = 0.4
        layer.shadowRadius = 7
    }
    
    func setupCornerRadius(_ cornerRadius: CGFloat = 0, maskedCorners: CACornerMask? = nil) {
        layer.cornerRadius = cornerRadius
        if let corners = maskedCorners {
            layer.maskedCorners = corners
        }
    }
    
    func applyGradientBackground(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        self.layer.insertSublayer(gradientLayer, at: 0)

        self.layer.sublayers?.first?.frame = self.bounds
    }
}
