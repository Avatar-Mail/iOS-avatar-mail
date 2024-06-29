//
//  AvatarSearchBar.swift
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

protocol AvatarSearchBarDelegate: AnyObject {
    func searchTextFieldDidTap()
    func searchTextDidChange(text: String)
    func cancelButtonDidTap()
    func clearButtonDidTap()
}

final class AvatarSearchBar: UIView {
    
    weak var delegate: AvatarSearchBarDelegate?
    
    var disposeBag = DisposeBag()
    
    
    let searchTextField = UITextField().then {
        $0.backgroundColor = .white
        $0.layer.borderColor = UIColor.lightGray.cgColor
        $0.layer.borderWidth = 2
        $0.layer.cornerRadius = 10
        $0.leftViewMode = .always
        $0.clipsToBounds = true
        $0.placeholder = "검색"
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
            $0.top.trailing.bottom.equalToSuperview()
        }
        
        // clear button
        clearButton.snp.makeConstraints {
            $0.trailing.equalTo(searchTextField.snp.trailing).inset(10)
            $0.verticalEdges.equalTo(searchTextField.snp.verticalEdges)
        }
        
        // textfield left icon
        let iconContainerView = UIView()
        iconContainerView.snp.makeConstraints {
            $0.width.equalTo(35)
            $0.height.equalTo(20)
        }
        
        let boldConfiguration = UIImage.SymbolConfiguration(weight: .regular)
        let iconImageView = UIImageView(image: UIImage(systemName: "magnifyingglass", withConfiguration: boldConfiguration)).then {
            $0.tintColor = .gray
            $0.frame = CGRect(x: 0, y: 0, width: 18, height: 18)
        }
        
        iconContainerView.addSubview(iconImageView)
        iconImageView.snp.makeConstraints {
            $0.center.equalTo(iconContainerView.snp.center)
        }
        
        searchTextField.leftView = iconContainerView
        searchTextField.rightViewMode = .never
    }
    
    
    private func bindUI() {
        searchTextField.rx.text
            .orEmpty
            .throttle(.milliseconds(300), scheduler: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] text in
                guard let self = self else { return }
                
                self.delegate?.searchTextDidChange(text: text)
                
                if !text.isEmpty {
                    self.showClearButton(true)
                } else {
                    self.showClearButton(false)
                }
            }.disposed(by: disposeBag)
        
        
        cancelButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.cancelButtonDidTap()
            
                self.showCancelButton(false)
                self.showKeyboard(false)
            })
            .disposed(by: disposeBag)
        
        
        clearButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.searchTextField.text = ""
                self.delegate?.clearButtonDidTap()
                self.showClearButton(false)
            })
            .disposed(by: disposeBag)
        
        
        searchTextField.rx.controlEvent([.editingDidBegin])
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                self.delegate?.searchTextFieldDidTap()
                
                self.showCancelButton(true)
            })
            .disposed(by: disposeBag)
    }
    
    
    private func showCancelButton(_ shouldShowCancelButton: Bool) {
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
    
    
    private func showClearButton(_ shouldShowClearButton: Bool) {
        if shouldShowClearButton {
            clearButton.isHidden = false
        } else {
            clearButton.isHidden = true
        }
    }
}

