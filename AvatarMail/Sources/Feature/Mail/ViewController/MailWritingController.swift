//
//  MailWritingController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import UIKit
import ReactorKit
import Then
import RxCocoa
import RxSwift
import RxGesture


class MailWritingController: UIViewController, View {
    
    typealias Reactor = MailWritingReactor

    var disposeBag = DisposeBag()
    
    private let topNavigation = TopNavigation().then {
        $0.setTitle(titleText: "편지 작성하기", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setTitleIsHidden(true)
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    // 상단 툴팁 뷰
    private let tooltipView = TooltipView().then {
        $0.applyShadow(shadowColor: UIColor.gray,
                       shadowRadius: 4,
                       shadowOffset: CGSize(width: 2, height: 4),
                       shadowOpacity: 0.4)
        $0.setData(title: "편지 작성하기",
                   description: "당신이 원하는 아바타에게 편지를 작성해보세요.")
    }
    
    // 바탕 버튼 (터치 시 키보드 감추기 위함)
    private let backgroundButton = UIButton().then {
        $0.backgroundColor = .clear
    }
    
    private let clearTextButtonContainerView = UIView().then {
        $0.backgroundColor = .clear
    }
    
    // 상단 초기화 버튼
    private let clearTextButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("초기화")
        title.font = UIFont.content(size: 16, weight: .regular)
        title.foregroundColor = UIColor(hex: 0x7B7B7B)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "arrow.counterclockwise", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 2
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0x7B7B7B)
        
        $0.isHidden = true
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
    
    private let recipientNameSearchBar = SearchBar().then {
        $0.setPlaceholderText(placeholderText: "편지를 받을 아바타를 찾아보세요.",
                              color: UIColor(hex: 0x7B7B7B),
                              font: .content(size: 14, weight: .regular))
        $0.setLeftIcon(iconName: "magnifyingglass",
                       iconSize: CGSize(width: 16, height: 16),
                       iconColor: UIColor(hex:0x7B7B7B),
                       configuration: nil)
        $0.setBackgroundColor(colors: [UIColor(hex:0xF1F1F1)])
        $0.setBorder(width: 0, colors: [])
    }
    
    private let recipientNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
        $0.isHidden = true
    }
    
    private let recipientNameLabel = UILabel()
    
    private let recipientNameCorrectionIcon = UIImageView().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfiguration)
        $0.image = image
        $0.tintColor = UIColor(hex:0xA0A0A0)
    }
    
    // 수신인 자동완성 영역 컬렉션 뷰
    private let recipientNameAutoCompleteContainerView = UIView().then {
        $0.isHidden = true
    }
    
    private let recipientNamePlaceholderView = RecipientNamePlaceholderView().then {
        $0.isHidden = true
    }
    
    private let recipientNameAutoCompleteCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(AutoCompletedNameCell.self, forCellWithReuseIdentifier: AutoCompletedNameCell.identifier)
        collectionView.backgroundColor = .white
        collectionView.isHidden = true
        return collectionView
    }()

    // 편지 내용 영역 뷰
    private let inputTextView = LetterContentInputTextView()
    
    // 발신인 (From.) 영역 뷰
    private let senderNameInputContainerView = UIView()
    
    private let senderNameInputTextfield = SenderNameInputTextfield().then {
        $0.setPlaceholderText(placeholderText: "보내는 사람의 이름을 입력하세요.",
                              color: UIColor(hex: 0x7B7B7B),
                              font: .content(size: 14, weight: .regular))
        $0.setBackgroundColor(colors: [UIColor(hex:0xF1F1F1)])
        $0.setBorder(width: 0, colors: [])
    }
    
    private let senderNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
        $0.isHidden = true
    }
    
    private let senderNameLabel = UILabel()
    
    private let senderNameCorrectionIcon = UIImageView().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfiguration)
        $0.image = image
        $0.tintColor = UIColor(hex:0xA0A0A0)
    }
    
    // 하단 글자수 레이블
    private let textCountLabel = UILabel().then {
        $0.text = "0 | 300자"
        $0.font = UIFont.content(size: 16, weight: .regular)
        $0.textColor = UIColor(hex:0x7B7B7B)
        
        $0.isHidden = true
    }
    
    private let sendMailButton = UIButton().then {
        $0.setButtonTitle(title: "편지 보내기",
                          color: .white,
                          font: .content(size: 20, weight: .bold))
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
        recipientNameSearchBar.delegate = self
        recipientNamePlaceholderView.delegate = self
        inputTextView.delegate = self
        recipientNameAutoCompleteCollectionView.delegate = self
        senderNameInputTextfield.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactor?.action.onNext(.initializeRecipientStates)
        reactor?.action.onNext(.getAllAvatarInfos)
        
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
            backgroundButton,
            
            topNavigation,
            
            tooltipView,
            
            clearTextButtonContainerView.addSubViews(
                clearTextButton
            ),
            
            letterContainerView.addSubViews(
                letterOutlineView.addSubViews(
                    
                    // 수신인 (To.)
                    recipientNameInputContainerView.addSubViews(
                        recipientNameSearchBar,

                        recipientNameStackView.addArrangedSubViews(
                            recipientNameLabel,
                            recipientNameCorrectionIcon
                        )
                    ),
                    
                    recipientNameAutoCompleteContainerView.addSubViews(
                        recipientNameAutoCompleteCollectionView,
                        recipientNamePlaceholderView
                    ),
                    
                    letterScrollView.addSubViews(
                        scrollContentView.addSubViews(
                            // 편지 내용
                            inputTextView
                        )
                    ),
                    
                    // 발신인 (From.)
                    senderNameInputContainerView.addSubViews(
                        senderNameInputTextfield,
                        
                        senderNameStackView.addArrangedSubViews(
                            senderNameLabel,
                            senderNameCorrectionIcon
                        )
                    )
                )
            ),
            
            textCountLabel,
            
            sendMailButton
        )
        
        backgroundButton.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        tooltipView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
        }
        
        sendMailButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-((AppConst.shared.safeAreaInset?.bottom ?? 0) + 16))
            $0.horizontalEdges.equalToSuperview().inset(16)
            $0.height.equalTo(72)
        }
        
        letterContainerView.snp.makeConstraints {
            $0.top.equalTo(tooltipView.snp.bottom).offset(24)
            $0.horizontalEdges.equalToSuperview().inset(28)
            // 키보드 올라오기 전
            $0.bottom.equalTo(sendMailButton.snp.top).offset(-30).priority(999)
            // 키보드 올라온 후
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-50).priority(750)
        }
        
        letterOutlineView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(14)
        }
        
        clearTextButtonContainerView.snp.makeConstraints {
            $0.bottom.equalTo(letterContainerView.snp.top)
            $0.trailing.equalTo(letterContainerView.snp.trailing)
            $0.width.equalTo(70)
            $0.height.equalTo(40)
        }
        
        // 초기화 버튼
        clearTextButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview()
        }
        
        // 'N | 300자' 레이블
        textCountLabel.snp.makeConstraints {
            $0.top.equalTo(letterContainerView.snp.bottom).offset(10)
            $0.trailing.equalTo(letterContainerView.snp.trailing)
        }
        
        // 수신인 (To.)
        recipientNameInputContainerView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(43)
        }
        
        recipientNameSearchBar.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        recipientNameStackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        recipientNameAutoCompleteContainerView.snp.makeConstraints {
            $0.top.equalTo(recipientNameSearchBar.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalToSuperview().inset(20)
        }
        
        recipientNameAutoCompleteCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        recipientNamePlaceholderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        letterScrollView.snp.makeConstraints {
            $0.top.equalTo(recipientNameInputContainerView.snp.bottom).offset(10)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.bottom.equalTo(senderNameInputContainerView.snp.top).offset(-10)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalToSuperview()
            $0.height.greaterThanOrEqualToSuperview()
        }
        
        // 편지 내용
        inputTextView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        // 발신인 (From.)
        senderNameInputContainerView.snp.makeConstraints {
            $0.bottom.equalToSuperview().inset(20)
            $0.horizontalEdges.equalToSuperview().inset(20)
            $0.height.equalTo(43)
        }
        
        senderNameInputTextfield.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        senderNameStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    
    func bind(reactor: MailWritingReactor) {
        reactor.state
            .map { $0.filteredAvatarInfos }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: recipientNameAutoCompleteCollectionView.rx.items(cellIdentifier: AutoCompletedNameCell.identifier,
                                                                       cellType: AutoCompletedNameCell.self)) { index, avatar, cell in
                cell.setData(cellIndex: index, avatarName: avatar.name)
                cell.delegate = self
            }
            .disposed(by: disposeBag)
        
        backgroundButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                
                view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        sendMailButton.rx.tap
            .asDriver()
            .drive(onNext: {
                
                if reactor.currentState.senderNameText.isEmpty {
                    reactor.action.onNext(.showToast(text: "편지를 보내는 사람의 이름을 입력하세요"))
                    return
                }
                
                if reactor.currentState.letterContentsText.isEmpty {
                    reactor.action.onNext(.showToast(text: "편지의 내용을 입력하세요."))
                    return
                }
                
                if reactor.currentState.selectedAvatar == nil {
                    reactor.action.onNext(.showToast(text: "편지를 받는 아바타를 선택하세요."))
                    return
                }
                
                GlobalIndicator.shared.show("mail_indicator", with: "편지를 보내는 중입니다...")
                
                reactor.action.onNext(.sendButtonDipTap)
            })
            .disposed(by: disposeBag)
        
        
        clearTextButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self else { return }
                // 수신인 영역 초기화
                recipientNameSearchBar.setSearchText(text: "")
                recipientNameSearchBar.showClearButton(false)
                recipientNameSearchBar.showCancelButton(false)
                recipientNameSearchBar.setPlaceholderText(placeholderText: "편지를 보낼 아바타를 찾아보세요.",
                                                          color: UIColor(hex: 0x7B7B7B),
                                                          font: .content(size: 14, weight: .regular))
                showRecipientSearchBar(true)
                reactor.action.onNext(.initializeRecipientStates)
                
                // 메일 컨텐츠 영역 초기화
                inputTextView.setInputText(text: "")
                inputTextView.showInputTextView(false)
                reactor.action.onNext(.initializeLetterContentStates)
                
                // 발신인 영역 초기화
                senderNameInputTextfield.setInputText(text: "")
                senderNameInputTextfield.showClearButton(false)
                senderNameInputTextfield.showCancelButton(false)
                senderNameInputTextfield.setPlaceholderText(placeholderText: "보내는 사람의 이름을 입력하세요.",
                                                            color: UIColor(hex: 0x7B7B7B),
                                                            font: .content(size: 14, weight: .regular))
                reactor.action.onNext(.initializeSenderStates)
                
                view.endEditing(true)
            })
            .disposed(by: disposeBag)
        
        recipientNameStackView.rx.tapGesture()
            .skip(1)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                showRecipientSearchBar(true)
                recipientNameSearchBar.showKeyboard(true)
            })
            .disposed(by: disposeBag)
        
        senderNameStackView.rx.tapGesture()
            .skip(1)
            .asDriver(onErrorDriveWith: .empty())
            .drive(onNext: { [weak self] _ in
                guard let self else { return }
                showSenderInputTextfield(true)
                senderNameInputTextfield.showKeyboard(true)
            })
            .disposed(by: disposeBag)
        
        // states
        reactor.pulse(\.$isMailSent)
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .bind { isMailSent in
                
                GlobalIndicator.shared.hide()
                
                if isMailSent {
                    reactor.action.onNext(.closeMailWritingController)
                }
            }
            .disposed(by: disposeBag)
        
        reactor.state.map(\.letterContentsText)
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
        
        reactor.pulse(\.$toastMessage)
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }.disposed(by: disposeBag)
    }
    
    
    public func hideTooltip() {
        if reactor?.currentState.isTooltipHidden == false {
            reactor?.action.onNext(.hideToolTip)
        }
        topNavigation.setTitleIsHidden(false)
    }
    
    
    public func showRecipientNameAutoCompleteContainerView(_ shouldShow: Bool) {
        if shouldShow {
            recipientNameAutoCompleteContainerView.isHidden = false
            
            // 다른 뷰 숨김
            inputTextView.isHidden = true
            senderNameInputContainerView.isHidden = true
        } else {
            recipientNameAutoCompleteContainerView.isHidden = true
            
            // 다른 뷰 보임
            inputTextView.isHidden = false
            senderNameInputContainerView.isHidden = false
        }
    }
    
    
    public func showRecipientNameAutoCompleteCollectionView(_ shouldShow: Bool) {
        if shouldShow {
            recipientNamePlaceholderView.isHidden = true
            recipientNameAutoCompleteCollectionView.isHidden = false
        } else {
            recipientNamePlaceholderView.isHidden = false
            recipientNameAutoCompleteCollectionView.isHidden = true
        }
    }
    
    
    public func showRecipientSearchBar(_ shouldShow: Bool) {
        if shouldShow {
            recipientNameSearchBar.isHidden = false
            recipientNameStackView.isHidden = true
        } else {
            recipientNameSearchBar.isHidden = true
            recipientNameStackView.isHidden = false
        }
    }
    
    
    public func showSenderInputTextfield(_ shouldShow: Bool) {
        if shouldShow {
            senderNameInputTextfield.isHidden = false
            senderNameStackView.isHidden = true
        } else {
            senderNameInputTextfield.isHidden = true
            senderNameStackView.isHidden = false
        }
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


extension MailWritingController: SearchBarDelegate {
    func searchTextFieldDidReturn() { }
    
    func searchTextFieldDidBeginEditing() {
        recipientNameSearchBar.clearPlaceholderText()
        showRecipientNameAutoCompleteContainerView(true)
        showRecipientNameAutoCompleteCollectionView(false)
        recipientNameSearchBar.showCancelButton(true)
        hideTooltip()
    }
    
    
    func searchTextFieldDidEndEditing() {
        if let searchText = recipientNameSearchBar.getSearchText(), searchText.isEmpty {
            recipientNameSearchBar.setSearchText(text: "")
            recipientNameSearchBar.showClearButton(false)
            recipientNameSearchBar.showCancelButton(false)
            recipientNameSearchBar.showKeyboard(false)
            recipientNameSearchBar.setPlaceholderText(placeholderText: "편지를 보낼 아바타를 찾아보세요.",
                                                      color: UIColor(hex: 0x7B7B7B),
                                                      font: .content(size: 14, weight: .regular))
        } else {
            recipientNameSearchBar.showCancelButton(false)
        }
        showRecipientNameAutoCompleteContainerView(false)
    }
    
    func searchTextDidChange(text: String) {
        reactor?.action.onNext(.recipientNameTextDidChange(text: text))
        
        if !text.isEmpty {
            recipientNameSearchBar.showClearButton(true)
        }
        
        if let filteredAvatarInfos = reactor?.currentState.filteredAvatarInfos, !filteredAvatarInfos.isEmpty {
            showRecipientNameAutoCompleteCollectionView(true)
        } else {
            showRecipientNameAutoCompleteCollectionView(false)
        }
    }
    
    func cancelButtonDidTap() {
        if let selectedAvatar = reactor?.currentState.selectedAvatar {
            showRecipientSearchBar(false)
            showRecipientNameAutoCompleteContainerView(false)
        } else {
            recipientNameSearchBar.setSearchText(text: "")
            recipientNameSearchBar.showClearButton(false)
            recipientNameSearchBar.showCancelButton(false)
            recipientNameSearchBar.showKeyboard(false)
            recipientNameSearchBar.setPlaceholderText(placeholderText: "편지를 받을 아바타를 찾아보세요.",
                                                      color: UIColor(hex: 0x7B7B7B),
                                                      font: .content(size: 14, weight: .regular))
            showRecipientNameAutoCompleteContainerView(false)
        }
    }
    
    func clearButtonDidTap() {
        recipientNameSearchBar.setSearchText(text: "")
        recipientNameSearchBar.showKeyboard(true)
        reactor?.action.onNext(.recipientNameTextDidChange(text: ""))
    }
}


extension MailWritingController: SenderNameInputTextfieldDelegate {
    func senderNameInputTextfieldDidBeginEditing() {
        senderNameInputTextfield.clearPlaceholderText()
        senderNameInputTextfield.showCancelButton(true)
        hideTooltip()
    }
    
    func senderNameInputTextfieldDidEndEditing() {
        guard let inputText = senderNameInputTextfield.getInputText() else { return }
        
        if inputText.isEmpty {
            senderNameInputTextfield.setInputText(text: "")
            senderNameInputTextfield.showClearButton(false)
            senderNameInputTextfield.showCancelButton(false)
            senderNameInputTextfield.showKeyboard(false)
            senderNameInputTextfield.setPlaceholderText(placeholderText: "보내는 사람의 이름을 입력하세요.",
                                                        color: UIColor(hex: 0x7B7B7B),
                                                        font: .content(size: 14, weight: .regular))
        }
    }
    
    func senderNameInputTextfieldDidEndEditingOnExit() {
        guard let inputText = senderNameInputTextfield.getInputText() else { return }
        
        if inputText.isNotEmpty {
            senderNameInputTextfield.showCancelButton(false)
            
            senderNameLabel.attributedText = .makeAttributedString(text: "From. \(inputText)",
                                                                   color: .black,
                                                                   font: .letter(size: 16, weight: .bold))
            showSenderInputTextfield(false)
        }
    }
    
    func senderNameInputTextDidChange(text: String) {
        reactor?.action.onNext(.senderNameTextDidChange(text: text))
        
        if !text.isEmpty {
            senderNameInputTextfield.showClearButton(true)
        }
    }
    
    func senderNameInputTextfieldCancelButtonDidTap() {
        
        senderNameInputTextfield.setInputText(text: "")
        senderNameInputTextfield.showClearButton(false)
        senderNameInputTextfield.showCancelButton(false)
        senderNameInputTextfield.showKeyboard(false)
        senderNameInputTextfield.setPlaceholderText(placeholderText: "편지를 보내는 사람의 이름을 입력하세요.",
                                                    color: UIColor(hex: 0x7B7B7B),
                                                    font: UIFont.content(size: 14, weight: .regular))
    }
    
    func senderNameInputTextfieldClearButtonDidTap() {
        senderNameInputTextfield.setInputText(text: "")
        senderNameInputTextfield.showKeyboard(true)
        reactor?.action.onNext(.senderNameTextDidChange(text: ""))
    }
}


extension MailWritingController: LetterContentInputTextViewDelegate {
    func inputTextDidChange(text: String) {
        reactor?.action.onNext(.letterContentsTextDidChange(text: text))
    }
    
    func inputTextViewDidBeginEditing() {
        hideTooltip()
        inputTextView.showInputTextView(true)
    }
    
    func inputTextViewDidEndEditing() {
        if inputTextView.getInputText().isEmpty {
            inputTextView.showInputTextView(false)
        }
    }
}


extension MailWritingController: RecipientNamePlaceholderViewDelegate {
    func recipientNamePlaceholderViewDidTap() {
        recipientNameSearchBar.becomeFirstResponder()  // 검색창 포커스 유지
    }
    
    func newAvatarCreationButtonDidTap() {
        reactor?.action.onNext(.showAvatarSettingController)
    }
}


extension MailWritingController: AutoCompletedNameCellDelegate {
    func autoCompletedNameCellDidTap(cellIndex: Int) {
        guard let filteredAvatars = reactor?.currentState.filteredAvatarInfos else { return }
        
        let selectedAvatar = filteredAvatars[cellIndex]
        
        reactor?.action.onNext(.changeSelectedAvatar(avatar: selectedAvatar))
        
        recipientNameSearchBar.setSearchText(text: selectedAvatar.name)
        
        recipientNameLabel.attributedText = .makeAttributedString(text: "To. \(selectedAvatar.name)",
                                                                  color: .black,
                                                                  font: .letter(size: 16, weight: .bold))
        showRecipientSearchBar(false)
    }
}


extension MailWritingController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 45)
    }
}
