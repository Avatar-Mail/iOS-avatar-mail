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
    
    private let containerStackView = UIStackView().then {
        $0.distribution = .fillEqually
        $0.alignment = .center
        $0.backgroundColor = .systemIndigo
        $0.setupCornerRadius(30)
    }
    
    private let tappedItemSubject = PublishSubject<Int>()
    
    var tappedItem: Observable<Int> { tappedItemSubject.asObservable() }
    
    private let mailItemView = CustomItemView(with: .mail, index: 0)
    private let avatarItemView = CustomItemView(with: .avatar, index: 1)
    private let settingItemView = CustomItemView(with: .setting, index: 2)
    
    private lazy var customItemViews: [CustomItemView] = [mailItemView, avatarItemView, settingItemView]
    
    
    init() {
        super.init(frame: .zero)
        
        makeUI()
        bindUI()
        
        selectItem(index: 0)
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        
        addSubViews(
            containerStackView.addArrangedSubViews(
                mailItemView,
                avatarItemView,
                settingItemView
            )
        )
        
        containerStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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
    
    
    private func selectItem(index: Int) {
        customItemViews.forEach { $0.isSelected = $0.index == index }
        tappedItemSubject.onNext(index)
    }
}

