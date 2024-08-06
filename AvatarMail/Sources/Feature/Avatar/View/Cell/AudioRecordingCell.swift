//
//  AudioRecordingCell.swift
//  AvatarMail
//
//  Created by 최지석 on 7/25/24.
//

import UIKit
import SnapKit
import Then
import RxSwift
import RxCocoa


protocol AudioRecordingCellDelegate: AnyObject {
    func playingButtonDidTap(with recording: AudioRecording)
}

final class AudioRecordingCell: UICollectionViewCell {
    
    static let identifier = "AudioRecordingCell"
    
    weak var delegate: AudioRecordingCellDelegate?
    
    var disposeBag = DisposeBag()
    
    enum PlayingButtonInnerShape {
        case triangle
        case rectangle
    }
    
    private let containerView = UIView().then {
        $0.applyCornerRadius(10)
        $0.applyBorder(width: 2, color: UIColor(hex:0xAAAAAA))
    }
    
    private let recordingTitleLabel = UILabel().then {
        $0.text = "Hello world"
        $0.font = UIFont.content(size: 18, weight: .semibold)
        $0.textColor = .black
    }
    
    private let recordedDateLabel = UILabel().then {
        $0.text = "Hello world"
        $0.font = UIFont.content(size: 14, weight: .semibold)
        $0.textColor = UIColor(hex:0xA4A4A4)
    }
    
    private let removeButton = UIButton().then {
        let imageConfiguration = UIImage.SymbolConfiguration(pointSize: 18,
                                                             weight: .regular,
                                                             scale: .default)
        let iconImage = UIImage(systemName: "trash",
                                withConfiguration: imageConfiguration)
        $0.setImage(iconImage, for: .normal)
    }
    
    private let playingButtonInnerShape = UIView().then {
        $0.backgroundColor = UIColor(hex:0x6878F6)
    }
    
    private let playingButton = UIButton().then {
        $0.clipsToBounds = true
        $0.applyCornerRadius(24)
        $0.applyBorder(width: 2, color: UIColor(hex:0xC9C9C9))
    }
    
    private var recording: AudioRecording?
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
   
        makeUI()
        bindUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    private func makeUI() {
        addSubview(
            containerView.addSubViews(
                recordingTitleLabel,
                recordedDateLabel,
                
                removeButton,
                
                playingButtonInnerShape,
                playingButton
            )
        )
        
        containerView.snp.makeConstraints {
            $0.edges.equalToSuperview()
        }
        
        recordingTitleLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(20)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(playingButton.snp.leading).offset(-10)
        }
        
        recordedDateLabel.snp.makeConstraints {
            $0.top.equalTo(recordingTitleLabel.snp.bottom).offset(3)
            $0.leading.equalToSuperview().offset(20)
            $0.trailing.equalTo(playingButton.snp.leading).offset(-10)
        }
        
        removeButton.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-12)
            $0.leading.equalToSuperview().offset(20)
            $0.size.equalTo(18)
        }
        
        playingButton.snp.makeConstraints {
            $0.size.equalTo(48)
            $0.top.equalToSuperview().offset(20)
            $0.trailing.equalToSuperview().offset(-20)
        }
        
        playingButtonInnerShape.snp.makeConstraints {
            $0.size.equalTo(24)
            $0.centerX.equalTo(playingButton.snp.centerX)
            $0.centerY.equalTo(playingButton.snp.centerY)
        }
        
        setPlayingButtonInnerShape(as: .triangle)
    }
    
    public func setPlayingButtonInnerShape(as shape: PlayingButtonInnerShape) {
        var newPath: UIBezierPath
        let newSize: CGSize
        
        switch shape {
        case .triangle:
            newSize = CGSize(width: 10 * sqrt(3), height: 20)
            newPath = UIBezierPath()
            newPath.move(to: CGPoint(x: 0, y: 2))
            newPath.addQuadCurve(to: CGPoint(x: sqrt(3), y: 1), controlPoint: CGPoint(x: sqrt(3)/3, y: 1))
            newPath.addLine(to: CGPoint(x: 9 * sqrt(3), y: 9))
            newPath.addQuadCurve(to: CGPoint(x: 9 * sqrt(3), y: 11), controlPoint: CGPoint(x: 28 * sqrt(3) / 3, y: 10))
            newPath.addLine(to: CGPoint(x: sqrt(3), y: 19))
            newPath.addQuadCurve(to: CGPoint(x: 0, y: 18), controlPoint: CGPoint(x: sqrt(3)/3, y: 19))
            newPath.close()
        case .rectangle:
            newSize = CGSize(width: 18, height: 18)
            newPath = UIBezierPath()
            newPath.move(to: CGPoint(x: 0, y: 2))
            newPath.addQuadCurve(to: CGPoint(x: 2, y: 0), controlPoint: CGPoint(x: 0.5, y: 0.5))
            newPath.addLine(to: CGPoint(x: 16, y: 0))
            newPath.addQuadCurve(to: CGPoint(x: 18, y: 2), controlPoint: CGPoint(x: 17.5, y: 0.5))
            newPath.addLine(to: CGPoint(x: 18, y: 16))
            newPath.addQuadCurve(to: CGPoint(x: 16, y: 18), controlPoint: CGPoint(x: 17.5, y: 17.5))
            newPath.addLine(to: CGPoint(x: 2, y: 18))
            newPath.addQuadCurve(to: CGPoint(x: 0, y: 16), controlPoint: CGPoint(x: 0.5, y: 17.5))
            newPath.close()
        }
        
        let shapeLayer = CAShapeLayer()
        shapeLayer.path = newPath.cgPath

        switch shape {
        case .triangle:
            playingButtonInnerShape.snp.updateConstraints {
                $0.size.equalTo(newSize)
                $0.centerX.equalTo(playingButton.snp.centerX).offset((20 - 10 * sqrt(3)) / 2)
            }
        case .rectangle:
            playingButtonInnerShape.snp.updateConstraints {
                $0.size.equalTo(newSize)
                $0.centerX.equalTo(playingButton.snp.centerX)
            }
        }
        
        layoutIfNeeded()
        
        playingButtonInnerShape.layer.mask = shapeLayer
    }
    
    
    private func bindUI() {
        playingButton.rx.tap
            .bind { [weak self] in
                guard let self, let recording else { return }
                delegate?.playingButtonDidTap(with: recording)
            }
            .disposed(by: disposeBag)
    }
    
    
    public func setData(recording: AudioRecording) {
        self.recording = recording
        
        recordingTitleLabel.text = recording.fileName
        recordedDateLabel.text = CustomFormatter.shared.getMailDateString(from: recording.createdDate)
    }
}
