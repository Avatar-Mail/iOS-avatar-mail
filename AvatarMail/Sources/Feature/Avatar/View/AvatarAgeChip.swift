//
//  AvatarAgeChip.swift
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
import RxGesture



protocol AvatarAgeChipDelegate: AnyObject {
    func chipDidTap(chip: AvatarAgeChip)
}


final class AvatarAgeChip: UIView {
    
    weak var delegate: AvatarAgeChipDelegate?
    
    var disposeBag = DisposeBag()
    
    var data: String?
    
    
    private let containerView = UIView().then {
        $0.layer.cornerRadius = 20
        $0.clipsToBounds = true
        
        $0.layer.borderWidth = 1
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 1)
        $0.layer.shadowOpacity = 0.2
        $0.layer.shadowRadius = 2
        $0.layer.masksToBounds = false
    }
    
    private let titleLabel = UILabel().then {
        $0.font = UIFont.content(size: 16, weight: .medium)
        $0.textAlignment = .center
    }
    
    private var state: AvatarAgeChipState = .unSelected
    
    
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
            containerView.addSubViews(
                // title
                titleLabel
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(40)
        }
        
        titleLabel.snp.makeConstraints {
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.verticalEdges.equalToSuperview().inset(5)
        }
    }
    
    
    private func bindUI() {
        containerView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self, let delegate else { return }
                
                delegate.chipDidTap(chip: self)
                
            }).disposed(by: disposeBag)
    }
    
    
    public func setData(titleText: String,
                        data: String,
                        state: AvatarAgeChipState) {
        
        titleLabel.text = titleText
        
        self.state = state
        self.data = data
        
        updateUI(withState: state)
    }
    
    
    public func getChipState() -> AvatarAgeChipState {
        return state
    }
    
    
    public func setChipState(as state: AvatarAgeChipState) {
        self.state = state
        updateUI(withState: state)
    }
    
    
    public func updateUI(withState state: AvatarAgeChipState) {
        containerView.backgroundColor = state.chipBackgroundColor()
        containerView.layer.borderColor = state.chipBorderColor().cgColor
        titleLabel.textColor = state.chipTextColor()
    }
}


enum AvatarAgeChipState {
    case selected
    case unSelected
    
    func chipBackgroundColor() -> UIColor {
        switch self {
        case .selected: return UIColor(hex: 0x6878F6)
        case .unSelected: return .white
        }
    }
    
    func chipTextColor() -> UIColor {
        switch self {
        case .selected: return .white
        case .unSelected: return UIColor(hex: 0xCACACA)
        }
    }
    
    func chipBorderColor() -> UIColor {
        switch self {
        case .selected: return UIColor(hex: 0x6878F6)
        case .unSelected: return UIColor(hex: 0xCACACA)
        }
    }
}

