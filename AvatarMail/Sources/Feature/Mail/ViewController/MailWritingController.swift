//
//  MailWritingController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit
import ReactorKit
import Then


class MailWritingController: UIViewController, View {
    
    typealias Reactor = MailWritingReactor

    var disposeBag = DisposeBag()
    
    private let topNavigation = TopNavigation().then {
        $0.setTitle(titleText: "편지 작성하기", titleColor: .white, fontSize: 18, fontWeight: .semibold)
        $0.setTitleIsHidden(true)
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setRightSideSecondaryIcon(iconName: "line.3.horizontal", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private let tooltipView = TooltipView().then {
        $0.applyShadow(shadowColor: UIColor.gray,
                       shadowRadius: 4,
                       shadowOffset: CGSize(width: 2, height: 4),
                       shadowOpacity: 0.4)
        $0.setData(title: "편지 작성하기",
                   description: "당신이 원하는 아바타에게 편지를 작성해보세요.")
    }
    
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
        $0.layer.cornerRadius = 10
        $0.layer.borderWidth = 1
        $0.layer.borderColor = UIColor(hex: 0xEBEBEB).cgColor
    }
    
    private let letterScrollView = UIScrollView()
    
    private let scrollContentView = UIView()
    
    private let recipientNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    private let recipientTitleTextLabel = UITextField().then {
        $0.text = "To."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let recipientNameTextField = UITextField().then {
        $0.backgroundColor = UIColor(hex: 0xF8F8F8)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .center
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    private let senderNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    private let senderTitleTextLabel = UITextField().then {
        $0.text = "From."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let senderNameTextField = UITextField().then {
        $0.backgroundColor = UIColor(hex: 0xF8F8F8)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .center
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }
    
    private let inputTextView = UITextView().then {
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    }
    
    private let textCountLabel = UILabel().then {
        $0.text = "0 | 300자"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(hex:0x7B7B7B)
        
        $0.isHidden = true
    }
    
    private let clearTextButton = UIButton().then {
        $0.setTitle("초기화", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.setTitleColor(UIColor(hex:0x7B7B7B), for: .normal)
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14)
        let image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfiguration)
        $0.setImage(image, for: .normal)
        $0.tintColor = UIColor(hex:0x7B7B7B)
        $0.semanticContentAttribute = .forceRightToLeft
        
        $0.isHidden = true
    }
    
    private let sendMailButton = UIButton().then {
        $0.setButtonTitle(title: "편지 보내기",
                          color: .white,
                          fontSize: 20,
                          fontWeight: .bold)
        $0.applyCornerRadius(20)
        $0.applyShadow(shadowRadius: 4,
                       shadowOffset: CGSize(width: 0, height: 2),
                       shadowOpacity: 0.5)
    }
    
    init(
        reactor: MailWritingReactor
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
        
        self.hideKeyboardWhenTappedAround()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
        sendMailButton.applyGradientBackground(colors: [UIColor(hex: 0x538EFE),
                                                        UIColor(hex: 0x4C5BDF)],
                                               isHorizontal: true)
    }
    
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            topNavigation,
            
            tooltipView,
            clearTextButton,
            
            letterContainerView.addSubViews(
                letterOutlineView.addSubViews(
                    letterScrollView.addSubViews(
                        scrollContentView.addSubViews(
                            // 수신인 (To.)
                            recipientNameStackView.addArrangedSubViews(
                                recipientTitleTextLabel,
                                recipientNameTextField
                            ),
                            
                            // 편지 내용
                            inputTextView,
                            
                            // 발신인 (From.)
                            senderNameStackView.addArrangedSubViews(
                                senderTitleTextLabel,
                                senderNameTextField
                            )
                        )
                    )
                )
            ),
            
            textCountLabel,
            
            sendMailButton
        )
        
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        tooltipView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(16)
            $0.horizontalEdges.equalToSuperview().inset(16)
        }
        
        sendMailButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-((AppConst.shared.safeAreaInset?.bottom ?? 0) + 16))
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
        
        letterContainerView.snp.makeConstraints {
            $0.top.equalTo(tooltipView.snp.bottom).offset(50)
            $0.bottom.lessThanOrEqualTo(sendMailButton.snp.top).offset(-50).priority(999)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-50).priority(1)
            $0.horizontalEdges.equalToSuperview().inset(28)
        }
        
        clearTextButton.snp.makeConstraints {
            $0.bottom.equalTo(letterContainerView.snp.top).offset(-10)
            $0.trailing.equalTo(letterContainerView.snp.trailing)
        }
        
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(letterContainerView.snp.bottom).offset(10)
            $0.trailing.equalTo(letterContainerView.snp.trailing)
        }
        
        letterOutlineView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        
        letterScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(12)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
        
        // 수신인 (To.)
        recipientNameStackView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        recipientNameTextField.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(50)
            $0.height.equalTo(25)
        }
        
        // 발신인 (From.)
        senderNameStackView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
        }
        
        senderNameTextField.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(50)
            $0.height.equalTo(25)
        }
        
        // 내용
        inputTextView.snp.makeConstraints {
            $0.top.equalTo(recipientNameStackView.snp.bottom).offset(10)
            $0.bottom.equalTo(senderNameStackView.snp.top).offset(-10)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    
    func bind(reactor: MailWritingReactor) {
        inputTextView.rx.text
            .map { Reactor.Action.inputTextDidChange(text: $0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        inputTextView.rx.didBeginEditing
            .bind {
                if reactor.currentState.isTooltipHidden == false {
                    reactor.action.onNext(.hideToolTip)
                }
            }
            .disposed(by: disposeBag)
        
        recipientNameTextField.rx.text
            .map { Reactor.Action.recipientNameTextDidChange(text: $0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        recipientNameTextField.rx.controlEvent(.editingDidBegin)
            .bind {
                if reactor.currentState.isTooltipHidden == false {
                    reactor.action.onNext(.hideToolTip)
                }
            }
            .disposed(by: disposeBag)
        
        senderNameTextField.rx.text
            .map { Reactor.Action.senderNameTextDidChange(text: $0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        senderNameTextField.rx.controlEvent(.editingDidBegin)
            .bind {
                if reactor.currentState.isTooltipHidden == false {
                    reactor.action.onNext(.hideToolTip)
                }
            }
            .disposed(by: disposeBag)
        
        sendMailButton.rx.tap
            .map { Reactor.Action.sendButtonDipTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        clearTextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
                self.recipientNameTextField.text = ""
                self.inputTextView.text = ""
                self.senderNameTextField.text = ""
            }.disposed(by: disposeBag)
        
        // states
        reactor.state.map(\.isMailSent)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { $0 }  // isMailSent가 true일 때만 현재 뷰컨 close
            .map { _ in Reactor.Action.closeMailWritingController }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.inputText)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .bind { [weak self] inputText in
                guard let self else { return }
                self.textCountLabel.text = "\(inputText.count) | 300자"
            }.disposed(by: disposeBag)
        
        reactor.state.map(\.isTooltipHidden)
            .observe(on: MainScheduler.instance)
            .distinctUntilChanged()
            .filter { $0 == true }
            .bind { [weak self] isTooltipHidden in
                guard let self else { return }
                
                // 툴팁 숨김
                tooltipView.isHidden = true
                
                UIView.animate(withDuration: 0.5) { [weak self] in
                    guard let self else { return }
                    // 편지 컨테이너 뷰 레이아웃 재설정
                    letterContainerView.snp.remakeConstraints {
                        $0.top.equalTo(self.topNavigation.snp.bottom).offset(60)
                        // 최초에는 전송 버튼 상단에 붙어있다가, 키보드가 올라오면 키보드 layoutGuide 상단에 붙도록 처리
                        $0.bottom.lessThanOrEqualTo(self.sendMailButton.snp.top).offset(-60).priority(999)
                        $0.bottom.equalTo(self.view.keyboardLayoutGuide.snp.top).offset(-50).priority(1)
                        $0.horizontalEdges.equalToSuperview().inset(28)
                    }
                }
                    
                // 초기화 버튼 숨김 해제
                clearTextButton.isHidden = false
                // 글자 수 레이블 숨김 해제
                textCountLabel.isHidden = false
                // 탑 네비게이션 중앙 타이틀 숨김 해제
                topNavigation.setTitleIsHidden(false)
            }.disposed(by: disposeBag)
    }
}


extension MailWritingController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        guard let text = textView.text else { return }
        
        // text view 글자 수 제한
        let maxLength = 300
        if text.count > maxLength {
            textView.text = String(text.prefix(maxLength))
        }
    }
}



extension MailWritingController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        reactor?.action.onNext(.closeMailWritingController)
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {}
    
    func topNavigationRightSideSecondaryIconDidTap() {}
    
    func topNavigationRightSideTextButtonDidTap() {}
}
