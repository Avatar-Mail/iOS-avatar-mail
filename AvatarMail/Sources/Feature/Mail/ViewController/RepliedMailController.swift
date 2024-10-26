//
//  RepliedMailController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit
import ReactorKit
import Then
import RxOptional


class RepliedMailController: UIViewController, View {
    
    typealias Reactor = RepliedMailReactor

    var disposeBag = DisposeBag()
    
    
    private let topNavigation = TopNavigation().then {
        $0.setTitle(titleText: "편지 작성하기", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setTitleIsHidden(true)
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    // 상단 편지 삭제하기 버튼
    private let deleteMailButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("편지 삭제하기")
        title.font = UIFont.content(size: 16, weight: .regular)
        title.foregroundColor = UIColor(hex: 0x7B7B7B)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "trash", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 2
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0x7B7B7B)
    }
    
    // 배경 편지지 뷰
    private let letterContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.applyCornerRadius(1.5)
        $0.applyShadow(shadowColor: UIColor.black,
                       shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    private let letterOutlineView = UIView().then {
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 3
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(hex: 0xE6E6E6).cgColor
    }
    
    private let letterScrollView = UIScrollView().then {
        $0.showsVerticalScrollIndicator = false
    }
    
    private let scrollContentView = UIView()
    
    // 수신인 (To.) 영역 뷰
    private let recipientNameInputContainerView = UIView()
    
    private let recipientNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    private let recipientNameLabel = UILabel().then {
        $0.textAlignment = .left
    }
    
    private let narrationButton = UIButton().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 28)
        let image = UIImage(systemName: "waveform.circle", withConfiguration: imageConfiguration)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(hex: 0xA0A0A0)
        $0.isHidden = true
        $0.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        $0.setContentCompressionResistancePriority(.required, for: .horizontal)
    }
    
    private let mailContentsView = UILabel().then {
        $0.numberOfLines = 0
    }
    
    // 발신인 (From.) 영역 뷰
    private let senderNameInputContainerView = UIView()
    
    private let senderNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    private let senderNameLabel = UILabel().then {
        $0.textAlignment = .right
    }
    
    private let replyButton = UIButton().then {
        $0.setButtonTitle(title: "답장 편지 작성하기",
                          color: .white,
                          font: .content(size: 20, weight: .bold))
        $0.applyCornerRadius(20)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    init(
        reactor: RepliedMailReactor
    ) {
        super.init(nibName: nil, bundle: nil)
        
        self.reactor = reactor
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        
        topNavigation.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
        replyButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE), 
                                                     UIColor(hex: 0x4C5BDF)],
                                            isHorizontal: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if let isNarrating = reactor?.currentState.isNarrating, isNarrating == true {
            reactor?.action.onNext(.stopNarration)
        }
    }
    
    private func makeUI() {
        view.backgroundColor = UIColor(hex: 0xEFEFEF)
        
        view.addSubViews(
            
            topNavigation,
            
            deleteMailButton,
            
            letterContainerView.addSubViews(
                letterOutlineView.addSubViews(
                    letterScrollView.addSubViews(
                        scrollContentView.addSubViews(
                            // 수신인 (To.)
                            recipientNameInputContainerView.addSubViews(
                                recipientNameStackView.addArrangedSubViews(
                                    recipientNameLabel,
                                    // 나레이션 재생 버튼
                                    narrationButton
                                )
                            ),
                            
                            // 편지 내용
                            mailContentsView,
                            
                            // 발신인 (From.)
                            senderNameInputContainerView.addSubViews(
                                senderNameStackView.addArrangedSubViews(
                                    senderNameLabel
                                )
                            )
                        )
                    )
                )
            ),
            
            replyButton
        )
        
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        replyButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-((AppConst.shared.safeAreaInset?.bottom ?? 0) + 16))
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
        
        letterContainerView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(60)
            $0.bottom.equalTo(replyButton.snp.top).offset(-40)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }
        
        // 초기화 버튼
        deleteMailButton.snp.makeConstraints {
            $0.bottom.equalTo(letterContainerView.snp.top).offset(-10)
            $0.trailing.equalTo(letterContainerView.snp.trailing)
        }
        
        letterOutlineView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }
        
        letterScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(20)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
        
        // 수신인 (To.)
        recipientNameInputContainerView.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(43)
        }
        
        recipientNameStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 음성 재생 버튼
        narrationButton.snp.makeConstraints {
            $0.size.equalTo(28)
        }
        
        // 편지 내용
        mailContentsView.snp.makeConstraints {
            $0.top.equalTo(recipientNameInputContainerView.snp.bottom).offset(10)
            $0.bottom.lessThanOrEqualTo(senderNameInputContainerView.snp.top).offset(-10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        // 발신인 (From.)
        senderNameInputContainerView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(43)
        }
        
        senderNameStackView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
    }
    
    
    func bind(reactor: RepliedMailReactor) {
        
        replyButton.rx.tap
            .map { Reactor.Action.replyButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        narrationButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                // 나레이션 버튼 바인딩
                if reactor.currentState.isNarrating == false {
                    reactor.action.onNext(.startNarration)
                } else {
                    reactor.action.onNext(.stopNarration)
                }
            })
            .disposed(by: disposeBag)
        
        deleteMailButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                GlobalDialog.shared.show(title: "편지를 삭제하시겠습니까?",
                                         description: "삭제한 편지는 다시 확인하실 수 없습니다.",
                                         buttonInfos: .init(title: "취소",
                                                            titleColor: UIColor(hex: 0x2B2B2B),
                                                            backgroundColor: UIColor(hex: 0xEDEDED),
                                                            borderColor: nil,
                                                            buttonHandler: {
                                                                GlobalDialog.shared.hide()
                                                            }),
                                                      .init(title: "확인",
                                                            titleColor: .white,
                                                            backgroundColor: UIColor(hex: 0x336FF2),
                                                            borderColor: nil,
                                                            buttonHandler: { [weak self] in
                                                                guard let self else { return }
                                                                // 편지 삭제
                                                                reactor.action.onNext(.deleteMail)
                                                                
                                                                GlobalDialog.shared.hide()
                                                            }))
            })
            .disposed(by: disposeBag)
        
        // states
        reactor.state.map(\.isNarrating)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] isNarrating in
                guard let self else { return }
                
                if isNarrating {
                    setNarrationButton(isNarrating: true)
                } else {
                    setNarrationButton(isNarrating: false)
                }
            }.disposed(by: disposeBag)
        
        
        reactor.state.map(\.writtenMail)
            .observe(on: MainScheduler.instance)
            .filterNil()
            .distinctUntilChanged()
            .bind { [weak self] mail in
                guard let self else { return }
                
                reactor.action.onNext(.requestNarrationAudioFile(mailID: mail.id))
                
                topNavigation.setTitle(titleText: mail.isSentFromUser ? "보낸 편지" : "받은 편지",
                                       titleColor: .white,
                                       font: .content(size: 18, weight: .semibold))
                
                recipientNameLabel.attributedText = .makeAttributedString(text: "To. \(mail.recipientName)",
                                                                          color: .black,
                                                                          font: .letter(size: 16, weight: .bold))
                mailContentsView.attributedText = .makeAttributedString(text: mail.content,
                                                                        color: .black,
                                                                        font: .letter(size: 16, weight: .medium),
                                                                        lineHeightMultiple: 1.6)
                senderNameLabel.attributedText = .makeAttributedString(text: "From. \(mail.senderName)",
                                                                       color: .black,
                                                                       font: .letter(size: 16, weight: .bold),
                                                                       textAlignment: .right)
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.narrationAudioURL)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] audioURL in
                guard let self else { return }
                
                if let audioURL {
                    narrationButton.isHidden = false
                } else {
                    narrationButton.isHidden = true
                }
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.isMailDeleted)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] isMailDeleted in
                guard let self else { return }
                
                if isMailDeleted == true {
                    reactor.action.onNext(.closeRepliedMailController)
                }
            }.disposed(by: disposeBag)
                
        reactor.pulse(\.$toastMessage)
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }.disposed(by: disposeBag)
    }
    
    
    private func setNarrationButton(isNarrating: Bool) {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 28)
        let image = UIImage(systemName: isNarrating ? "waveform.circle.fill" : "waveform.circle", withConfiguration: imageConfiguration)
        narrationButton.setImage(image, for: .normal)
        narrationButton.tintColor = UIColor(hex: 0xA0A0A0)
    }
}


extension RepliedMailController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        reactor?.action.onNext(.closeRepliedMailController)
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {
        
    }
    
    func topNavigationRightSideSecondaryIconDidTap() {
        
    }
    
    func topNavigationRightSideTextButtonDidTap() {
        
    }
}
