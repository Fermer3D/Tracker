////
////  UIColor+Extensions.swift
////  Tracker
////
////  Created by Данил Третьяченко on 14.05.2026.
////
//
//import UIKit
//
//final class UIColorMarshalling {
//    // Конвертируем UIColor в HEX-строку (для сохранения в Core Data)
//    static func hexString(from color: UIColor) -> String {
//        var r: CGFloat = 0
//        var g: CGFloat = 0
//        var b: CGFloat = 0
//        var a: CGFloat = 0
//        color.getRed(&r, green: &g, blue: &b, alpha: &a)
//        return String(format: "#%02x%02x%02x",
//                      Int(r * 255), Int(g * 255), Int(b * 255))
//    }
//
//    // Конвертируем HEX-строку в UIColor (для чтения из Core Data)
//    static func color(from hex: String) -> UIColor {
//        var rgbValue: UInt64 = 0
//        let scanner = Scanner(string: hex)
//        if hex.hasPrefix("#") {
//            scanner.currentIndex = hex.index(after: hex.startIndex)
//        }
//        scanner.scanHexInt64(&rgbValue)
//        return UIColor(
//            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
//            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
//            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
//            alpha: 1.0
//        )
//    }
//}
