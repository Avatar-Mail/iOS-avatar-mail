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
    public func animateClick(completion: @escaping () -> Void) {
        UIView.animate(withDuration: 0.01) {
            self.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        } completion: { _ in
            UIView.animate(withDuration: 0.01) {
                self.transform = CGAffineTransform.identity
            } completion: { _ in completion() }
        }
    }
    
    public func applyShadow(shadowColor: UIColor = UIColor.gray,
                     shadowRadius: CGFloat = 7,
                     shadowOffset: CGSize = .zero,
                     shadowOpacity: Float = 1) {
        layer.shadowColor = shadowColor.cgColor
        layer.shadowRadius = shadowRadius
        layer.shadowOffset = shadowOffset
        layer.shadowOpacity = shadowOpacity
        layer.masksToBounds = false
    }
    
    public func applyCornerRadius(_ cornerRadius: CGFloat = 0, maskedCorners: CACornerMask? = nil) {
        clipsToBounds = true
        layer.cornerRadius = cornerRadius
        if let corners = maskedCorners {
            layer.maskedCorners = corners
        }
    }
    
    public func applyGradientBackground(colors: [UIColor], isHorizontal: Bool) {
        layoutIfNeeded()
        
        // 기존 레이어 제거 (layoutSubviews가 여러번 호출될 때 레이어가 중첩되는 이슈 존재)
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        
        if isHorizontal {
            gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
            gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
            gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        }
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
    
    
    public func removeGradientBackground() {
        layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
    }
    
    public func applyBorder(to side: BorderSide, width: CGFloat, color: UIColor) {
        let border = CALayer()
        border.backgroundColor = color.cgColor
        
        switch side {
        case .top:
            border.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: width)
        case .bottom:
            border.frame = CGRect(x: 0, y: self.frame.height - width, width: self.frame.width, height: width)
        case .left:
            border.frame = CGRect(x: 0, y: 0, width: width, height: self.frame.height)
        case .right:
            border.frame = CGRect(x: self.frame.width - width, y: 0, width: width, height: self.frame.height)
        }
        
        self.layer.addSublayer(border)
    }
    
    public func applyBorder(width: CGFloat,
                            color: UIColor) {
        layer.borderColor = color.cgColor
        layer.borderWidth = width
    }
    
    
    public func applyGradientBorder(width: CGFloat,
                                    colors: [UIColor],
                                    isHorizontal: Bool = true) {
        let existedBorder = gradientBorderLayer()
        let border = existedBorder ?? CAGradientLayer()
        border.frame = bounds
        border.colors = colors.map { return $0.cgColor }
        
        if isHorizontal {
            border.startPoint = CGPoint(x: 0.0, y: 0.5)
            border.endPoint = CGPoint(x: 1.0, y: 0.5)
        } else {
            border.startPoint = CGPoint(x: 0.5, y: 0)
            border.endPoint = CGPoint(x: 0.5, y: 1)
        }
        
        let mask = CAShapeLayer()
        mask.path = UIBezierPath(roundedRect: bounds, cornerRadius: 0).cgPath
        mask.fillColor = UIColor.clear.cgColor
        mask.strokeColor = UIColor.white.cgColor
        mask.lineWidth = width
        
        border.mask = mask
        
        let exists = existedBorder != nil
        if !exists {
            border.name = "GradientBorderLayer"
            layer.addSublayer(border)
        }
    }
    
    
    public func removeGradientBorder() {
        self.gradientBorderLayer()?.removeFromSuperlayer()
    }
    
    
    private func gradientBorderLayer() -> CAGradientLayer? {
        let borderLayers = layer.sublayers?.filter { return $0.name == "GradientBorderLayer" }
        if borderLayers?.count ?? 0 > 1 {
            fatalError()
        }
        return borderLayers?.first as? CAGradientLayer
    }

    enum ShadowDirection {
        case bottom
        case top
        case left
        case right
    }

    func applyShadow(location: ShadowDirection, color: UIColor, opacity: Float, radius: CGFloat) {
        switch location {
        case .bottom:
            applyShadow(offset: CGSize(width: 0, height: 10), color: color, opacity: opacity, radius: radius)
        case .top:
            applyShadow(offset: CGSize(width: 0, height: -10), color: color, opacity: opacity, radius: radius)
        case .left:
            applyShadow(offset: CGSize(width: -10, height: 0), color: color, opacity: opacity, radius: radius)
        case .right:
            applyShadow(offset: CGSize(width: 10, height: 0), color: color, opacity: opacity, radius: radius)
        }
    }

    func applyShadow(offset: CGSize, color: UIColor = .black, opacity: Float = 0.1, radius: CGFloat = 3.0) {
        self.layer.masksToBounds = false
        self.layer.shadowColor = color.cgColor
        self.layer.shadowOffset = offset
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
    }
    
}


extension UIView {
    public enum BorderSide {
        case top, bottom, left, right
    }
}
