//
//  TimerManager.swift
//  AvatarMail
//
//  Created by 최지석 on 7/20/24.
//

import Foundation


protocol CustomTimerDelegate: AnyObject {
    func timerUpdated(seconds: Double)
}

class CustomTimer {
    
    weak var delegate: CustomTimerDelegate?
    
    var timer: Timer?
    
    private let timerInterval: Double = 0.01
    private var seconds: Double = 0.0

    init() {}
    
    public func startTimer() {
        // 초기화
        timer?.invalidate()
        timer = nil
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }
    

    @objc private func updateTimer() {
        // 이 메서드는 타이머가 동작할 때마다 호출됩니다.
        seconds += timerInterval
        print(seconds)
        // print("Timer Progress: \(seconds) 초")
        delegate?.timerUpdated(seconds: seconds)
    }

    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}
