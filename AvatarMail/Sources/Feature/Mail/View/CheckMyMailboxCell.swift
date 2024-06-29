//
//  CheckMailboxCell.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import Foundation
import UIKit
import SnapKit
import Then
import RxSwift

protocol CheckMailboxCellDelegate {
    func checkMailboxButtonDidTap()
}

class CheckMailboxCell: UICollectionViewCell {
    
    static let identifier = "CheckMailboxCell"
    
    private var disposeBag = DisposeBag()
    
    var delegate: WriteMailCellDelegate?
    
    // 최상단 뷰
    private let containerView = UIView().then { cell in
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        cell.applyShadow(shadowRadius: 4,
                         shadowOffset: CGSize(width: 0, height: 2),
                         shadowOpacity: 0.5)
    }
  
    // 타이틀 레이블
    private let titleLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "편지함 확인하기",
                                                  color: .black,
                                                  fontSize: 24,
                                                  fontWeight: .bold,
                                                  textAlignment: .left)
    }
    
    // 설명 레이블
    private let descriptionLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "당신 앞으로 전달된 편지들을 확인해보세요.",
                                                  color: UIColor(hex: 0x777777),
                                                  fontSize: 16,
                                                  fontWeight: .regular,
                                                  textAlignment: .left)
    }
    
    // 중앙 이미지 뷰
    private let centerImageView = UIImageView().then {
        $0.image = UIImage(named: "mailbox_img")
        $0.contentMode = .scaleAspectFill
    }

    private let checkMailboxButton = UIButton().then {
        $0.setTitle("편지함 확인하기", for: .normal)
        $0.titleLabel?.attributedText = .makeAttributedString(text: "편지함 확인하기",
                                                              color: .white,
                                                              fontSize: 20,
                                                              fontWeight: .bold)
        $0.applyCornerRadius(20)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
            
        checkMailboxButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                            UIColor(hex: 0x4C5BDF)],
                                                   isHorizontal: true)
    }
    
    private func makeUI() {
        // 셀 레이아웃 설정
        contentView.addSubViews(
            containerView.addSubViews(
                titleLabel,
                descriptionLabel,
                centerImageView,
                
                checkMailboxButton
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.leading.top.equalTo(30)
        }
        
        descriptionLabel.snp.makeConstraints {
            $0.leading.equalTo(30)
            $0.top.equalTo(titleLabel.snp.bottom).offset(8)
        }
        
        centerImageView.snp.makeConstraints {
            $0.top.equalTo(descriptionLabel.snp.bottom).offset(36)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(228)
            $0.height.equalTo(327)
        }
        
        checkMailboxButton.snp.makeConstraints {
            $0.top.equalTo(centerImageView.snp.bottom).offset(36)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
    }
    
    // MARK: Reset for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    private func bindUI() {
        checkMailboxButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.writeMailButtonDidTap()
            }.disposed(by: disposeBag)
    }
}

