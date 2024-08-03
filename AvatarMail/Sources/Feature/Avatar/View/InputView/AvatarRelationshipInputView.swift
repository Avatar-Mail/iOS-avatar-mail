//
//  AvatarRelationshipInputView.swift
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


protocol AvatarRelationshipInputViewDelegate: AnyObject {
    // avatar
    func avatarRoleInputTextFieldDidTap()
    func avatarRoleInputTextDidChange(text: String)
    func avatarRoleClearButtonDidTap()
    // user
    func userRoleInputTextFieldDidTap()
    func userRoleInputTextDidChange(text: String)
    func userRoleClearButtonDidTap()
}


final class AvatarRelationshipInputView: UIView, ActivatableInputView {
    
    weak var delegate: AvatarRelationshipInputViewDelegate?
    
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
        $0.text = "아바타와 나와의 관계를 입력하세요."
        $0.font = UIFont.systemFont(ofSize: 18, weight: .bold)
    }
    
    private let subTitleLabel = UILabel().then {
        $0.text = "예) 아바타 - 연예인, 나 - 팬"
        $0.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        $0.textColor = .lightGray
    }
    
    private let avatarRoleTitleLabel = UILabel().then {
        $0.text = "아바타 :"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private let avatarRoleInputTextFieldContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private let avatarRoleInputTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.placeholder = "아바타의 역할"
    }
    
    private let avatarRoleClearButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("지우기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        $0.setTitleColor(UIColor(hex: 0x6878F6), for: .normal)
        $0.isHidden = true
    }
    
    private let userRoleTitleLabel = UILabel().then {
        $0.text = "나 :"
        $0.textColor = .lightGray
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .right
    }
    
    private let userRoleInputTextFieldContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
    }
    
    private let userRoleInputTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.placeholder = "나의 역할"
    }
    
    private let userRoleClearButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("지우기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
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
    
    
    public func setData(avatarRole: String?,
                        userRole: String?) {
        avatarRoleInputTextField.text = avatarRole
        userRoleInputTextField.text = userRole
    }
    
    
    public func activateInputView(_ shouldActivate: Bool) {
        activateAvatarRoleInputView(shouldActivate)
        activateUserRoleInputView(shouldActivate)
    }
    
    
    private func activateAvatarRoleInputView(_ shouldActivate: Bool) {
        if shouldActivate {
            avatarRoleTitleLabel.textColor = .black
            avatarRoleInputTextFieldContainerView.layer.borderColor = UIColor(hex: 0x6878F6).cgColor
        } else {
            avatarRoleTitleLabel.textColor = .lightGray
            avatarRoleInputTextFieldContainerView.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        }
    }
    
    
    private func activateUserRoleInputView(_ shouldActivate: Bool) {
        if shouldActivate {
            userRoleTitleLabel.textColor = .black
            userRoleInputTextFieldContainerView.layer.borderColor = UIColor(hex: 0x6878F6).cgColor
        } else {
            userRoleTitleLabel.textColor = .lightGray
            userRoleInputTextFieldContainerView.layer.borderColor = UIColor(hex: 0xCACACA).cgColor
        }
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                // title
                titleLabel,
                subTitleLabel,
                
                // avatar role input text field
                avatarRoleTitleLabel,
                avatarRoleInputTextFieldContainerView.addSubViews(
                    avatarRoleInputTextField
                ),
                avatarRoleClearButton,
                
                // user role input text field
                userRoleTitleLabel,
                userRoleInputTextFieldContainerView.addSubViews(
                    userRoleInputTextField
                ),
                userRoleClearButton
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.leading.equalToSuperview().inset(20)
        }
        
        subTitleLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalToSuperview().inset(25)
        }
        
        avatarRoleTitleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(45)
            $0.width.equalTo(70)
        }
        
        avatarRoleInputTextFieldContainerView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
            $0.leading.equalTo(avatarRoleTitleLabel.snp.trailing).inset(-10)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        avatarRoleInputTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
        }
        
        avatarRoleClearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(avatarRoleInputTextFieldContainerView)
            $0.width.equalTo(45)
        }
        
        userRoleTitleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(avatarRoleTitleLabel.snp.bottom).offset(15)
            $0.leading.equalToSuperview().inset(20)
            $0.height.equalTo(45)
            $0.width.equalTo(70)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        userRoleInputTextFieldContainerView.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(avatarRoleInputTextFieldContainerView.snp.bottom).offset(15)
            $0.leading.equalTo(userRoleTitleLabel.snp.trailing).inset(-10)
            $0.trailing.equalToSuperview().inset(20)
            $0.height.equalTo(45)
        }
        
        userRoleInputTextField.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(15)
            $0.top.bottom.equalToSuperview()
            $0.trailing.equalToSuperview().inset(15)
        }
        
        userRoleClearButton.snp.makeConstraints {
            $0.trailing.equalToSuperview().inset(15)
            $0.centerY.equalTo(userRoleInputTextFieldContainerView)
            $0.width.equalTo(45)
        }
    }
    
    
    private func bindUI() {
        avatarRoleClearButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.avatarRoleInputTextField.text = ""
                
                self.delegate?.avatarRoleInputTextDidChange(text: "")
                self.delegate?.avatarRoleClearButtonDidTap()
                
                self.showAvatarRoleClearButton(false)
            })
            .disposed(by: disposeBag)
        
        
        avatarRoleInputTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                self.delegate?.avatarRoleInputTextFieldDidTap()
            })
            .disposed(by: disposeBag)
        
        
        avatarRoleInputTextField.rx.controlEvent([.editingChanged])
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                let text = self.avatarRoleInputTextField.text ?? ""
                self.delegate?.avatarRoleInputTextDidChange(text: text)
                
                if !text.isEmpty {
                    self.showAvatarRoleClearButton(true)
                } else {
                    self.showAvatarRoleClearButton(false)
                }
            }).disposed(by: disposeBag)
        
        
        avatarRoleInputTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.avatarRoleInputTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
        
        userRoleClearButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.userRoleInputTextField.text = ""
                
                self.delegate?.userRoleInputTextDidChange(text: "")
                self.delegate?.userRoleClearButtonDidTap()
                
                self.showUserRoleClearButton(false)
            })
            .disposed(by: disposeBag)
        
        
        userRoleInputTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                self.delegate?.userRoleInputTextFieldDidTap()
            })
            .disposed(by: disposeBag)
        
        
        userRoleInputTextField.rx.controlEvent([.editingChanged])
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                let text = self.userRoleInputTextField.text ?? ""
                self.delegate?.userRoleInputTextDidChange(text: text)
                
                if !text.isEmpty {
                    self.showUserRoleClearButton(true)
                } else {
                    self.showUserRoleClearButton(false)
                }
            }).disposed(by: disposeBag)
        
        
        userRoleInputTextField.rx.controlEvent(.editingDidEndOnExit)
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                
                self.userRoleInputTextField.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }
    
    
    private func showAvatarRoleClearButton(_ shouldShowClearButton: Bool) {
        if shouldShowClearButton {
            avatarRoleClearButton.isHidden = false
             
            avatarRoleInputTextFieldContainerView.snp.remakeConstraints {
                $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
                $0.leading.equalTo(avatarRoleTitleLabel.snp.trailing).inset(-10)
                $0.trailing.equalTo(avatarRoleClearButton.snp.leading).inset(-5)
                $0.height.equalTo(45)
            }
        } else {
            avatarRoleClearButton.isHidden = true
            
            avatarRoleInputTextFieldContainerView.snp.remakeConstraints {
                $0.top.greaterThanOrEqualTo(subTitleLabel.snp.bottom).offset(15)
                $0.leading.equalTo(avatarRoleTitleLabel.snp.trailing).inset(-10)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
            }
        }
        
        // 애니메이션 적용
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
    
    
    private func showUserRoleClearButton(_ shouldShowClearButton: Bool) {
        if shouldShowClearButton {
            userRoleClearButton.isHidden = false
             
            userRoleInputTextFieldContainerView.snp.remakeConstraints {
                $0.top.greaterThanOrEqualTo(avatarRoleInputTextFieldContainerView.snp.bottom).offset(15)
                $0.leading.equalTo(userRoleTitleLabel.snp.trailing).inset(-10)
                $0.trailing.equalTo(userRoleClearButton.snp.leading).inset(-5)
                $0.height.equalTo(45)
            }
        } else {
            userRoleClearButton.isHidden = true
            
            userRoleInputTextFieldContainerView.snp.remakeConstraints {
                $0.top.greaterThanOrEqualTo(avatarRoleInputTextFieldContainerView.snp.bottom).offset(15)
                $0.leading.equalTo(userRoleTitleLabel.snp.trailing).inset(-10)
                $0.trailing.equalToSuperview().inset(20)
                $0.height.equalTo(45)
            }
        }
        
        // 애니메이션 적용
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
}




