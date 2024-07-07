//
//  RecipientNamePlaceholderView.swift
//  AvatarMail
//
//  Created by 최지석 on 7/7/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa
import RxGesture


protocol RecipientNamePlaceholderViewDelegate: AnyObject {
    func recipientNamePlaceholderViewDidTap()
    func newAvatarCreationButtonDidTap()
}


final class RecipientNamePlaceholderView: UIView {
    
    var disposeBag = DisposeBag()
    
    weak var delegate: RecipientNamePlaceholderViewDelegate?
    
    let containerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    let messageLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "입력된 아바타가 존재하지 않습니다.",
                                                  color: UIColor(hex: 0x787878),
                                                  fontSize: 14,
                                                  fontWeight: .regular)
    }
    
    let newAvatarCreationButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("새로운 아바타 생성하기")
        title.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        title.foregroundColor = UIColor(hex: 0xB6B6B6)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "arrow.up.forward", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 2
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0xB6B6B6)
    }
    
    let newAvatarCreationButtonUnderline = UIView().then {
        $0.backgroundColor = UIColor(hex: 0xB6B6B6)
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
                messageLabel,
                newAvatarCreationButton,
                newAvatarCreationButtonUnderline
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        messageLabel.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-10)
        }
        
        newAvatarCreationButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview()
        }
        
        newAvatarCreationButtonUnderline.snp.makeConstraints {
            $0.top.equalTo(newAvatarCreationButton.snp.bottom)
            $0.centerX.equalTo(newAvatarCreationButton.snp.centerX)
            $0.width.equalTo(newAvatarCreationButton.snp.width)
            $0.height.equalTo(1)
        }
    }
    
    
    private func bindUI() {
        // cancelsTouchesInView를 false로 설정해야 안에 있는 버튼 터치 가능
        let tapGesture = UITapGestureRecognizer()
        tapGesture.cancelsTouchesInView = false
        addGestureRecognizer(tapGesture)
        
        tapGesture.rx.event
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self = self else { return }
                self.delegate?.recipientNamePlaceholderViewDidTap()
            })
            .disposed(by: disposeBag)
        
        newAvatarCreationButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                self.delegate?.newAvatarCreationButtonDidTap()
            })
            .disposed(by: disposeBag)
    }
}
