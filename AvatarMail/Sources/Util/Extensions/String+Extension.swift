//
//  String+Extension.swift
//  AvatarMail
//
//  Created by 최지석 on 6/23/24.
//

import UIKit

extension NSAttributedString {
    static func makeAttributedString(text: String,
                                     color: UIColor,
                                     font: UIFont,
                                     textAlignment: NSTextAlignment = .left,
                                     lineBreakMode: NSLineBreakMode = .byCharWrapping,
                                     lineBreakStrategy: NSParagraphStyle.LineBreakStrategy = .hangulWordPriority,
                                     lineHeightMultiple: CGFloat = 1.0) -> NSAttributedString {
        // 문단 스타일
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineBreakStrategy = lineBreakStrategy
        paragraphStyle.alignment = textAlignment
        paragraphStyle.lineHeightMultiple = lineHeightMultiple
        
        // 폰트 속성
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: font,
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
