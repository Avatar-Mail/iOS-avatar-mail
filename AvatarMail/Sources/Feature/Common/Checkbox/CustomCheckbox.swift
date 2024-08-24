//
//  CustomCheckbox.swift
//  AvatarMail
//
//  Created by 최지석 on 8/23/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa


protocol CustomCheckboxDelegate: AnyObject {
    func checkboxDidTap(checkBox: CustomCheckbox)
}

class CustomCheckbox: UIView {
    
    var disposeBag = DisposeBag()
    
    weak var delegate: CustomCheckboxDelegate?

    private let containerStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 6
        $0.alignment = .center
    }
    
    private let checkboxIconButton = UIButton()
    
    private let checkboxLabel = UILabel()
    
    var selectedIcon: String
    var unSelectedIcon: String

    /// 이미지 직접 지정 + init
    init(selectedIcon: String,
         unSelectedIcon: String) {
        
        self.selectedIcon = selectedIcon
        self.unSelectedIcon = unSelectedIcon
        
        super.init(frame: .zero)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    private func makeUI() {
        addSubview(containerStackView)
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        containerStackView.addArrangedSubview(checkboxIconButton)
        checkboxIconButton.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        checkboxIconButton.setImage(UIImage(named: unSelectedIcon), for: .normal)
        
        containerStackView.addArrangedSubview(checkboxLabel)
    }
    
    public func setTitle(with title: String) {
        checkboxLabel.attributedText = .makeAttributedString(text: title,
                                                             color: UIColor(hex: 0x7B7B7B),
                                                             font: .content(size: 14, weight: .medium))
    }
    
    public func setIsChecked(_ isChecked: Bool) {
        if isChecked {
            checkboxIconButton.setImage(UIImage(named: selectedIcon), for: .normal)
        } else {
            checkboxIconButton.setImage(UIImage(named: unSelectedIcon), for: .normal)
        }
    }
    
    private func bindUI() {
        checkboxIconButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.checkboxDidTap(checkBox: self)
            })
            .disposed(by: disposeBag)
    }
}
