//
//  AvatarCharacteristicInputView.swift
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

protocol AvatarCharacteristicInputViewDelegate: AnyObject {
    func characteristicInputTextViewDidTap()
    func characteristicInputTextDidChange(text: String)
    func characteristicClearButtonDidTap()
}

final class AvatarCharacteristicInputView: UIView, ActivatableInputView {
    
    weak var delegate: AvatarCharacteristicInputViewDelegate?
    
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
        $0.text = "아바타의 성격을 입력하세요."
        $0.font = UIFont.content(size: 18, weight: .bold)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "e.g. 쾌활하고 밝은 성격이다."
        $0.font = UIFont.content(size: 14, weight: .regular)
        $0.textColor = .lightGray
    }
    
    private let textViewContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private let inputTextView = UITextView().then {
        $0.font = UIFont.content(size: 18, weight: .regular)
        $0.isScrollEnabled = false  // 스크롤을 비활성화하여 높이 자동 조정을 가능하게 함
    }
    
    private let clearButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("모두 지우기", for: .normal)
        $0.titleLabel?.font = UIFont.content(size: 16, weight: .medium)
        $0.setTitleColor(UIColor(hex: 0x6878F6), for: .normal)
        $0.isHidden = true
    }
    

    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    
    public func setData(characteristic: String?) {
        inputTextView.text = characteristic
    }
    
    
    public func activateInputView(_ shouldActivate: Bool) {
        if shouldActivate {
            textViewContainerView.layer.borderColor = UIColor(hex: 0x6878F6).cgColor
        } else {
            textViewContainerView.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        }
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                // title
                titleLabel,
                clearButton,
                
                subTitleLabel,
                
                // text field
                textViewContainerView.addSubViews(
                    inputTextView
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
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(20)
            $0.centerY.equalTo(titleLabel)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(25)
        }
        
        textViewContainerView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        inputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(10)
            $0.height.greaterThanOrEqualTo(60)
        }
    }
    
    
    private func bindUI() {
        clearButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.inputTextView.text = ""
                
                self.delegate?.characteristicInputTextDidChange(text: "")
                self.delegate?.characteristicClearButtonDidTap()
                
                self.showClearButton(false)
            })
            .disposed(by: disposeBag)
        
        inputTextView.rx.didBeginEditing
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.characteristicInputTextViewDidTap()
            })
            .disposed(by: disposeBag)
        
        inputTextView.rx.didChange
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                let text = self.inputTextView.text ?? ""
                
                self.delegate?.characteristicInputTextDidChange(text: text)
                
                if !text.isEmpty {
                    self.showClearButton(true)
                } else {
                    self.showClearButton(false)
                }
            }).disposed(by: disposeBag)
        
        inputTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.inputTextView.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func showClearButton(_ shouldShowClearButton: Bool) {
        clearButton.isHidden = !shouldShowClearButton
        UIView.animate(withDuration: 0.2) { [weak self] in
            self?.layoutIfNeeded()
        }
    }
}

