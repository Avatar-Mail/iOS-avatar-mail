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


protocol AvatarPlaceholderViewDelegate: AnyObject {
    func createButtonDidTap()
}


final class AvatarPlaceholderView: UIView {
    
    weak var delegate: AvatarPlaceholderViewDelegate?
    
    var disposeBag = DisposeBag()
    
    
    private let avatarImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFit
        $0.image = UIImage(named: "avatar_img")

        // 이미지 뷰의 프레임을 화면의 절반으로 설정
        $0.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width / 2, height: 0)
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "편지를 쓸 아바타를 생성하거나 수정해보세요."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .light)
        $0.textColor = .lightGray
    }
    
    private let createAvatarButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xF8554A)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("새로운 아바타 생성하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func makeUI() {
        addSubViews(
            avatarImageView,
            titleLabel,
            createAvatarButton
        )
        
        avatarImageView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-60)
            $0.size.equalTo(UIScreen.main.bounds.height / 3)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(avatarImageView.snp.bottom).offset(-5)
            $0.centerX.equalToSuperview()
        }
        
        createAvatarButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(273)
            $0.bottom.equalToSuperview().offset(-10)
            $0.centerX.equalToSuperview()
        }
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


