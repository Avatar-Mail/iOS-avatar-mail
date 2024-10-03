//
//  TopNavigationBottomView.swift
//  AvatarMail
//
//  Created by 최지석 on 10/3/24.
//

import UIKit
import Foundation
import RxSwift
import RxCocoa
import Then


class TopNavigationBottomView: UIView {
    
    var disposeBag = DisposeBag()

    private let containerView = UIView().then {
        $0.backgroundColor = .darkGray
        $0.applyCornerRadius(8)
        $0.applyShadow(offset: CGSize(width: 0, height: 4))
    }
    
    private let descriptionLabel = UILabel().then {
        $0.numberOfLines = 0
    }

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func makeUI() {
        self.isHidden = true
        
        addSubViews(
            containerView.addSubViews(
                descriptionLabel
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.verticalEdges.equalToSuperview().inset(5)
            $0.horizontalEdges.equalToSuperview().inset(10)
        }
    }
    
    
    public func showTopNavigationBottomView(withText text: String) {
        descriptionLabel.attributedText = .makeAttributedString(text: text,
                                                                color: .white,
                                                                font: .content(size: 14, weight: .medium))
        drawEdgeTriangle()
        
        isHidden = false
        
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.layer.opacity = 1
        }, completion: { [weak self] isSuccess in
            guard let self else { return }
            
            if isSuccess {
                DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
                    guard let self else { return }
                    // 3초 뒤 숨김 처리
                    hideTopNavigationBottomView()
                }
            }
        })
    }
    
    
    public func hideTopNavigationBottomView() {
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            guard let self else { return }
            self.layer.opacity = 0
        }, completion: { [weak self] _ in
            guard let self else { return }
            self.isHidden = true
        })
    }
    
    
    private func drawEdgeTriangle() {
        layoutIfNeeded()
        
        // 기존의 삼각형 레이어 제거
        containerView.layer.sublayers?.forEach { layer in
            if layer.name == "edgeTriangleLayer" {
                layer.removeFromSuperlayer()
            }
        }
        
        // 새로운 삼각형 레이어 생성
        let triangleLayer = CAShapeLayer()
        triangleLayer.name = "edgeTriangleLayer" // 레이어에 고유한 이름 지정
        triangleLayer.fillColor = UIColor.darkGray.cgColor
        
        let trianglePath = UIBezierPath()
        let triangleWidth: CGFloat = 16
        let triangleHeight: CGFloat = 8
        let marginRight: CGFloat = 10
        
        // 삼각형의 시작점 (우측 상단에서 marginRight 만큼 떨어진 곳에서 시작)
        let startX = self.frame.width - marginRight - triangleWidth
        let startY = 0.0
        
        trianglePath.move(to: CGPoint(x: startX, y: startY))
        trianglePath.addLine(to: CGPoint(x: startX + triangleWidth / 2, y: startY - triangleHeight))
        trianglePath.addLine(to: CGPoint(x: startX + triangleWidth, y: startY))
        trianglePath.close()
        
        triangleLayer.path = trianglePath.cgPath
        
        containerView.layer.addSublayer(triangleLayer)
    }
}
