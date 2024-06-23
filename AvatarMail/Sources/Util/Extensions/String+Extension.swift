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
                                     fontSize: CGFloat,
                                     fontWeight: UIFont.Weight = .medium,
                                     textAlignment: NSTextAlignment = .left,
                                     lineBreakMode: NSLineBreakMode = .byCharWrapping,
                                     lineBreakStrategy: NSParagraphStyle.LineBreakStrategy = .hangulWordPriority) -> NSAttributedString {
        // 문단 스타일
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = lineBreakMode
        paragraphStyle.lineBreakStrategy = lineBreakStrategy
        paragraphStyle.alignment = textAlignment
        
        // 폰트 속성
        let attributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: color,
            .font: UIFont.systemFont(ofSize: fontSize, weight: fontWeight),
            .paragraphStyle: paragraphStyle
        ]
        
        return NSAttributedString(string: text, attributes: attributes)
    }
}
