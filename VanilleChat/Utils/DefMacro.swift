//
//  DefMacro.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/2/5.
//

import UIKit

@_exported import SnapKit
///沙盒DOC地址
let docPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last ?? ""

///屏幕宽高
let SCREEN_WIDTH = UIScreen.main.bounds.width
let SCREEN_HEIGHT = UIScreen.main.bounds.height

/// 判断是否为刘海屏
var isiPhoneX: Bool {
    guard #available(iOS 11.0, *) else {
        return false
    }
    return UIApplication.shared.windows[0].safeAreaInsets.bottom > 0
}

/// iPhone X顶部部多余的高度
let IPHONEX_TH:CGFloat = UIApplication.shared.windows[0].safeAreaInsets.top
/// iPhone X底部多余的高度
let IPHONEX_BH:CGFloat = UIApplication.shared.windows[0].safeAreaInsets.bottom
/// 状态栏高度 44.0 20.0
let StatusBarHeight: CGFloat = UIApplication.shared.statusBarFrame.size.height
/// 系统导航条高度
let NavBarHeight: CGFloat = 44.0
/// 导航栏高度(导航条和状态栏总高度)
let NavPlusStatusH: CGFloat = (StatusBarHeight + NavBarHeight)
/// tabbar高度
let TabBarHeight: CGFloat = 49.0
/// tabbar和底部安全区总高度
let TabBarPlusBH: CGFloat = TabBarHeight + IPHONEX_BH


/// 基于iPhone6的屏宽比例
let Scale_iPhone6: CGFloat = SCREEN_WIDTH/375.0

/// 尺寸适配 以iPhone6为基准
/// - Parameter cgfNum: 传入iPhone6设计下的宽高
/// - Returns: 返回适配后的宽高
func WidthScale(_ cgfNum: CGFloat) -> CGFloat {
    return CGFloat(cgfNum * Scale_iPhone6)
}

///角度转换
func angleToRadian(_ angle: Double)->CGFloat {
    return CGFloat(angle/Double(180.0) * Double.pi)
}

/// 根据十六进制数生成颜色 HEXCOLOR(h:0xe6e6e6,alpha:0.8)
/// - Parameters:
///   - h: 十六进制整数
///   - alpha: 透明度 0~1
/// - Returns: 返回UIColor
func HEXCOLOR(h:Int,alpha:CGFloat) ->UIColor {
    return RGBCOLOR(r: CGFloat(((h)>>16) & 0xFF), g: CGFloat(((h)>>8) & 0xFF), b: CGFloat((h) & 0xFF),alpha: alpha)
}

///根据R,G,B生成颜色
func RGBCOLOR(r:CGFloat,g:CGFloat,b:CGFloat,alpha:CGFloat) -> UIColor {
    return UIColor.init(red: r/255.0, green: g/255.0, blue: b/255.0, alpha: alpha)
}

/// 获取一段两种颜色的文本
/// 颜色部分使用十六进制
/// - Parameters:
///     - str: 文本字符串
///     - sColor: 其他部分的颜色
///     - dColor: 选中部分的颜色
///     - start: 选中部分开始的位置
///     - length: 选中部分的长度
func GET_ATTRIBUTE_STR(WithString str : String, sColor : Int, dColor : Int, start: Int, length : Int ) -> NSMutableAttributedString {
    let atrriStr = NSMutableAttributedString.init(string: str)
    atrriStr.addAttribute(NSAttributedString.Key.foregroundColor, value: HEXCOLOR(h: sColor, alpha: 1.0), range: NSRange.init(location:0, length: start))
    atrriStr.addAttribute(NSAttributedString.Key.foregroundColor, value: HEXCOLOR(h: dColor, alpha: 1.0), range: NSRange.init(location:start, length: length))
    atrriStr.addAttribute(NSAttributedString.Key.foregroundColor, value: HEXCOLOR(h: sColor, alpha: 1.0), range: NSRange.init(location:start + length, length: str.count - start - length))
    return atrriStr
}

/// 系统版本
let IOS_VERSION = UIDevice.current.systemVersion._bridgeToObjectiveC().doubleValue
/// 是否是真机
func ISIPHONE() -> Bool {
    #if TARGET_OS_IPHONE
        return true
    #endif
    #if TARGET_IPHONE_SIMULATOR
        return false
    #endif
    return false
}

// MARK: - DEBUG模式下打印(Swift)
func Dprint(filePath: String = #file, rowCount: Int = #line) {
    #if DEBUG
        let fileName = (filePath as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        print("class:" + fileName + "  line:" + "\(rowCount)" + "\n")
    #endif
}
func Dprint<T>(_ message: T, filePath: String = #file, rowCount: Int = #line) {
    #if DEBUG
        let fileName = (filePath as NSString).lastPathComponent.replacingOccurrences(of: ".swift", with: "")
        print("class:" + fileName + "  line:" + "\(rowCount)" + "  \(message)" + "\n")
    #endif
}

enum NetworkReachabilityStatus {
    case ethernetOrWiFi
    case cellular
    case notReachable
}

var netWordState: NetworkReachabilityStatus = .notReachable

//func getNetState(completed: @escaping (NetworkReachabilityStatus)->()){
//    var manager: NetworkReachabilityManager?
//    manager = NetworkReachabilityManager(host: "www.apple.com")
//    manager?.startListening { status in
//        print("网络状态: \(status)")
//        if status == .reachable(.ethernetOrWiFi) { //WIFI
//            completed(.ethernetOrWiFi)
//        } else if status == .reachable(.cellular) { // 蜂窝网络
//            completed(.cellular)
//        } else if status == .notReachable { // 无网络
//            completed(.notReachable)
//        } else { // 其他
//
//        }
//    }
//}

