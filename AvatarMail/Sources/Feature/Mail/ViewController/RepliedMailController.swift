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
    
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "나의 메일함"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    private let letterContainerView = UIView().then {
        $0.backgroundColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
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
    
    private let recipientNameTextLabel = UILabel().then {
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
    
    private let senderNameTextLabel = UILabel().then {
        $0.backgroundColor = UIColor(hex: 0xF8F8F8)
        $0.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
        $0.textAlignment = .center
        $0.layer.cornerRadius = 5
        $0.clipsToBounds = true
        $0.layoutMargins = UIEdgeInsets(top: 0, left: 8, bottom: 0, right: 8)
    }

    
    private let mailContentLabel = UILabel().then {
        $0.numberOfLines = 0
        $0.font = UIFont.systemFont(ofSize: 18, weight: .regular)
    }
    
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
        
        reactor?.action.onNext(.getRepliedMail)
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            pageTitleLabel,
            letterContainerView.addSubViews(
                letterOutlineView.addSubViews(
                    letterScrollView.addSubViews(
                        scrollContentView.addSubViews(
                            // 수신인 (To.)
                            recipientNameStackView.addArrangedSubViews(
                                recipientTitleTextLabel,
                                recipientNameTextLabel
                            ),
                            
                            // 편지 내용
                            mailContentLabel,
                            
                            // 발신인 (From.)
                            senderNameStackView.addArrangedSubViews(
                                senderTitleTextLabel,
                                senderNameTextLabel
                            )
                        )
                    )
                )
            ),
            replyButton
        )
        
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        replyButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-120)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.height.equalTo(60)
        }
        
        letterContainerView.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(50)
            $0.bottom.equalTo(replyButton.snp.top).offset(-50)
            $0.horizontalEdges.equalToSuperview().inset(50)
        }
        
        letterOutlineView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        
        letterScrollView.snp.makeConstraints {
            $0.edges.equalToSuperview().inset(8)
        }
        
        scrollContentView.snp.makeConstraints {
            $0.edges.equalToSuperview()
            $0.width.equalTo(letterScrollView.snp.width) // 수정된 부분
        }
        
        // 수신인 (To.)
        recipientNameStackView.snp.makeConstraints {
            $0.top.leading.equalToSuperview()
        }
        
        recipientNameTextLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(50)
            $0.height.equalTo(25)
        }
        
        // 발신인 (From.)
        senderNameStackView.snp.makeConstraints {
            $0.bottom.trailing.equalToSuperview()
        }
        
        senderNameTextLabel.snp.makeConstraints {
            $0.width.greaterThanOrEqualTo(50)
            $0.height.equalTo(25)
        }
        
        // 내용
        mailContentLabel.snp.makeConstraints {
            $0.top.equalTo(recipientNameStackView.snp.bottom).offset(10)
            $0.bottom.equalTo(senderNameStackView.snp.top).offset(-10)
            $0.horizontalEdges.equalToSuperview()
        }
    }
    
    
    func bind(reactor: RepliedMailReactor) {
        replyButton.rx.tap
            .map { Reactor.Action.replyButtonDidTap }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // states
        reactor.state.map(\.repliedMail)
            .observe(on: MainScheduler.instance)
            .filterNil()
            .distinctUntilChanged()
            .bind { [weak self] message in
                guard let self else { return }
                
                self.recipientNameTextLabel.text = message.recipientName
                self.mailContentLabel.text = message.content
                self.senderNameTextLabel.text = message.senderName
                
            }.disposed(by: disposeBag)
    }
}

