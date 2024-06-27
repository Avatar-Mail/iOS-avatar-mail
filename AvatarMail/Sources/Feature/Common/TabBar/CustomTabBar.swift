//
//  CustomTabBar.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import UIKit
import RxSwift
import RxCocoa
import RxGesture
import SnapKit
import Then


final class CustomTabBar: UIView {
    
    private let disposeBag = DisposeBag()
    
    private let tappedItemSubject = PublishSubject<Int>()
    
    var tappedItem: Observable<Int> { tappedItemSubject.asObservable() }
    
    private let containerView = UIView().then {
        $0.layer.masksToBounds = true
        $0.layer.cornerRadius = 30
        $0.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    private let tabStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.backgroundColor = .clear
    }
    
    private let mailItemView = CustomItemView(with: .mail,
                                              index: CustomTabItem.mail.tabIndex())
    
    private let avatarItemView = CustomItemView(with: .avatar, 
                                                index: CustomTabItem.avatar.tabIndex())
    
    private let settingItemView = CustomItemView(with: .setting, 
                                                 index: CustomTabItem.setting.tabIndex())
    
    private lazy var customItemViews: [CustomItemView] = [mailItemView, avatarItemView, settingItemView]
    
    
    init() {
        super.init(frame: .zero)
        
        makeUI()
        bindUI()
        
        selectItem(index: CustomTabItem.mail.tabIndex())
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // 탭바 배경 그레디언트 색상 적용
        setupBackgroundGradient()
    }
    
    
    private func makeUI() {
        addSubViews(
            containerView.addSubViews(
                tabStackView.addArrangedSubViews(
                    mailItemView,
                    avatarItemView,
                    settingItemView
                )
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        tabStackView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.centerX.equalToSuperview()
            $0.width.equalTo(300)
            $0.height.equalTo(AppConst.shared.tabHeight)
        }
        
        customItemViews.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.clipsToBounds = true
        }
    }
    
    
    private func bindUI() {
        mailItemView.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.mailItemView.animateClick {
                    self.selectItem(index: self.mailItemView.index)
                }
            }
            .disposed(by: disposeBag)
        
        avatarItemView.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.avatarItemView.animateClick {
                    self.selectItem(index: self.avatarItemView.index)
                }
            }
            .disposed(by: disposeBag)
        
        settingItemView.rx.tapGesture()
            .when(.recognized)
            .bind { [weak self] _ in
                guard let self = self else { return }
                self.settingItemView.animateClick {
                    self.selectItem(index: self.settingItemView.index)
                }
            }
            .disposed(by: disposeBag)
    }
    
    
    private func setupBackgroundGradient() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor(hex: 0x538EFE).cgColor, UIColor(hex: 0x4C5BDF).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
        containerView.layer.insertSublayer(gradientLayer, at: 0)
        
        containerView.layer.sublayers?.first?.frame = containerView.bounds
    }
    
    
    private func selectItem(index: Int) {
        customItemViews.forEach { $0.isSelected = $0.index == index }
        tappedItemSubject.onNext(index)
    }
}

