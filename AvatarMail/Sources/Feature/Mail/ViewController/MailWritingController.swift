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
    
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "메일 작성하기"
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
        $0.textColor = UIColor(hex:0xD8D8D8)
    }
    
    private let clearTextButton = UIButton().then {
        $0.setTitle("전체삭제", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        $0.setTitleColor(UIColor(hex:0xD8D8D8), for: .normal)
        
        $0.setImage(UIImage(systemName: "xmark"), for: .normal)
        $0.tintColor = UIColor(hex:0xD8D8D8)
        $0.semanticContentAttribute = .forceRightToLeft
    }
    
    private let sendButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xF8554A)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("메일 보내기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
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
        self.hideKeyboardWhenTappedAround()
    }
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            pageTitleLabel,
            
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
            
            sendButton
        )
        
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        sendButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-120)
            $0.horizontalEdges.equalToSuperview().inset(50)
            $0.height.equalTo(60)
        }
        
        letterContainerView.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(50)
            $0.bottom.equalTo(sendButton.snp.top).offset(-50)
            $0.horizontalEdges.equalToSuperview().inset(50)
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
        
        recipientNameTextField.rx.text
            .map { Reactor.Action.recipientNameTextDidChange(text: $0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        senderNameTextField.rx.text
            .map { Reactor.Action.senderNameTextDidChange(text: $0 ?? "") }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        sendButton.rx.tap
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

