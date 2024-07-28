//
//  AvatarNameInputView.swift
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


protocol AvatarNameInputViewDelegate: AnyObject {
    func nameInputTextFieldDidTap()
    func nameInputTextDidChange(text: String)
    func nameClearButtonDidTap()
}


class AvatarNameInputView: UIView, ActivatableInputView {
    
    weak var delegate: AvatarNameInputViewDelegate?
    
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
        $0.text = "아바타의 이름을 입력하세요."
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "아바타의 이름은 최대 13자까지 가능합니다."
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .lightGray
    }
    
    private let textFieldContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private let inputTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.placeholder = "아바타 이름"
    }
    
    private let clearButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("지우기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(UIColor(hex: 0xF8554A), for: .normal)
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
    
    
    public func setData(name: String?) {
        inputTextField.text = name
    }
    
    
    public func activateInputView(_ shouldActivate: Bool) {
        if shouldActivate {
            textFieldContainerView.layer.borderColor = UIColor(hex: 0xF8554A).cgColor
        } else {
            textFieldContainerView.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        }
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                // title
                titleLabel,
                subTitleLabel,
                
                // text field
                textFieldContainerView.addSubViews(
                    inputTextField
                ),
                
                clearButton
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.height.equalTo(144)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(25)
        }
        
        textFieldContainerView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
            $0.leading.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(45)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        inputTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
        }
        
        clearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(textFieldContainerView)
            $0.width.equalTo(45)
        }
    }
    
    
    private func bindUI() {
        clearButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.inputTextField.text = ""
                
                self.delegate?.nameInputTextDidChange(text: "")
                self.delegate?.nameClearButtonDidTap()
                
                self.showClearButton(false)
            })
            .disposed(by: disposeBag)
        
        
        inputTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                self.delegate?.nameInputTextFieldDidTap()
            })
            .disposed(by: disposeBag)
        
        
        inputTextField.rx.controlEvent([.editingChanged])
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                let text = self.inputTextField.text ?? ""
                self.delegate?.nameInputTextDidChange(text: text)
                
                if !text.isEmpty {
                    self.showClearButton(true)
                } else {
                    self.showClearButton(false)
                }
            }).disposed(by: disposeBag)
        
        
        inputTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.inputTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func showClearButton(_ shouldShowClearButton: Bool) {
        if shouldShowClearButton {
            clearButton.isHidden = false
             
            textFieldContainerView.snp.remakeConstraints {
                $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
                $0.leading.equalToSuperview().inset(20)
                $0.trailing.equalTo(clearButton.snp.leading).offset(-5)
                $0.height.equalTo(45)
                $0.bottom.equalToSuperview().inset(20)
            }
        } else {
            clearButton.isHidden = true
            
            textFieldContainerView.snp.remakeConstraints {
                $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
                $0.leading.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
                $0.bottom.equalToSuperview().inset(20)
            }
        }
        
        // 애니메이션 적용
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
}




