//
//  TopNavigation.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//


import UIKit
import SnapKit
import RxSwift
import RxCocoa
import Then


public protocol TopNavigationDelegate: AnyObject {
    func topNavigationLeftSideIconDidTap()
    func topNavigationRightSidePrimaryIconDidTap()
    func topNavigationRightSideSecondaryIconDidTap()
    func topNavigationRightSideTextButtonDidTap()
}


public final class TopNavigation: UIView {
    
    var disposeBag = DisposeBag()
    
    public weak var delegate: TopNavigationDelegate?
    
    private let containerView = UIView()
    
    private let topSafetyAreaView = UIView()
    
    private let leftSideStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 0
        $0.alignment = .center
    }
    
    private let leftSideIconButton = UIButton()
    
    private let titleLabel = UILabel().then {
        $0.numberOfLines = 1
        $0.isHidden = true
    }
    
    private let rightSideStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 20
        $0.alignment = .center
    }
    
    private let rightSidePrimaryIconButton = UIButton().then {
        $0.isHidden = true
    }
    
    private let rightSideSecondaryIconButton = UIButton().then {
        $0.isHidden = true
    }
    
    private let rightSideTextButton = UIButton().then {
        $0.isHidden = true
    }
    
    private let topNavigationViewHeight: CGFloat = AppConst.shared.topNavigationHeight
    
    
    public init() {
        super.init(frame: .zero)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // TopNavigation 컴포넌트는 뷰 컨트롤러의 최상단 view에 addSubview 되어야 함
    private func makeUI() {
        
        addSubViews(
            // 상단 안전영역
            topSafetyAreaView,
            // 최상단 view
            containerView.addSubViews(
                // 왼쪽 아이콘 영역
                leftSideStackView.addArrangedSubViews(
                    leftSideIconButton
                ),
                // 중앙 타이틀 영역
                titleLabel,
                // 오른쪽 아이콘, 텍스트 버튼 영역
                rightSideStackView.addArrangedSubViews(
                    rightSidePrimaryIconButton,
                    rightSideSecondaryIconButton,
                    rightSideTextButton
                )
            )
        )
        
        topSafetyAreaView.snp.makeConstraints() {
            $0.top.left.right.equalToSuperview()
            $0.bottom.equalTo(safeAreaLayoutGuide.snp.top)
        }
        
        containerView.snp.makeConstraints {
            $0.top.equalTo(topSafetyAreaView.snp.bottom)
            $0.left.right.bottom.equalToSuperview()
            $0.height.equalTo(topNavigationViewHeight)
        }
        
        leftSideStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.left.equalToSuperview().inset(18)
        }
        
        leftSideIconButton.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        titleLabel.snp.makeConstraints {
            $0.left.right.equalToSuperview().inset(86)
            $0.height.equalTo(19)
            $0.center.equalToSuperview()
        }
        
        rightSideStackView.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.right.equalToSuperview().inset(18)
        }
        
        rightSidePrimaryIconButton.snp.makeConstraints {
            $0.size.equalTo(20)
        }
        
        rightSideSecondaryIconButton.snp.makeConstraints {
            $0.size.equalTo(20)
        }
    }
    
    
    private func bindUI() {
        leftSideIconButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.topNavigationLeftSideIconDidTap()
            })
            .disposed(by: disposeBag)
        
        rightSidePrimaryIconButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.topNavigationRightSidePrimaryIconDidTap()
            })
            .disposed(by: disposeBag)
        
        rightSideSecondaryIconButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.topNavigationRightSidePrimaryIconDidTap()
            })
            .disposed(by: disposeBag)
        
        rightSideTextButton.rx.tap
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] in
                guard let self else { return }
                self.delegate?.topNavigationRightSideTextButtonDidTap()
            })
        
            
            .disposed(by: disposeBag)
    }
    
    /// TopNavigation 배경 색상 세팅 (topSafetyArea 포함)
    /// - Parameters:
    ///   - color: 탑 네비게이션 배경색
    public func setTopNavigationBackgroundColor(color: UIColor) {
        topSafetyAreaView.backgroundColor = color
        containerView.backgroundColor = color
    }
    
    /// TopNavigation 그라디언트 배경 색상 세팅 (topSafetyArea 포함)
    /// - Parameters:
    ///   - colors: 배경 그라디언트 적용할 탑 네비게이션 색상 리스트
    public func setTopNavigationBackgroundGradientColor(colors: [UIColor]) {
        topSafetyAreaView.applyGradientBackground(colors: colors, isHorizontal: true)
        containerView.applyGradientBackground(colors: colors, isHorizontal: true)
    }
    
    /// TopNavigation 중앙 타이틀 세팅 (topSafetyArea 포함)
    /// - Parameters:
    ///   - titleText: 타이틀 텍스트
    ///   - titleColor: 타이틀 색상
    ///   - fontSize: 타이틀 폰트 사이즈
    public func setTitle(titleText: String?,
                         titleColor: UIColor,
                         font: UIFont) {
        
        if let titleText {
            titleLabel.attributedText = .makeAttributedString(text: titleText,
                                                              color: titleColor,
                                                              font: font,
                                                              textAlignment: .center)
            titleLabel.isHidden = false
        }
    }
    
    /// TopNavigation 중앙 타이틀 숨김 처리 세팅
    /// - Parameters:
    ///   - isHidden: 숨김 처리 여부
    public func setTitleIsHidden(_ isHidden: Bool) {
        titleLabel.isHidden = isHidden
    }
    
    /// TopNavigation 좌측 아이콘 세팅
    /// - Parameters:
    ///   - iconName: 아이콘 이름
    ///   - iconColor: 아c        이콘 색상
    ///   - iconSize: 아이콘 크기
    public func setLeftIcon(iconName: String?,
                            iconColor: UIColor,
                            iconSize: CGSize) {
        if let iconName, let iconImage = UIImage(systemName: iconName) {
            let coloredImage = iconImage.withColor(iconColor)
            let resizedImage = coloredImage?.resized(to: iconSize)
            
            leftSideIconButton.snp.remakeConstraints {
                $0.width.equalTo(iconSize.width)
                $0.height.equalTo(iconSize.height)
            }
            
            leftSideIconButton.setImage(resizedImage, for: .normal)
            leftSideIconButton.isHidden = false
        } else {
            leftSideIconButton.isHidden = true
        }
    }
    
    
    /// TopNavigation 좌측 로고 아이콘 세팅
    /// - Parameters:
    ///   - logoName: 로고 아이콘 이름
    ///   - logoSize: 로고 아이콘 크기
    public func setLeftLogoIcon(logoName: String?,
                                logoSize: CGSize) {
        if let logoName, let logoImage = UIImage(named: logoName) {
            let resizedImage = logoImage.resized(to: logoSize)
            
            leftSideIconButton.snp.remakeConstraints {
                $0.width.equalTo(logoSize.width)
                $0.height.equalTo(logoSize.height)
            }
            
            leftSideIconButton.setImage(resizedImage, for: .normal)
            leftSideIconButton.isUserInteractionEnabled = false
            leftSideIconButton.isHidden = false
        } else {
            leftSideIconButton.isUserInteractionEnabled = true
            leftSideIconButton.isHidden = true
        }
    }
    
    
    /// TopNavigation 우측 Primary(첫 번째) 아이콘 세팅
    /// - Parameters:
    ///   - iconName: 아이콘 이름
    ///   - iconColor: 아이콘 색상
    ///   - iconSize: 아이콘 크기
    public func setRightSidePrimaryIcon(iconName: String?,
                                        iconColor: UIColor,
                                        iconSize: CGSize) {
        if let iconName, let iconImage = UIImage(systemName: iconName) {
            let coloredImage = iconImage.withColor(iconColor)
            let resizedImage = coloredImage?.resized(to: iconSize)
            
            rightSidePrimaryIconButton.snp.remakeConstraints {
                $0.width.equalTo(iconSize.width)
                $0.height.equalTo(iconSize.height)
            }
            
            rightSidePrimaryIconButton.setImage(resizedImage, for: .normal)
            rightSidePrimaryIconButton.isHidden = false
        } else {
            rightSidePrimaryIconButton.isHidden = true
        }
    }
    
    
    /// TopNavigation 우측 Secondary(두 번째) 아이콘 세팅
    /// - Parameters:
    ///   - iconName: 아이콘 이름
    ///   - iconColor: 아이콘 색상
    ///   - iconSize: 아이콘 크기
    public func setRightSideSecondaryIcon(iconName: String?,
                                          iconColor: UIColor,
                                          iconSize: CGSize) {
        if let iconName, let iconImage = UIImage(systemName: iconName) {
            let coloredImage = iconImage.withColor(iconColor)
            let resizedImage = coloredImage?.resized(to: iconSize)
            
            rightSideSecondaryIconButton.snp.remakeConstraints {
                $0.width.equalTo(iconSize.width)
                $0.height.equalTo(iconSize.height)
            }
            
            rightSideSecondaryIconButton.setImage(resizedImage, for: .normal)
            rightSideSecondaryIconButton.isHidden = false
        } else {
            rightSideSecondaryIconButton.isHidden = true
        }
    }
    
    
    /// TopNavigation 우측 텍스트 버튼 세팅
    /// - Parameters:
    ///  - buttonText: 텍스트 버튼 내 텍스트
    ///  - buttonTextColor: 텍스트 버튼 내 텍스트 색상
    public func setRightSideTextButton(buttonText: String?,
                                       buttonTextColor: UIColor,
                                       buttonTextFont: UIFont) {
        if let buttonText {
            rightSideTextButton.setAttributedTitle(.makeAttributedString(text: buttonText,
                                                                         color: buttonTextColor,
                                                                         font: buttonTextFont),
                                                   for: .normal)
            rightSideTextButton.isHidden = false
        }
    }
    
    
    /// 스크롤 높이에 의한 TopNavigation의 그림자 설정
    /// (scroll 값이 topNavigationViewHeight를 넘어가면 스크롤 높이에 따라 그림자가 서서히 생겨나며, 스크롤 높이에 따라 최대 maxShadowHeight 높이의 그림자가 생성된다.)
    /// - Parameters:
    ///   - scroll: 스크롤 높이
    ///   - maxShadowHeight: 그림자 최대 높이
    public func setTopNavigationShadow(scroll: CGFloat,
                                       maxShadowHeight: CGFloat) {
        if scroll > topNavigationViewHeight {
            let shadowHeight = min(
                maxShadowHeight,
                scroll / topNavigationViewHeight - 1
            )
            if shadowHeight <= 0 {
                layer.shadowOpacity = 0
            } else {
                layer.masksToBounds = false
                layer.shadowColor = UIColor.gray.cgColor
                layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
                layer.shadowOpacity = 1
            }
        } else {
            layer.shadowOpacity = 0
        }
    }
    
    
    /// 주어진 높이(shadowHeight)를 갖는 TopNavigation의 그림자 설정
    /// - Parameter shadowHeight: 그림자의 높이
    public func setTopNavigationShadow(shadowHeight: CGFloat) {
        layer.masksToBounds = false
        layer.shadowColor = UIColor.gray.cgColor
        layer.shadowOffset = CGSize(width: 0, height: shadowHeight)
        layer.shadowOpacity = 1
    }
    
    
    /// TopNavigation의 그림자 숨김 여부 설정
    /// - Parameter isHidden: 그림자의 숨김 여부
    public func setTopNavigationShadow(isHidden: Bool) {
        self.layer.shadowOpacity = isHidden ? 0 : 1
    }
}
