//
//  AvatarInfoCell.swift
//  AvatarMail
//
//  Created by 최지석 on 6/16/24.
//

import Foundation
import UIKit
import Then
import RxSwift
import RxCocoa
import SnapKit
import RxGesture

protocol AvatarInfoCellDelegate: AnyObject {
    func avatarInfoCellDidTap(cellIndex: Int)
}


final class AvatarInfoCell: UICollectionViewCell {
    
    static let identifier = "AvatarInfoCell"
    
    private var cellIndex: Int?
    
    private var disposeBag = DisposeBag()
    
    weak var delegate: AvatarInfoCellDelegate?
    
    
    private let nameLabel = UILabel().then {
        $0.font = UIFont.systemFont(ofSize: 16)
        $0.textColor = .black
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeUI() {
        contentView.addSubview(nameLabel)
        
        nameLabel.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(10)
        }
    }
    
    func setData(cellIndex: Int,
                 avatarName: String) {
        self.cellIndex = cellIndex
        nameLabel.text = avatarName
    }
    
    
    func bindUI() {
        contentView.rx.tapGesture()
            .when(.recognized)
            .subscribe(onNext: { [weak self] _ in
                guard let self, let delegate, let cellIndex else { return }
                
                delegate.avatarInfoCellDidTap(cellIndex: cellIndex)
            }).disposed(by: disposeBag)
    }
}

