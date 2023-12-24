//
//  LJToastView.swift
//  LearnJapanese
//
//  Created by 唐星宇 on 2020/8/11.
//  Copyright © 2020 唐星宇. All rights reserved.
//

import UIKit

class LJToastView: UIView {
    private static var _sharedInstance: LJToastView?
    
    var task: ((Bool)->())?

    private override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("初始化失败")
    }
    
    /// 单例
    ///
    /// - Returns: 单例对象
    class func shared() -> LJToastView {
        guard let instance = _sharedInstance else {
            let view = LJToastView(frame: .zero)
            _sharedInstance = view
            view.backgroundColor = .darkGray
            return _sharedInstance!
        }
        instance.layer.cornerRadius = WidthScale(10)
        instance.layer.shadowOffset = CGSize(width: WidthScale(5), height: WidthScale(5))
        instance.layer.shadowRadius = WidthScale(5)
        instance.layer.shadowOpacity = 1.0
        instance.layer.shadowColor = UIColor.black.withAlphaComponent(0.6).cgColor
        return instance
    }

}
