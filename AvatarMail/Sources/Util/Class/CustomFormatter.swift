//
//  DateManager.swift
//  AvatarMail
//
//  Created by 최지석 on 7/28/24.
//

import Foundation

final class CustomFormatter {
    
    public static let shared = CustomFormatter()
    
    let dateFormatter: DateFormatter
    
    private init() {
        self.dateFormatter = DateFormatter()
    }
    
    /// Format: yyyy-MM-dd
    public func getMailDateString(from date: Date) -> String {
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())
        return dateString
    }
}
