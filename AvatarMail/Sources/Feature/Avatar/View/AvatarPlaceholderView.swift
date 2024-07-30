//
//  AvatarPlaceholderView.swift
//  AvatarMail
//
//  Created by 최지석 on 6/16/24.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit
import Lottie


protocol AvatarPlaceholderViewDelegate: AnyObject {
    func createButtonDidTap()
}


final class AvatarPlaceholderView: UIView {
    
    weak var delegate: AvatarPlaceholderViewDelegate?
    
    var disposeBag = DisposeBag()
    
    let avatarAnimationView = LottieAnimationView(name: "avatar_setting_main").then {
        $0.loopMode = .loop
        $0.contentMode = .scaleAspectFit
    }
    
    private let titleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "당신만의 아바타를 만들어보세요",
                                                  color: UIColor(hex:0x535353),
                                                  fontSize: 20,
                                                  fontWeight: .bold,
                                                  lineBreakMode: .byTruncatingTail)
        $0.textAlignment = .center
    }
    
    private let subtitleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "이름, 성격, 나이, 말투, 그리고 목소리까지 설정해보세요.",
                                                  color: UIColor(hex:0x9A9A9A),
                                                  fontSize: 14,
                                                  fontWeight: .light,
                                                  lineBreakMode: .byTruncatingTail)
        $0.textAlignment = .center
    }
    
    private let createAvatarButton = UIButton().then {
        $0.setButtonTitle(title: "새로운 아바타 생성하기",
                          color: .white,
                          fontSize: 20,
                          fontWeight: .bold)
        $0.applyCornerRadius(20)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        createAvatarButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                            UIColor(hex: 0x4C5BDF)],
                                                   isHorizontal: true)
    }
    
    
    private func makeUI() {
        addSubViews(
            avatarAnimationView,
            titleLabel,
            subtitleLabel,
            createAvatarButton
        )
        
        avatarAnimationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-100)
            $0.size.equalTo(UIScreen.main.bounds.height / 3)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(avatarAnimationView.snp.bottom).offset(5)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        subtitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        createAvatarButton.snp.makeConstraints {
            $0.height.equalTo(72)
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.bottom.equalToSuperview().offset(-30)
            $0.centerX.equalToSuperview()
        }
        
        avatarAnimationView.play()
    }
    
    
    private func bindUI() {
        createAvatarButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.createButtonDidTap()
            })
            .disposed(by: disposeBag)
    }
}


