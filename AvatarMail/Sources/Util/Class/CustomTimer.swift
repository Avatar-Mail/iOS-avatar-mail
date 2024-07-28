//
//  CustomTimer.swift
//  AvatarMail
//
//  Created by 최지석 on 7/20/24.
//

import Foundation


protocol CustomTimerDelegate: AnyObject {
    func timerUpdated(timerIdentifier: String, elapsedTime: Double)
}

class CustomTimer {
    
    public let identifier: String
    
    weak var delegate: CustomTimerDelegate?
    
    var timer: Timer?
    
    private let timerInterval: Double
    private var elapsedTime: Double = 0

    
    init(identifier: String, interval: Double) {
        self.identifier = identifier
        self.timerInterval = interval
    }
    
    
    public func startTimer() {
        // 초기화
        initializeTimer()
        
        timer = Timer.scheduledTimer(timeInterval: timerInterval,
                                     target: self,
                                     selector: #selector(updateTimer),
                                     userInfo: nil,
                                     repeats: true)
    }

    public func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    public func getElapsedTime() -> Double {
        return elapsedTime
    }
    
    private func initializeTimer() {
        timer?.invalidate()
        timer = nil
        elapsedTime = 0
    }
    
    @objc private func updateTimer() {
        // 이 메서드는 타이머가 동작할 때마다 호출됩니다.
        elapsedTime += timerInterval
    
        delegate?.timerUpdated(timerIdentifier: identifier, elapsedTime: elapsedTime)
    }
}
