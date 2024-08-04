//
//  LetterContentInputTextView.swift
//  AvatarMail
//
//  Created by 최지석 on 7/7/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxOptional
import RxGesture


protocol LetterContentInputTextViewDelegate: AnyObject {
    func inputTextDidChange(text: String)
    func inputTextViewDidBeginEditing()
    func inputTextViewDidEndEditing()
}

final class LetterContentInputTextView: UIView {
    
    var disposeBag = DisposeBag()
    
    public weak var delegate: LetterContentInputTextViewDelegate?
    
    let containerView = UIView()
    
    private let inputTextView = UITextView()
    
    private let placeholderView = UIView().then {
        $0.backgroundColor = UIColor(hex:0xFCFCFC)
        $0.applyCornerRadius(10)
        $0.applyBorder(width: 1, color: UIColor(hex:0xE9E9E9))
    }
    
    private let placeholderLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "편지의 내용을 입력하세요.", 
                                                  color: UIColor(hex: 0x7B7B7B),
                                                  font: .content(size: 14, weight: .regular))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                inputTextView,
                placeholderView.addSubViews(
                    placeholderLabel
                )
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        inputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        placeholderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.center.equalToSuperview()
        }
        
        inputTextView.isHidden = true
        placeholderView.isHidden = false
    }
    
    
    private func bindUI() {
        placeholderView.rx.tapGesture()
            .skip(1)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                inputTextView.becomeFirstResponder()
            })
            .disposed(by: disposeBag)
        
        inputTextView.rx.text
            .distinctUntilChanged()
            .filterNil()
            .bind(onNext: { [weak self] text in
                guard let self else { return }
                delegate?.inputTextDidChange(text: text)
            }).disposed(by: disposeBag)
        
        inputTextView.rx.didBeginEditing
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                delegate?.inputTextViewDidBeginEditing()
            }).disposed(by: disposeBag)
        
        inputTextView.rx.didEndEditing
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                delegate?.inputTextViewDidEndEditing()
            }).disposed(by: disposeBag)
    }
    
    
    public func showInputTextView(_ shouldShow: Bool) {
        if shouldShow {
            inputTextView.isHidden = false
            placeholderView.isHidden = true
        } else {
            inputTextView.isHidden = true
            placeholderView.isHidden = false
        }
    }
    
    
    public func setInputText(text: String) {
        inputTextView.attributedText = .makeAttributedString(text: text,
                                                             color: .black,
                                                             font: .letter(size: 16, weight: .medium),
                                                             lineHeightMultiple: 1.6)
    }
    
    
    public func getInputText() -> String {
        return inputTextView.text
    }
}
