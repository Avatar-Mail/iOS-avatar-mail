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
    
    private let recipientNameSearchBar = SearchBar().then {
        $0.setPlaceholderText(placeholderText: "편지를 보낼 아바타를 찾아보세요.",
                              color: UIColor(hex: 0x7B7B7B),
                              fontSize: 14,
                              fontWeight: .regular)
        $0.setLeftIcon(iconName: "magnifyingglass",
                       iconSize: CGSize(width: 16, height: 16),
                       iconColor: UIColor(hex:0x7B7B7B),
                       configuration: nil)
        $0.setBackgroundColor(colors: [UIColor(hex:0xF1F1F1)])
        $0.setBorder(width: 0, colors: [])
    }
    
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
    
    private let letterScrollView = UIScrollView()
    
    private let scrollContentView = UIView()
    
    private let recipientNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    private let recipientNameLabel = UILabel()
    
    private let recipientNameCorrectionIcon = UIImageView().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfiguration)
        $0.image = image
        $0.tintColor = UIColor(hex:0xA0A0A0)
    }
    
    private let senderNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    private let senderNameLabel = UITextField().then {
        $0.text = "From."
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
    }
    
    private let senderNameCorrectionIcon = UIImageView().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "square.and.pencil", withConfiguration: imageConfiguration)
        $0.image = image
        $0.tintColor = UIColor(hex:0xA0A0A0)
    }
    
    private let inputTextView = LetterContentInputTextView()
    
    private let textCountLabel = UILabel().then {
        $0.text = "0 | 300자"
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.textColor = UIColor(hex:0x7B7B7B)
        
        $0.isHidden = true
    }
    
    private let clearTextButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("초기화")
        title.font = UIFont.systemFont(ofSize: 16, weight: .regular)
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
        recipientNameSearchBar.delegate = self
        recipientNamePlaceholderView.delegate = self
        inputTextView.delegate = self
        recipientNameAutoCompleteCollectionView.delegate = self
        
        self.hideKeyboardWhenTappedAround()
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
            topNavigation,
            
            tooltipView,
            clearTextButton,
            
            letterContainerView.addSubViews(
                letterOutlineView.addSubViews(
                    letterScrollView.addSubViews(
                        scrollContentView.addSubViews(
                            // 수신인 (To.)
                            recipientNameStackView.addArrangedSubViews(
                                recipientNameLabel,
                                recipientNameCorrectionIcon
                            ),
                            recipientNameSearchBar,
                            
                            // 편지 내용
                            inputTextView,
                            
                            // 발신인 (From.)
                            senderNameStackView.addArrangedSubViews(
                                senderNameLabel,
                                senderNameCorrectionIcon
                            )
                        )
                    ),
                    recipientNameAutoCompleteContainerView.addSubViews(
                        recipientNameAutoCompleteCollectionView,
                        recipientNamePlaceholderView
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
        
        // 발신인 (From.)
        senderNameStackView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
        }
        
        // 내용
        inputTextView.snp.makeConstraints {
            $0.top.equalTo(recipientNameSearchBar.snp.bottom).offset(10)
            $0.bottom.equalTo(senderNameStackView.snp.top).offset(-10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        // 수신인 (To.)
        recipientNameSearchBar.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(43)
        }
        
        recipientNameStackView.snp.makeConstraints {
            $0.leading.equalToSuperview()
            $0.centerY.equalTo(recipientNameSearchBar)
        }
        
        recipientNameAutoCompleteContainerView.snp.makeConstraints {
            $0.top.equalTo(recipientNameSearchBar.snp.bottom).offset(10)
            $0.horizontalEdges.bottom.equalToSuperview().inset(20)
        }
        
        recipientNameAutoCompleteCollectionView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        recipientNamePlaceholderView.snp.makeConstraints {
            $0.edges.equalToSuperview()
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

//
//        senderNameTextField.rx.text
//            .map { Reactor.Action.senderNameTextDidChange(text: $0 ?? "") }
//            .bind(to: reactor.action)
//            .disposed(by: disposeBag)
//
//        senderNameTextField.rx.controlEvent(.editingDidBegin)
//            .bind {
//                if reactor.currentState.isTooltipHidden == false {
//                    reactor.action.onNext(.hideToolTip)
//                }
//            }
//            .disposed(by: disposeBag)
        
        sendMailButton.rx.tap
            .map { Reactor.Action.sendButtonDipTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        clearTextButton.rx.tap
            .bind { [weak self] in
                guard let self else { return }
//                self.recipientNameTextField.text = ""
//                sself.inputTextView.text = ""
//                self.senderNameTextField.text = ""
            }
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
    
    
    public func hideTooltip() {
        if reactor?.currentState.isTooltipHidden == false {
            reactor?.action.onNext(.hideToolTip)
        }
        topNavigation.setTitle(titleText: "편지 작성하기", titleColor: .white, fontSize: 20, fontWeight: .semibold)
    }
    
    
    public func showRecipientNameAutoCompleteContainerView(_ shouldShow: Bool) {
        if shouldShow {
            recipientNameAutoCompleteContainerView.isHidden = false
        } else {
            recipientNameAutoCompleteContainerView.isHidden = true
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
                                                      fontSize: 14,
                                                      fontWeight: .regular)
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
            recipientNameSearchBar.setPlaceholderText(placeholderText: "편지를 보낼 아바타를 찾아보세요.",
                                                      color: UIColor(hex: 0x7B7B7B),
                                                      fontSize: 14,
                                                      fontWeight: .regular)
            showRecipientNameAutoCompleteContainerView(false)
        }
    }
    
    func clearButtonDidTap() {
        recipientNameSearchBar.setSearchText(text: "")
        recipientNameSearchBar.showKeyboard(true)
//        reactor?.action.onNext(.syncQueryToSearchTextFieldInput(text: ""))
//        showAvatarSearchView(true)
//        searchBar.showKeyboard(true)
//        topNavigation.setTitle(titleText: "아바타 찾기", titleColor: .white, fontSize: 20, fontWeight: .semibold)
    }
}


extension MailWritingController: LetterContentInputTextViewDelegate {
    func inputTextDidChange(text: String) {
        reactor?.action.onNext(.inputTextDidChange(text: text))
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
        
        recipientNameLabel.attributedText = .makeAttributedString(text: "To. \((selectedAvatar.name))",
                                                                  color: .black,
                                                                  fontSize: 16,
                                                                  fontWeight: .regular)
        showRecipientSearchBar(false)
    }
}


extension MailWritingController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 45)
    }
}
