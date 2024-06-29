//
//  TooltipView.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import UIKit

class TooltipView: UIView {
    
    private let containerView = UIView().then {
        $0.applyCornerRadius(20)
    }
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 1
    }
    
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        containerView.applyGradientBackground(colors: [UIColor(hex: 0x5B75FF), UIColor(hex: 0x403DD2)],
                                              isHorizontal: false)
    }
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        
        drawTooltipCorner()
    }
    
    
    public func setData(title: String?,
                        description: String?) {
        if let title {
            titleLabel.attributedText = .makeAttributedString(text: title,
                                                              color: .white,
                                                              fontSize: 20,
                                                              fontWeight: .bold)
        }
        if let description {
            descriptionLabel.attributedText = .makeAttributedString(text: "당신이 원하는 아바타에게 메일을 작성해보세요.",
                                                                    color: .white,
                                                                    fontSize: 14,
                                                                    lineBreakMode: .byCharWrapping)
        }
    }
    
    
    private func makeUI() {
        addSubview(
            containerView.addSubViews(
                titleLabel,
                descriptionLabel
            )
        )

        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(24)
            $0.leading.equalToSuperview().inset(24)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(6)
            $0.leading.equalToSuperview().inset(24)
            $0.bottom.equalToSuperview().inset(24)
        }
    }
    
    
    private func drawTooltipCorner() {
        let cornerPath = UIBezierPath()
        cornerPath.move(to: CGPoint(x: 10, y: bounds.height - 3))
        cornerPath.addLine(to: CGPoint(x: 32, y: bounds.height + 14))
        cornerPath.addLine(to: CGPoint(x: 54, y: bounds.height - 3))
        cornerPath.close()
        
        let cornerLayer = CAShapeLayer()
        cornerLayer.path = cornerPath.cgPath
        cornerLayer.fillColor = UIColor(hex: 0x403DD2).cgColor
        
        layer.addSublayer(cornerLayer)
    }
}
