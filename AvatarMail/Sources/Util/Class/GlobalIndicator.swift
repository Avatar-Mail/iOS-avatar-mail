import UIKit
import Lottie
import SnapKit

public class GlobalIndicator {
    
    public static let shared = GlobalIndicator()
    private var animationView: LottieAnimationView?
    private var backgroundView: UIView?
    private var descriptionLabel: UILabel?
    
    private init() {}
    
    public func show(_ lottieImageName: String, with description: String? = nil) {
        guard backgroundView == nil && animationView == nil else { return }
        
        guard let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first else { return }
        
        backgroundView = UIView().then {
            $0.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        }
        
        animationView = LottieAnimationView(name: lottieImageName).then {
            $0.loopMode = .loop
            $0.contentMode = .scaleAspectFit
        }
        
        
        if let description {
            descriptionLabel = UILabel().then {
                $0.attributedText = .makeAttributedString(text: description,
                                                          color: .white,
                                                          font: .content(size: 16, weight: .regular))
            }
        }
        
        if let backgroundView = backgroundView, let animationView = animationView {
            
            window.addSubViews(
                backgroundView.addSubViews(
                    animationView
                )
            )
            
            backgroundView.snp.makeConstraints { make in
                make.edges.equalTo(window)
            }
            
            animationView.snp.makeConstraints { make in
                make.centerX.equalTo(backgroundView)
                make.centerY.equalTo(backgroundView).offset(-10)
                make.width.height.equalTo(150)
            }
            
            if let descriptionLabel {
                backgroundView.addSubview(descriptionLabel)
                
                descriptionLabel.snp.makeConstraints {
                    $0.centerX.equalToSuperview()
                    $0.top.equalTo(animationView.snp.bottom)
                }
            }
            
            animationView.play()
        }
    }
    
    public func hide() {
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, animations: {
                self.backgroundView?.alpha = 0
            }, completion: { _ in
                self.animationView?.stop()
                self.animationView?.removeFromSuperview()
                self.backgroundView?.removeFromSuperview()
                self.backgroundView = nil
                self.animationView = nil
            })
        }
    }
}
