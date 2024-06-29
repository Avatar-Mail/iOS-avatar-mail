//
//  SendMailCell.swift
//  AvatarMail
//
//  Created by 최지석 on 6/29/24.
//

import Foundation
import UIKit
import SnapKit
import Then
import RxSwift

protocol WriteMailCellDelegate {
    func writeMailButtonDidTap()
}

class WriteMailCell: UICollectionViewCell {
    
    static let identifier = "WriteMailCell"
    
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
        $0.attributedText = .makeAttributedString(text: "메일 작성하기",
                                                  color: .black,
                                                  fontSize: 24,
                                                  fontWeight: .bold,
                                                  textAlignment: .left)
    }
    
    // 설명 레이블
    private let descriptionLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "당신이 원하는 아바타에게 메일을 작성해보세요.",
                                                  color: UIColor(hex: 0x777777),
                                                  fontSize: 16,
                                                  fontWeight: .regular,
                                                  textAlignment: .left)
    }
    
    // 중앙 이미지 뷰
    private let centerImageView = UIImageView().then {
        $0.image = UIImage(named: "letter_img")
        $0.contentMode = .scaleAspectFill
    }
    
    // 편지 내용 스택 뷰
    private let mailContentsStackView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .leading
        $0.spacing = 6
    }
    
    private let mailContentsLabel1 = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "안녕 친구야,",
                                                  color: UIColor(hex: 0xA5A5A5, alpha: 1),
                                                  fontSize: 14,
                                                  fontWeight: .regular,
                                                  lineBreakMode: .byTruncatingTail)
        $0.numberOfLines = 1
    }
    
    private let mailContentsLabel2 = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "우리 못 본 지 참 오래됐네",
                                                  color: UIColor(hex: 0xA5A5A5, alpha: 0.6),
                                                  fontSize: 14,
                                                  fontWeight: .regular,
                                                  lineBreakMode: .byTruncatingTail)
        $0.numberOfLines = 1
    }
    
    private let mailContentsLabel3 = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "널 봤던 게 엊그제 같은데, 벌써 일 년이나 지났구나",
                                                  color: UIColor(hex: 0xA5A5A5, alpha: 0.3),
                                                  fontSize: 14,
                                                  fontWeight: .regular,
                                                  lineBreakMode: .byTruncatingTail)
        $0.numberOfLines = 1
    }
    
    private let writeMailButton = UIButton().then {
        $0.setTitle("새로운 메일 작성하기", for: .normal)
        $0.titleLabel?.attributedText = .makeAttributedString(text: "새로운 메일 작성하기",
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
            
        writeMailButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                         UIColor(hex: 0x4C5BDF)])
    }
    
    private func makeUI() {
        // 셀 레이아웃 설정
        contentView.addSubViews(
            containerView.addSubViews(
                titleLabel,
                descriptionLabel,
                centerImageView,
                
                mailContentsStackView.addArrangedSubViews(
                    mailContentsLabel1,
                    mailContentsLabel2,
                    mailContentsLabel3
                ),
                
                writeMailButton
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
            $0.width.equalTo(251)
            $0.height.equalTo(154)
        }
        
        mailContentsStackView.snp.makeConstraints {
            $0.top.equalTo(centerImageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(44)
        }
        
        writeMailButton.snp.makeConstraints {
            $0.top.equalTo(mailContentsStackView.snp.bottom).offset(36)
            $0.leading.trailing.bottom.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
    }
    
    // MARK: Reset for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    private func bindUI() {
        writeMailButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                delegate?.writeMailButtonDidTap()
            }.disposed(by: disposeBag)
    }
}
