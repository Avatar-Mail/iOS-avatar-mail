//
//  SenderNameInputTextfield.swift
//  AvatarMail
//
//  Created by 최지석 on 7/7/24.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit

protocol SenderNameInputTextfieldDelegate: AnyObject {
    func senderNameInputTextfieldDidBeginEditing()
    func senderNameInputTextfieldDidEndEditing()
    func senderNameInputTextfieldDidEndEditingOnExit()
    func senderNameInputTextDidChange(text: String)
    func senderNameInputTextfieldCancelButtonDidTap()
    func senderNameInputTextfieldClearButtonDidTap()
}

final class SenderNameInputTextfield: UIView {
    
    weak var delegate: SenderNameInputTextfieldDelegate?
    
    var disposeBag = DisposeBag()
    
    let searchTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
        $0.clipsToBounds = true
        
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 10))
        $0.leftView = paddingView
        $0.leftViewMode = .always
    }
    
    let cancelButton = UIButton().then {
        $0.backgroundColor = .clear
        $0.setTitle("취소", for: .normal)
        $0.setTitleColor(.lightGray, for: .normal)
        $0.isHidden = true
    }
    
    let clearButton = UIButton().then {
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .bold)
        let icon = UIImage(systemName: "x.circle.fill", withConfiguration: boldConfiguration)
        $0.setImage(icon, for: .normal)
        $0.tintColor = .lightGray
        $0.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
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
    
    
    public func showKeyboard(_ shouldShowKeyboard: Bool) {
        if shouldShowKeyboard {
            searchTextField.becomeFirstResponder()
        } else {
            searchTextField.resignFirstResponder()
        }
    }
    
    
    private func makeUI() {
        addSubViews(
            searchTextField,
            cancelButton,
            clearButton
        )
        
        // textfield
        searchTextField.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // cancel button
        cancelButton.snp.makeConstraints {
            $0.width.equalTo(40)
            $0.height.equalTo(43)
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // clear button
        clearButton.snp.makeConstraints {
            $0.height.equalTo(43)
            $0.width.equalTo(21)
            $0.centerY.equalToSuperview()
            $0.trailing.equalTo(searchTextField.snp.trailing).inset(10)
        }
    }
    
    
    private func bindUI() {
        searchTextField.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] text in
                guard let self = self else { return }
                self.delegate?.senderNameInputTextDidChange(text: text)
            }.disposed(by: disposeBag)
        
        
        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.senderNameInputTextfieldCancelButtonDidTap()
            })
            .disposed(by: disposeBag)
        
        
        clearButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.senderNameInputTextfieldClearButtonDidTap()
                self.showClearButton(false)
            })
            .disposed(by: disposeBag)
        
        
        searchTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.senderNameInputTextfieldDidBeginEditing()
            })
            .disposed(by: disposeBag)
        
        
        searchTextField.rx.controlEvent([.editingDidEnd])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.senderNameInputTextfieldDidEndEditing()
                
            })
            .disposed(by: disposeBag)
        
        searchTextField.rx.controlEvent([.editingDidEndOnExit])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.senderNameInputTextfieldDidEndEditingOnExit()
            })
            .disposed(by: disposeBag)
    }
    
    
    public func setInputText(text: String) {
        searchTextField.text = text
    }
    
    
    public func getInputText() -> String? {
        return searchTextField.text
    }
    
    public func showCancelButton(_ shouldShowCancelButton: Bool) {
        if shouldShowCancelButton {
            cancelButton.isHidden = false
                
            searchTextField.snp.remakeConstraints {
                $0.top.leading.bottom.equalToSuperview()
                $0.trailing.equalTo(cancelButton.snp.leading).offset(-5)
            }
        } else {
            cancelButton.isHidden = true
            
            searchTextField.snp.remakeConstraints {
                $0.edges.equalToSuperview()
            }
        }
        
        // 애니메이션 적용
        UIView.animate(withDuration: 0.2) { [weak self] in
            guard let self = self else { return }
            self.layoutIfNeeded()
        }
    }
    
    
    public func showClearButton(_ shouldShowClearButton: Bool) {
        if shouldShowClearButton {
            clearButton.isHidden = false
        } else {
            clearButton.isHidden = true
        }
    }
    
    
    public func setPlaceholderText(placeholderText: String,
                                   color: UIColor,
                                   font: UIFont) {
        searchTextField.attributedPlaceholder = .makeAttributedString(text: placeholderText,
                                                                      color: color,
                                                                      font: font)
    }
    
    
    public func clearPlaceholderText() {
        searchTextField.attributedPlaceholder = nil
    }
    
    
    public func setBackgroundColor(colors: [UIColor],
                                   isHorizontal: Bool = true) {
        if colors.count == 0 {
            searchTextField.removeGradientBackground()
            searchTextField.backgroundColor = nil
        }
        else if colors.count == 1 {
            searchTextField.removeGradientBackground()
            searchTextField.backgroundColor = colors.first
        }
        else {
            searchTextField.backgroundColor = nil
            searchTextField.applyGradientBackground(colors: colors, isHorizontal: isHorizontal)
        }
    }
    
    
    public func setBorder(width: CGFloat,
                          colors: [UIColor],
                          isHorizontal: Bool = true) {
        if colors.count == 0 {
            searchTextField.removeGradientBorder()
            searchTextField.layer.borderWidth = 0
            searchTextField.layer.borderColor = nil
        }
        else if colors.count == 1 {
            searchTextField.removeGradientBorder()
            searchTextField.layer.borderWidth = width
            searchTextField.layer.borderColor = colors.first?.cgColor
        }
        else {
            searchTextField.layer.borderWidth = 0
            searchTextField.layer.borderColor = nil
            searchTextField.applyGradientBorder(width: width,
                                                colors: colors,
                                                isHorizontal: isHorizontal)
        }
    }
}



