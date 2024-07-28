//
//  AvatarAgeInputView.swift
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


protocol AvatarAgeInputViewDelegate: AnyObject {
    func avatarAgeInputViewInnerChipDidTap(data: String)
}


final class AvatarAgeInputView: UIView {
    
    weak var delegate: AvatarAgeInputViewDelegate?
    
    var disposeBag = DisposeBag()
    
    
    private let containerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
    private let titleLabel = UILabel().then {
        $0.text = "아바타의 나이대를 선택하세요."
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "아바타의 나이대는"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .lightGray
    }
    
    private let scrollView = UIScrollView().then {
        $0.showsHorizontalScrollIndicator = false
        $0.contentInset = UIEdgeInsets(top: 0, left: 20, bottom: 0, right: 20)
        $0.showsHorizontalScrollIndicator = false
    }
    
    private let contentsView = UIView()
    
    private let stackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    private let chipData = ["10대 미만", "10대", "20대", "30대", "40대", "50대", "60대", "70대 이상"]
    
    
    private var selectedChipData: String?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                // title
                titleLabel,
                
                // scroll-view
                scrollView.addSubViews(
                    contentsView.addSubViews(
                        stackView
                    )
                )
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        scrollView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(titleLabel.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(45)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        contentsView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalToSuperview()
        }
        
        stackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // Chip 생성
        for index in chipData.indices {
            
            let chip = AvatarAgeChip()
            
            chip.setData(titleText: chipData[index],
                         data: chipData[index],
                         state: .unSelected)
            chip.delegate = self
            
            stackView.addArrangedSubview(chip)
        }
    }
    
    
    public func setData(selectedChipData: String?) {
        var chipIndex: Int?
        
        for (index, data) in chipData.enumerated() {
            if data == selectedChipData {
                chipIndex = index
            }
        }
        
        guard let chipIndex,
              let targetChip = stackView.arrangedSubviews[chipIndex] as? AvatarAgeChip
        else { return }
        
        targetChip.setChipState(as: .selected)
    }
}


extension AvatarAgeInputView: AvatarAgeChipDelegate {
    func chipDidTap(chip: AvatarAgeChip) {
        
        switch chip.getChipState() {
        case .selected:
            chip.setChipState(as: .unSelected)
        case .unSelected:
            chip.setChipState(as: .selected)
        }
        
        if let chipViews = stackView.arrangedSubviews as? [AvatarAgeChip] {
            for chipView in chipViews {
                if chipView != chip {
                    chipView.setChipState(as: .unSelected)
                }
            }
        }
        
        guard let chipData = chip.data else { return }
        
        delegate?.avatarAgeInputViewInnerChipDidTap(data: chipData)
    }
}

