//
//  UIFont.swift
//  AvatarMail
//
//  Created by 최지석 on 8/4/24.
//

import Foundation
import UIKit

public extension UIFont {
    
    static let chosunKm = "ChosunKm"
    static let chosunSm = "ChosunSm"
    
    static let pretendardBlack = "Pretendard-Black"
    static let pretendardExtraBold = "Pretendard-ExtraBold"
    static let pretendardBold = "Pretendard-Bold"
    static let pretendardSemiBold = "Pretendard-SemiBold"
    static let pretendardMedium = "Pretendard-Medium"
    static let pretendardRegular = "Pretendard-Regular"
    static let pretendardLight = "Pretendard-Light"
    static let pretendardExtraLight = "Pretendard-ExtraLight"
    static let pretendardThin = "Pretendard-Thin"
    
    
    static func letter(size: CGFloat, weight: LetterFontWeight) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: size, weight: weight.rawValue)
        
        switch weight {
        case .bold:
            return UIFont(name: UIFont.chosunKm, size: size) ?? defaultFont
        case .medium:
            return UIFont(name: UIFont.chosunSm, size: size) ?? defaultFont
        }
    }
    
    
    static func content(size: CGFloat, weight: ContentFontWeight) -> UIFont {
        let defaultFont = UIFont.systemFont(ofSize: size, weight: weight.rawValue)
        
        switch weight {
        case .black:
            return UIFont(name: UIFont.pretendardBlack, size: size) ?? defaultFont
        case .extrabold:
            return UIFont(name: UIFont.pretendardExtraBold, size: size) ?? defaultFont
        case .bold:
            return UIFont(name: UIFont.pretendardBold, size: size) ?? defaultFont
        case .semibold:
            return UIFont(name: UIFont.pretendardSemiBold, size: size) ?? defaultFont
        case .medium:
            return UIFont(name: UIFont.pretendardMedium, size: size) ?? defaultFont
        case .regular:
            return UIFont(name: UIFont.pretendardRegular, size: size) ?? defaultFont
        case .light:
            return UIFont(name: UIFont.pretendardLight, size: size) ?? defaultFont
        case .extralight:
            return UIFont(name: UIFont.pretendardExtraLight, size: size) ?? defaultFont
        case .thin:
            return UIFont(name: UIFont.pretendardThin, size: size) ?? defaultFont
        }
    }
}


public enum LetterFontWeight: RawRepresentable {
    case bold, medium
    
    public var rawValue: UIFont.Weight {
        switch self {
        case .bold: return UIFont.Weight.bold
        case .medium: return UIFont.Weight.medium
        }
    }
    
    public init?(rawValue: UIFont.Weight) {
        switch rawValue {
        case .bold: self = .bold
        case .medium: self = .medium
        default: self = .medium
        }
    }
}


public enum ContentFontWeight: RawRepresentable {
    case black, extrabold, bold, semibold, medium, regular, light, extralight, thin
    
    public var rawValue: UIFont.Weight {
        switch self {
        case .black: return UIFont.Weight.black
        case .extrabold: return UIFont.Weight.heavy
        case .bold: return UIFont.Weight.bold
        case .semibold: return UIFont.Weight.semibold
        case .medium: return UIFont.Weight.medium
        case .regular: return UIFont.Weight.regular
        case .light: return UIFont.Weight.light
        case .extralight: return UIFont.Weight.thin
        case .thin: return UIFont.Weight.ultraLight
        }
    }
    
    public init?(rawValue: UIFont.Weight) {
        switch rawValue {
        case UIFont.Weight.black: self = .black
        case UIFont.Weight.heavy: self = .extrabold
        case UIFont.Weight.bold: self = .bold
        case UIFont.Weight.semibold: self = .semibold
        case UIFont.Weight.medium: self = .medium
        case UIFont.Weight.regular: self = .regular
        case UIFont.Weight.light: self = .light
        case UIFont.Weight.thin: self = .extralight
        case UIFont.Weight.ultraLight: self = .thin
        default: self = .medium
        }
    }
}
