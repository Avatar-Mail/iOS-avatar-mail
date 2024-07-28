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
        $0.setTitle(titleText: "메일 작성하기", titleColor: .white, fontSize: 18, fontWeight: .semibold)
        $0.setTitleIsHidden(true)
        $0.setLeftIcon(iconName: "arrow.left", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setRightSideSecondaryIcon(iconName: "line.3.horizontal", iconColor: .white, iconSize: CGSize(width: 20, height: 20))
        $0.setTopNavigationBackgroundColor(color: UIColor(hex: 0x4961E6))
        $0.setTopNavigationShadow(shadowHeight: 2)
    }
    
    // 상단 메일 삭제하기 버튼
    private let deleteMailButton = UIButton().then {
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
    
    private let letterScrollView = UIScrollView()
    
    private let scrollContentView = UIView()
    
    // 수신인 (To.) 영역 뷰
    private let recipientNameInputContainerView = UIView()
    
    private let recipientNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 10
        $0.alignment = .center
    }
    
    private let recipientNameLabel = UILabel()
    
    private let playAudioButton = UIImageView().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 16)
        let image = UIImage(systemName: "waveform", withConfiguration: imageConfiguration)
        $0.image = image
        $0.tintColor = UIColor(hex:0xA0A0A0)
        $0.isHidden = true
    }
    
    private let mailContentsView = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16, weight: .regular)
    }
    
    // 발신인 (From.) 영역 뷰
    private let senderNameInputContainerView = UIView()
    
    private let senderNameStackView = UIStackView().then {
        $0.axis = .horizontal
        $0.spacing = 3
    }
    
    private let senderNameLabel = UILabel()
    
    private let replyButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xF8554A)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("답장 작성하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
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
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        
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
                                    // 음성 재생 버튼
                                    playAudioButton
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
            $0.bottom.equalToSuperview().offset(-120)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.height.equalTo(60)
        }
        
        letterContainerView.snp.makeConstraints {
            $0.top.equalTo(topNavigation.snp.bottom).offset(60)
            $0.bottom.lessThanOrEqualTo(replyButton.snp.top).offset(-50).priority(999)
            $0.bottom.equalTo(view.keyboardLayoutGuide.snp.top).offset(-50).priority(1)
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
            $0.leading.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
        
        // 음성 재생 버튼
        playAudioButton.snp.makeConstraints {
            $0.size.equalTo(18)
        }
        
        // 편지 내용
        mailContentsView.snp.makeConstraints {
            $0.top.equalTo(recipientNameInputContainerView.snp.bottom).offset(10)
            $0.bottom.equalTo(senderNameInputContainerView.snp.top).offset(-10)
            $0.horizontalEdges.equalToSuperview()
        }
        
        // 발신인 (From.)
        senderNameInputContainerView.snp.makeConstraints {
            $0.bottom.equalToSuperview()
            $0.horizontalEdges.equalToSuperview()
            $0.height.equalTo(43)
        }
        
        senderNameStackView.snp.makeConstraints {
            $0.trailing.equalToSuperview()
            $0.centerY.equalToSuperview()
        }
    }
    
    
    func bind(reactor: RepliedMailReactor) {
        replyButton.rx.tap
            .map { Reactor.Action.replyButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // states
        reactor.state.map(\.writtenMail)
            .observe(on: MainScheduler.instance)
            .filterNil()
            .distinctUntilChanged()
            .bind { [weak self] mail in
                guard let self else { return }
                
                recipientNameLabel.text = mail.recipientName
                mailContentsView.text = mail.content
                senderNameLabel.text = mail.senderName
                
                if mail.isSentFromUser, let recording = mail.audioRecording {
                    playAudioButton.isHidden = false
                }
                
            }.disposed(by: disposeBag)
    }
}
