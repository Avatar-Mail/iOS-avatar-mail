//
//  MailListController.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import UIKit
import ReactorKit
import Then
import RxCocoa
import RxSwift
import RxGesture

class MailListController: UIViewController, View {

    typealias Reactor = MailListReactor

    var disposeBag = DisposeBag()

    private let topNavigation = TopNavigation().then {
        $0.setTitle(titleText: "나의 편지함", titleColor: .white, font: .content(size: 18, weight: .semibold))
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    private let topContainerView = UIStackView().then {
        $0.axis = .vertical
        $0.alignment = .fill
        $0.isHidden = true
    }
    
    private let filterButtonContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.applyShadow(offset: CGSize(width: 0, height: 5), color: .lightGray, opacity: 0.5, radius: 3)
    }
    
    private let filterMainContainerView = UIView().then {
        $0.backgroundColor = .clear
        $0.isHidden = true
    }
    
    private let filterAvatarSearchBarContainerView = UIView().then {
        $0.backgroundColor = .white
    }
    
    private let filterAvatarSearchBar = SearchBar().then {
        $0.setPlaceholderText(placeholderText: "아바타의 이름을 입력하세요.",
                              color: UIColor(hex: 0x7B7B7B),
                              font: .content(size: 14, weight: .regular))
        $0.setLeftIcon(iconName: "magnifyingglass",
                       iconSize: CGSize(width: 16, height: 16),
                       iconColor: UIColor(hex:0x7B7B7B),
                       configuration: nil)
        $0.setBackgroundColor(colors: [UIColor(hex:0xF1F1F1)])
        $0.setBorder(width: 0, colors: [])
    }
    
    let spacer = UIView().then {
        $0.backgroundColor = UIColor(hex: 0xEEEEEE)
    }
    
    let checkboxContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.applyCornerRadius(10, maskedCorners: [.layerMinXMaxYCorner])
        $0.applyShadow(offset: CGSize(width: 0, height: 5), color: .lightGray, opacity: 0.5, radius: 3)
    }
    
    let sentMailCheckbox = CustomCheckbox(selectedIcon: "checkbox_checked",
                                          unSelectedIcon: "checkbox_un_checked").then {
        $0.setTitle(with: "보낸 메일")
        $0.setIsChecked(false)
    }
    
    let receivedMailCheckbox = CustomCheckbox(selectedIcon: "checkbox_checked",
                                            unSelectedIcon: "checkbox_un_checked").then {
        $0.setTitle(with: "받은 메일")
        $0.setIsChecked(false)
    }
    
    // 필터 확장 버튼
    private let filterExtendButton = UIButton().then {
        var config = UIButton.Configuration.plain()
        
        // AttributedString을 사용하여 타이틀 설정
        var title = AttributedString("필터")
        title.font = UIFont.content(size: 16, weight: .regular)
        title.foregroundColor = UIColor(hex: 0x7B7B7B)
        config.attributedTitle = title
        config.titlePadding = 0
        
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .regular, scale: .default)
        let image = UIImage(systemName: "slider.horizontal.3", withConfiguration: imageConfiguration)
        config.image = image
        config.imagePadding = 3
        config.imagePlacement = .trailing
        
        config.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
        
        $0.configuration = config
        $0.tintColor = UIColor(hex: 0x7B7B7B)
    }
    
    private let upArrowButtonContainerView = UIView().then {
        $0.backgroundColor = .white
        $0.applyCornerRadius(10, maskedCorners: [.layerMinXMaxYCorner, .layerMaxXMaxYCorner])
        $0.applyShadow(offset: CGSize(width: 0, height: 5), color: .lightGray, opacity: 0.5, radius: 3)
    }
    
    private let upArrowButton = UIButton().then {
        $0.setImage(UIImage(systemName: "chevron.up"), for: .normal)
        $0.tintColor = .gray
    }
    
    private let filterPlaceholderView = FilterPlaceholderView()

    private let mailCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 16
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: UIScreen.main.bounds.width - 32, height: 180)
        layout.sectionInset = UIEdgeInsets(top: 16 + 54, left: 0, bottom: 16, right: 0)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(RepliedMailCell.self, forCellWithReuseIdentifier: RepliedMailCell.identifier)
        collectionView.backgroundColor = UIColor(hex: 0xEFEFEF)
        collectionView.isHidden = true
        return collectionView
    }()


    init(reactor: MailListReactor) {
        super.init(nibName: nil, bundle: nil)
        self.reactor = reactor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        makeUI()
        setDelegates()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        reactor?.action.onNext(.getAllMails)
        
        tabBarController?.hideTabBar(isHidden: true, animated: true)
    }

    override func viewDidLayoutSubviews() {
        topNavigation.setTopNavigationBackgroundGradientColor(colors: [UIColor(hex: 0x538EFE),
                                                                       UIColor(hex: 0x403DD2)])
    }
    
    private func setDelegates() {
        topNavigation.delegate = self
        filterAvatarSearchBar.delegate = self
        sentMailCheckbox.delegate = self
        receivedMailCheckbox.delegate = self
        filterPlaceholderView.delegate = self
    }

    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            
            topNavigation,
            
            topContainerView.addArrangedSubViews(
                filterButtonContainerView.addSubViews(
                    filterExtendButton
                ),
                
                filterMainContainerView.addSubViews(
                    filterAvatarSearchBarContainerView.addSubViews(
                        filterAvatarSearchBar
                    ),
                    
                    spacer,
                    
                    checkboxContainerView.addSubViews(
                        sentMailCheckbox,
                        receivedMailCheckbox
                    ),
                    
                    upArrowButtonContainerView.addSubViews(
                        upArrowButton
                    )
                )
            ),
            
            filterPlaceholderView,
            
            mailCollectionView
        )

        topNavigation.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
        }
        
        topContainerView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }

        filterButtonContainerView.snp.makeConstraints {
            $0.height.equalTo(54)
        }
        
        filterExtendButton.snp.makeConstraints {
            $0.centerY.equalToSuperview()
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        filterAvatarSearchBarContainerView.snp.makeConstraints {
            $0.top.leading.trailing.equalToSuperview()
            $0.height.equalTo(80)
        }
        
        filterAvatarSearchBar.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(16)
        }
        
        spacer.snp.makeConstraints {
            $0.height.equalTo(1)
            $0.top.equalTo(filterAvatarSearchBar.snp.bottom).offset(16)
            $0.leading.trailing.equalToSuperview().inset(16)
        }
        
        checkboxContainerView.snp.makeConstraints {
            $0.height.equalTo(54)
            $0.top.equalTo(spacer.snp.bottom)
            $0.leading.trailing.equalToSuperview()
        }
        
        sentMailCheckbox.snp.makeConstraints {
            $0.leading.equalToSuperview().inset(16)
            $0.centerY.equalToSuperview()
        }
        
        receivedMailCheckbox.snp.makeConstraints {
            $0.leading.equalTo(sentMailCheckbox.snp.trailing).offset(10)
            $0.centerY.equalToSuperview()
        }
        
        upArrowButtonContainerView.snp.makeConstraints {
            $0.top.equalTo(checkboxContainerView.snp.bottom)
            $0.trailing.bottom.equalToSuperview()
            $0.width.equalTo(56)
            $0.height.equalTo(36)
        }
        
        upArrowButton.snp.makeConstraints {
            $0.center.equalToSuperview()
            $0.size.equalTo(28)
        }
        
        filterPlaceholderView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }

        mailCollectionView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom)
            $0.leading.bottom.trailing.equalToSuperview()
        }

        view.bringSubviewToFront(topContainerView)
    }

    func bind(reactor: MailListReactor) {
        filterExtendButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                filterMainContainerView.isHidden = false
                filterButtonContainerView.isHidden = true
            })
            .disposed(by: disposeBag)
        
        upArrowButton.rx.tap
            .asDriver()
            .drive(onNext: { [weak self] in
                guard let self = self else { return }
                filterMainContainerView.isHidden = true
                filterButtonContainerView.isHidden = false
                
                filterAvatarSearchBar.setLeftIcon(iconName: "magnifyingglass",
                                                  iconSize: CGSize(width: 16, height: 16),
                                                  iconColor: UIColor(hex:0x7B7B7B),
                                                  configuration: nil)
                filterAvatarSearchBar.setBackgroundColor(colors: [UIColor(hex:0xF1F1F1)])
                filterAvatarSearchBar.setBorder(width: 0, colors: [])
                
                filterAvatarSearchBar.showKeyboard(false)
            })
            .disposed(by: disposeBag)
        
        reactor.state.map { $0.mails }
            .distinctUntilChanged()
            .bind { [weak self] mails in
                guard let self else { return }
                
                if mails.isNotEmpty {
                    filterPlaceholderView.placeholderAnimationView.isHidden = true
                    topContainerView.isHidden = false
                    mailCollectionView.isHidden = false
                } else {
                    filterPlaceholderView.placeholderAnimationView.isHidden = false
                    topContainerView.isHidden = true
                    mailCollectionView.isHidden = true
                }
            }


        reactor.state.map { $0.filteredMails }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind(to: mailCollectionView.rx.items(cellIdentifier: RepliedMailCell.identifier,
                                                  cellType: RepliedMailCell.self)) { index, mail, cell in
                cell.setData(mail: mail)
                cell.delegate = self
            }
            .disposed(by: disposeBag)

        
        reactor.pulse(\.$toastMessage)
            .observe(on: MainScheduler.asyncInstance)
            .compactMap { $0 }
            .filterNil()
            .bind { toastMessage in
                ToastHelper.shared.makeToast2(message: toastMessage, duration: 2.0, position: .bottom)
            }
            .disposed(by: disposeBag)
        
        
        reactor.state.map { $0.isSentFromUser }
            .distinctUntilChanged()
            .observe(on: MainScheduler.instance)
            .bind { [weak self] isSentFromUser in
                guard let self else { return }
                
                if let isSentFromUser {
                    sentMailCheckbox.setIsChecked(isSentFromUser ? true : false)
                    receivedMailCheckbox.setIsChecked(!isSentFromUser ? true : false)
                } else {
                    sentMailCheckbox.setIsChecked(false)
                    receivedMailCheckbox.setIsChecked(false)
                }
            }
            .disposed(by: disposeBag)
    }
}

extension MailListController: TopNavigationDelegate {
    func topNavigationLeftSideIconDidTap() {
        reactor?.action.onNext(.closeMailListController)
    }
    
    func topNavigationRightSidePrimaryIconDidTap() {}
    
    func topNavigationRightSideSecondaryIconDidTap() {}
    
    func topNavigationRightSideTextButtonDidTap() {}
}


extension MailListController: RepliedMailCellDelegate {
    func repliedMailCellDidTap(mail: Mail) {
        reactor?.action.onNext(.showRepliedMailController(mail: mail))
    }
}



extension MailListController: CustomCheckboxDelegate {
    func checkboxDidTap(checkBox: CustomCheckbox) {
        switch checkBox {
        case sentMailCheckbox:
            reactor?.action.onNext(.sentMailCheckboxDidTap)
        case receivedMailCheckbox:
            reactor?.action.onNext(.receivedMailCheckboxDidTap)
        default:
            break
        }
    }
}


extension MailListController: SearchBarDelegate {
    func searchTextFieldDidBeginEditing() {
        filterAvatarSearchBar.setLeftIcon(iconName: "magnifyingglass",
                                          iconSize: CGSize(width: 16, height: 16),
                                          iconColor: .darkGray,
                                          configuration: nil)
        filterAvatarSearchBar.setBackgroundColor(colors: [.white])
        filterAvatarSearchBar.setBorder(width: 1, colors: [.darkGray])
        
        filterAvatarSearchBar.showKeyboard(true)
    }
    
    func searchTextFieldDidEndEditing() {
        filterAvatarSearchBar.setLeftIcon(iconName: "magnifyingglass",
                                          iconSize: CGSize(width: 16, height: 16),
                                          iconColor: UIColor(hex:0x7B7B7B),
                                          configuration: nil)
        filterAvatarSearchBar.setBackgroundColor(colors: [UIColor(hex:0xF1F1F1)])
        filterAvatarSearchBar.setBorder(width: 0, colors: [])
    }
    
    func searchTextDidChange(text: String) {
        reactor?.action.onNext(.searchTextDidChange(text))
        
        if !text.isEmpty {
            filterAvatarSearchBar.showClearButton(true)
        } else {
            filterAvatarSearchBar.showClearButton(false)
        }
    }
    
    func searchTextFieldDidReturn() { }
    
    func cancelButtonDidTap() { }
    
    func clearButtonDidTap() {
        filterAvatarSearchBar.setSearchText(text: "")
        reactor?.action.onNext(.searchTextDidChange(""))
        
        filterAvatarSearchBar.setLeftIcon(iconName: "magnifyingglass",
                                          iconSize: CGSize(width: 16, height: 16),
                                          iconColor: .darkGray,
                                          configuration: nil)
        filterAvatarSearchBar.setBackgroundColor(colors: [.white])
        filterAvatarSearchBar.setBorder(width: 1, colors: [.darkGray])
        
        filterAvatarSearchBar.showKeyboard(true)
    }
}


extension MailListController: FilterPlaceholderViewDelegate {
    func writeNewMailButtonDidTap() {
        reactor?.action.onNext(.openMailWritingController)
    }
}
