//
//  GlobalDialog.swift
//  AvatarMail
//
//  Created by 최지석 on 9/17/24.
//

import UIKit
import SnapKit
import RxSwift
import RxCocoa

public class GlobalDialog {
    
    public struct GlobalDialogButtonInfo {
        let title: String
        let titleColor: UIColor
        let backgroundColor: UIColor
        let borderColor: UIColor?
        let buttonHandler: (()->())?
    }

    
    public static let shared = GlobalDialog()
    private var backgroundView: UIView?
    private var containerView: UIView?
    
    var disposeBag = DisposeBag()
    
    private init() {}
    
    public func show(title: String?,
                     description: String?,
                     buttonInfos: GlobalDialogButtonInfo...) {
        
        guard backgroundView == nil && containerView == nil else { return }
        
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        backgroundView = UIView().then {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        }
        
        containerView = UIView().then {
            $0.backgroundColor = .white
            $0.applyCornerRadius(15)
        }
        
        if let backgroundView, let containerView {
            window.addSubViews(
                backgroundView.addSubViews(
                    containerView
                )
            )
            
            backgroundView.snp.makeConstraints { make in
                make.edges.equalTo(window)
            }
            
            containerView.snp.makeConstraints {
                $0.width.equalToSuperview().inset(16)
                $0.center.equalToSuperview()
            }
            
            let stackView = UIStackView().then {
                $0.axis = .vertical
                $0.spacing = 10
            }
            
            let titleLabel = UILabel().then {
                $0.numberOfLines = 0
                $0.isHidden = true
            }
            
            let descriptionLabel = UILabel().then {
                $0.numberOfLines = 0
                $0.isHidden = true
            }
            
            let buttonStackView = UIStackView().then {
                $0.axis = .horizontal
                $0.distribution = .fillEqually
                $0.spacing = 12
            }
            
            containerView.addSubViews(
                stackView.addArrangedSubViews(
                    titleLabel,
                    descriptionLabel,
                    buttonStackView
                )
            )
            
            stackView.snp.makeConstraints {
                $0.verticalEdges.equalToSuperview().inset(16)
                $0.horizontalEdges.equalToSuperview().inset(20)
            }
            
            if let title {
                titleLabel.isHidden = false
                titleLabel.attributedText = .makeAttributedString(text: title, color: .black, font: .content(size: 20, weight: .semibold))
                
                stackView.snp.remakeConstraints {
                    $0.top.equalToSuperview().inset(24)
                    $0.horizontalEdges.equalToSuperview().inset(20)
                    $0.bottom.equalToSuperview().inset(16)
                }
            }
            
            if let description {
                descriptionLabel.isHidden = false
                descriptionLabel.attributedText = .makeAttributedString(text: description, color: .lightGray, font: .content(size: 16, weight: .regular))
                
                descriptionLabel.snp.makeConstraints {
                    $0.height.greaterThanOrEqualTo(54)
                }
                
                stackView.setCustomSpacing(4, after: descriptionLabel)
            }
            
            for buttonInfo in buttonInfos {
                let button = UIButton().then {
                    $0.backgroundColor = buttonInfo.backgroundColor
                    $0.setButtonTitle(title: buttonInfo.title,
                                      color: buttonInfo.titleColor,
                                      font: .content(size: 18, weight: .semibold))
                    $0.applyCornerRadius(10)
                    
                    if let borderColor = buttonInfo.borderColor {
                        $0.applyBorder(width: 2, color: borderColor)
                    }
                }
                
                button.snp.makeConstraints {
                    $0.height.equalTo(54)
                }
                
                buttonStackView.addArrangedSubview(button)
                
                // 버튼 클릭 바인딩
                button.rx.tap
                    .bind {
                        buttonInfo.buttonHandler?()
                    }.disposed(by: disposeBag)
                
            }
        }
    }
    
    public func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 0
            }, completion: { [weak self] _ in
                guard let self else { return }
                self.containerView?.removeFromSuperview()
                self.backgroundView?.removeFromSuperview()
                self.containerView = nil
                self.backgroundView = nil
                
                disposeBag = DisposeBag()  // button에 걸린 바인딩 제거
            })
        }
    }
}
