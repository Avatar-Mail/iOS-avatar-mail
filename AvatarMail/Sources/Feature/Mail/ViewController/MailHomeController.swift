//
//  MailHomeController.swift
//  AvatarMail
//
//  Created by 최지석 on 6/15/24.
//

import Foundation
import UIKit
import Then
import SnapKit
import RxSwift
import RxCocoa
import ReactorKit


class MailHomeController: UIViewController, View {
    
    typealias Reactor = MailHomeReactor

    var disposeBag = DisposeBag()
    
    
    private let pageTitleLabel = UILabel().then {
        $0.text = "나만의 우편함"
        $0.font = UIFont.systemFont(ofSize: 28, weight: .bold)
    }
    
    private let mailboxImageView = UIImageView().then {
        $0.contentMode = .scaleAspectFill
    }
    
    private let checkMailButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xADABAB)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("메일함 확인하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
    private let writeMailButton = UIButton().then {
        $0.backgroundColor = UIColor(hex: 0xF8554A)
        $0.clipsToBounds = true
        $0.layer.cornerRadius = 10
        $0.setTitle("메일 작성하기", for: .normal)
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        $0.tintColor = .white
        
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOffset = CGSize(width: 0, height: 2)
        $0.layer.shadowOpacity = 0.5
        $0.layer.shadowRadius = 4
        $0.layer.masksToBounds = false
    }
    
    init(
        reactor: MailHomeReactor
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        reactor?.action.onNext(.checkRepliedMailExists)
    }
    
    
    private func makeUI() {
        view.backgroundColor = .white
        
        view.addSubViews(
            pageTitleLabel,
            mailboxImageView,
            checkMailButton,
            writeMailButton
        )
    
        // title label
        pageTitleLabel.snp.makeConstraints {
            $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(35)
            $0.left.equalToSuperview().inset(20)
        }
        
        // mailbox image
        mailboxImageView.image = UIImage(named: "mailbox_img")
        mailboxImageView.snp.makeConstraints {
            $0.top.equalTo(pageTitleLabel.snp.bottom).offset(30)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(490)
            $0.width.equalTo(273)
        }
        
        // write mail button
        writeMailButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(273)
            $0.bottom.equalToSuperview().offset(-(tabBarController?.tabBar.frame.height ?? 90) - 10)
            $0.centerX.equalToSuperview()
        }
        
        // check mail button
        checkMailButton.snp.makeConstraints {
            $0.height.equalTo(60)
            $0.width.equalTo(273)
            $0.bottom.equalTo(writeMailButton.snp.top).offset(-10)
            $0.centerX.equalToSuperview()
        }
    }
    
    
    func bind(reactor: MailHomeReactor) {
        checkMailButton.rx.tap
            .filter { [weak self] in
                guard let self else { return false }
                return self.reactor?.currentState.repliedMailExists == true
            }
            .map { Reactor.Action.showRepliedMailController }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        writeMailButton.rx.tap
            .map { Reactor.Action.showMailWritingController }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        // states
        reactor.state.map(\.repliedMailExists)
            .distinctUntilChanged()
            .filter { $0 }
            .bind { [weak self] _ in
                guard let self else { return }
                self.checkMailButton.backgroundColor = UIColor(hex: 0xF8554A)
            }.disposed(by: disposeBag)
    }
}

