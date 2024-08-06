//
//  RepliedMailCell.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import Foundation
import UIKit
import SnapKit
import Then
import RxSwift
import RxGesture

protocol RepliedMailCellDelegate {
    func repliedMailCellDidTap(mail: Mail)
}

class RepliedMailCell: UICollectionViewCell {
    
    static let identifier = "RepliedMailCell"
    
    private var disposeBag = DisposeBag()
    
    var delegate: RepliedMailCellDelegate?
    
    // 최상단 뷰
    private let containerView = UIView().then { cell in
        cell.backgroundColor = .white
        cell.layer.cornerRadius = 10
        cell.clipsToBounds = true
        
        cell.applyShadow(shadowRadius: 2,
                         shadowOffset: CGSize(width: 0, height: 2),
                         shadowOpacity: 0.5)
        cell.applyBorder(width: 1, color: UIColor(hex:0xEDEDED))
    }
  
    // 수신인 레이블
    private let recipientLabel = UILabel().then {
        $0.text = "Hello world"
        $0.font = UIFont.content(size: 14, weight: .semibold)
        $0.textColor = UIColor(hex:0x777777)
    }
    
    // 날짜 레이블
    private let dateLabel = UILabel().then {
        $0.font = UIFont.content(size: 12, weight: .regular)
        $0.textColor = UIColor(hex:0x8F8F8F)
    }
    
    // 발신인 레이블
    private let senderLabel = UILabel().then {
        $0.font = UIFont.content(size: 14, weight: .semibold)
        $0.textColor = UIColor(hex:0x777777)
    }

    
    var mail: Mail?
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    public func setData(mail: Mail) {
        self.mail = mail
        
        recipientLabel.text = mail.recipientName
        
        let dateString = CustomFormatter.shared.getMailDateString(from: mail.date)
        dateLabel.text = dateString
        
        senderLabel.text = mail.senderName
    }
    
    
    private func makeUI() {
        // 셀 레이아웃 설정
        contentView.addSubViews(
            containerView.addSubViews(
                recipientLabel,
                dateLabel,
                senderLabel
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        recipientLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.top.equalToSuperview().inset(20)
        }
        
        dateLabel.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        senderLabel.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
    }
    
    // MARK: Reset for Reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        recipientLabel.text = nil
        dateLabel.text = nil
        senderLabel.text = nil
        
        mail = nil
    }
    
    
    private func bindUI() {
        containerView.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self,
                      let mail else { return }

                delegate?.repliedMailCellDidTap(mail: mail)
            }.disposed(by: disposeBag)
    }
}


