//
//  SettingHomeCollectionViewCell.swift
//  AvatarMail
//
//  Created by 최지석 on 9/18/24.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit
import RxGesture

protocol SettingHomeCollectionViewCellDelegate: AnyObject {
    func SettingHomeCollectionViewCellDidTap(item: SettingHomeItem)
}


final class SettingHomeCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "SettingHomeCollectionViewCell"
    
    private var item: SettingHomeItem?
    
    private var disposeBag = DisposeBag()
    
    weak var delegate: SettingHomeCollectionViewCellDelegate?
    
    
    private let containerView = UIView()
    
    private let titleLabel = UILabel()
    
    private let subTitleStackView = UIStackView()
    
    private let subTitleLabel = UILabel().then { $0.isHidden = true }
    
    private let arrowIcon = UIImageView().then { $0.isHidden = true }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.attributedText = nil
        subTitleLabel.attributedText = nil
        subTitleLabel.isHidden = true
        arrowIcon.isHidden = true
    }
    
    
    private func makeUI() {
        contentView.backgroundColor = .white
        
        contentView.addSubViews(
            containerView.addSubViews(
                titleLabel,
                subTitleStackView.addArrangedSubViews(
                    subTitleLabel,
                    arrowIcon
                )
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(64)
        }
        
        titleLabel.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.leading.equalToSuperview().inset(20)
            $0.trailing.equalTo(subTitleStackView.snp.leading).inset(10)
        }
        
        subTitleStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().inset(20)
        }
        
        arrowIcon.image = UIImage(systemName: "chevron.right")
        arrowIcon.contentMode = .scaleAspectFit
        arrowIcon.tintColor = .lightGray
        arrowIcon.snp.makeConstraints {
            $0.size.equalTo(20)
        }
    }
    
    
    func setData(item: SettingHomeItem,
                 title: String,
                 subTitle: String?,
                 showArrowIcon: Bool) {
        self.item = item
        
        titleLabel.attributedText = .makeAttributedString(text: title,
                                                          color: .black,
                                                          font: .content(size: 18, weight: .medium))
        
        if let subTitle {
            subTitleLabel.attributedText = .makeAttributedString(text: subTitle,
                                                                 color: .black,
                                                                 font: .content(size: 18, weight: .medium))
            subTitleLabel.isHidden = false
        }
        
        if showArrowIcon {
            arrowIcon.isHidden = false
        }
        
    }
    
    
    func bindUI() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self, let delegate, let item else { return }
                
                delegate.SettingHomeCollectionViewCellDidTap(item: item)
            }).disposed(by: disposeBag)
    }
}


public enum SettingHomeItemIdentifier: Equatable {
    case appVersion
    case debugMode
}

public struct SettingHomeItem: Equatable {
    var id: SettingHomeItemIdentifier
    var title: String
    var subTitle: String?
    var showArrowIcon: Bool
}
