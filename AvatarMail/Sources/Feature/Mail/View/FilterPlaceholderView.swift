//
//  FilterPlaceholderView.swift
//  AvatarMail
//
//  Created by 최지석 on 8/24/24.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit
import Lottie


protocol FilterPlaceholderViewDelegate: AnyObject {
    func writeNewMailButtonDidTap()
}

final class FilterPlaceholderView: UIView {
    
    weak var delegate: FilterPlaceholderViewDelegate?
    
    var disposeBag = DisposeBag()
    
    let placeholderAnimationView = LottieAnimationView(name: "mail_empty").then {
        $0.loopMode = .loop
        $0.contentMode = .scaleAspectFit
    }
    
    private let placeholderLabel = UILabel().then {
        $0.attributedText = .makeAttributedString(text: "메일함이 텅 비었습니다.",
                                                  color: UIColor(hex:0x787878),
                                                  font: .content(size: 18, weight: .regular),
                                                  lineBreakMode: .byTruncatingTail)
        $0.textAlignment = .center
    }
    
    let writeNewMailButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("새로운 메일 작성하기")
        title.font = UIFont.content(size: 16, weight: .regular)
        title.foregroundColor = UIColor(hex: 0xB6B6B6)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .regular, scale: .default)
        let image = UIImage(systemName: "arrow.up.forward", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 2
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0xB6B6B6)
    }
    
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
            placeholderAnimationView,
            placeholderLabel,
            writeNewMailButton
        )
        
        placeholderAnimationView.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.centerY.equalToSuperview().offset(-80)
            $0.size.equalTo(UIScreen.main.bounds.height / 3.5)
        }
        
        placeholderLabel.snp.makeConstraints {
            $0.top.equalTo(placeholderAnimationView.snp.bottom).offset(15)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }

        writeNewMailButton.snp.makeConstraints {
            $0.centerX.equalToSuperview()
            $0.bottom.equalToSuperview().offset(-60)
        }
        
        placeholderAnimationView.play()
    }
    
    
    private func bindUI() {
        writeNewMailButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                
                self.delegate?.writeNewMailButtonDidTap()
            })
            .disposed(by: disposeBag)
    }
}


