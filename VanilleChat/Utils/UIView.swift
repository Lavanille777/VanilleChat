//
//  UIView.swift
//  LJWallHaven
//
//  Created by 唐星宇 on 2021/3/3.
//

import UIKit

extension UIView {
    
    func makeToast(_ str: String){
        DispatchQueue.main.async {
            for view in LJToastView.shared().subviews{
                view.removeFromSuperview()
            }
            
            let mesL: UILabel = UILabel()
            mesL.text = str
            mesL.font = UIFont.systemFont(ofSize: WidthScale(16))
            mesL.textColor = .label
            mesL.numberOfLines = 0
            LJToastView.shared().addSubview(mesL)
            
            mesL.snp.makeConstraints { (make) in
                make.left.top.right.bottom.equalToSuperview().inset(WidthScale(10))
            }
            
            if LJToastView.shared().superview == nil{
                self.addSubview(LJToastView.shared())
                LJToastView.shared().snp.remakeConstraints { (make) in
                    make.bottom.equalToSuperview().inset(WidthScale(80) + IPHONEX_BH)
                    make.centerX.equalToSuperview()
                    make.left.greaterThanOrEqualToSuperview().inset(WidthScale(20))
                    make.right.lessThanOrEqualToSuperview().inset(WidthScale(20))
                }
                
                LJToastView.shared().layoutIfNeeded()
                LJToastView.shared().alpha = 0
                LJToastView.shared().transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
            
            if let curTask = LJToastView.shared().task{
                DispatchQueue.main.cancel(curTask)
            }
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                LJToastView.shared().alpha = 1
                LJToastView.shared().transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { (finished) in
                if finished{
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                        LJToastView.shared().transform = CGAffineTransform(scaleX: 1, y: 1)
                    }) { (finished) in
                        if finished{
                            if let curTask = LJToastView.shared().task{
                                DispatchQueue.main.cancel(curTask)
                            }
                            let task = DispatchQueue.main.delay(2) {
                                LJToastView.shared().task = nil
                                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                                    LJToastView.shared().alpha = 0
                                    LJToastView.shared().transform = CGAffineTransform(translationX: SCREEN_WIDTH, y: 0)
                                }) { (finished) in
                                    LJToastView.shared().removeFromSuperview()
                                }
                            }
                            LJToastView.shared().task = task
                        }else{
                            Dprint("动画未结束")
                        }
                    }
                }
            }
        }
    }
    
    class func makeToast(_ str: String){
        DispatchQueue.main.async {
            for view in LJToastView.shared().subviews{
                view.removeFromSuperview()
            }
            
            let mesL: UILabel = UILabel()
            mesL.text = str
            mesL.font = UIFont.systemFont(ofSize: WidthScale(16))
            mesL.textColor = .label
            mesL.numberOfLines = 0
            LJToastView.shared().addSubview(mesL)
            
            mesL.snp.makeConstraints { (make) in
                make.left.top.right.bottom.equalToSuperview().inset(WidthScale(10))
            }
            
            if LJToastView.shared().superview == nil{
                UIApplication.shared.windows[0].addSubview(LJToastView.shared())
                LJToastView.shared().snp.remakeConstraints { (make) in
                    make.bottom.equalToSuperview().inset(WidthScale(80) + IPHONEX_BH)
                    make.centerX.equalToSuperview()
                    make.left.greaterThanOrEqualToSuperview().inset(WidthScale(20))
                    make.right.lessThanOrEqualToSuperview().inset(WidthScale(20))
                }
                
                LJToastView.shared().layoutIfNeeded()
                LJToastView.shared().alpha = 0
                LJToastView.shared().transform = CGAffineTransform(scaleX: 0.5, y: 0.5)
            }
            
            if let curTask = LJToastView.shared().task{
                DispatchQueue.main.cancel(curTask)
            }
            
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseIn, animations: {
                LJToastView.shared().alpha = 1
                LJToastView.shared().transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
            }) { (finished) in
                if finished{
                    UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseOut, animations: {
                        LJToastView.shared().transform = CGAffineTransform(scaleX: 1, y: 1)
                    }) { (finished) in
                        if finished{
                            if let curTask = LJToastView.shared().task{
                                DispatchQueue.main.cancel(curTask)
                            }
                            let task = DispatchQueue.main.delay(2) {
                                LJToastView.shared().task = nil
                                UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseInOut, animations: {
                                    LJToastView.shared().alpha = 0
                                    LJToastView.shared().transform = CGAffineTransform(translationX: SCREEN_WIDTH, y: 0)
                                }) { (finished) in
                                    LJToastView.shared().removeFromSuperview()
                                }
                            }
                            LJToastView.shared().task = task
                        }else{
                            Dprint("动画未结束")
                        }
                    }
                }
            }
        }
    }
    
    private struct AssociatedKeys {
        static var timerKey = 100
    }
    
    var timer: Timer? {
        get{
            return objc_getAssociatedObject(self,  &AssociatedKeys.timerKey) as? Timer
        }
        set{
            objc_setAssociatedObject(self, &AssociatedKeys.timerKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    @discardableResult func addPressAnimation() -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(pressAction))
        longPress.minimumPressDuration = 0
        longPress.cancelsTouchesInView = false
        if let self = self as? UIGestureRecognizerDelegate{
            longPress.delegate = self
        }
        self.addGestureRecognizer(longPress)
        return longPress
    }
    
    @discardableResult func addOncePressAnimation() -> UILongPressGestureRecognizer {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(oncePressAction))
        longPress.minimumPressDuration = 0
        longPress.cancelsTouchesInView = false
        if let self = self as? UIGestureRecognizerDelegate{
            longPress.delegate = self
        }
        self.addGestureRecognizer(longPress)
        return longPress
    }
    
    @objc func oncePressAction(_ sender: UILongPressGestureRecognizer){
        if sender.state == .began {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.transform = CGAffineTransform.init(scaleX: 0.9, y: 0.9)
            }, completion: nil)
            
        }
        
        if sender.state == .changed || sender.state == .ended || sender.state == .cancelled{
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }, completion: nil)
        }
    }
    
    @objc func pressAction(_ sender: UILongPressGestureRecognizer){
        var scale: CGFloat = 1
        if sender.state == .began {
            timer = Timer.scheduledTimer(withTimeInterval: 0.017, repeats: true, block: { (timer) in
                scale -= 0.01
                if scale > 0.9{
                    self.transform = CGAffineTransform.init(scaleX: scale, y: scale)
                }
            })
            timer?.fire()
        }
        if sender.state == .changed || sender.state == .ended || sender.state == .cancelled{
            UIView.animate(withDuration: 0.1) {
                self.transform = CGAffineTransform.init(scaleX: 1, y: 1)
            }
            if let timer = timer{
                timer.invalidate()
            }
            timer = nil
        }
    }
    

}


extension UIViewController {
    /// 获取顶层视图控制器
    ///
    /// - Returns: 顶层视图控制器
    @objc class func getTopViewController() -> UIViewController{
        
        let rootVC = UIApplication.shared.windows[0].rootViewController
        
        var topVC = rootVC
        
        while topVC?.presentedViewController != nil {
            
            topVC = topVC?.presentedViewController
            
        }
        
        return topVC!
    }
    
    /// 获取当前视图控制器
    ///
    /// - Returns: 当前视图控制器
    @objc class func getCurrentViewCtrl()->UIViewController{
        var window = UIApplication.shared.keyWindow  //.keywindow must be used from main thread only
        if window?.windowLevel != UIWindow.Level.normal {  //.windowLevel
            let windows = UIApplication.shared.windows
            for subWin in windows {
                if subWin.windowLevel == UIWindow.Level.normal {
                    window = subWin
                    break
                }
            }
        }
        if let frontView = window?.subviews.first{   //.subviews
            let nextResponder = frontView.next  //.next
            if let tabbarCtrl = nextResponder as? UITabBarController{
                if let selectedCtrl = tabbarCtrl.selectedViewController{
                    if let navCtrl = selectedCtrl as? UINavigationController {
                        return UIViewController.getCurrentViewCtrl(navCtrl: navCtrl)
                    }else{
                        return selectedCtrl
                    }
                }else{
                    if let firstCtrl = tabbarCtrl.viewControllers?.first{
                        return firstCtrl
                    }else{
                        return tabbarCtrl
                    }
                }
            }else if let navCtrl = nextResponder as? UINavigationController{
                return UIViewController.getCurrentViewCtrl(navCtrl: navCtrl)
            }else if let viewCtrl = nextResponder as? UIViewController{
                return viewCtrl
            }
        }
        let windowCtrl = window?.rootViewController
        if let tabbarCtrl = windowCtrl as? UITabBarController{
            if let selectedCtrl = tabbarCtrl.selectedViewController {
                if let navCtrl = selectedCtrl as? UINavigationController {
                    return UIViewController.getCurrentViewCtrl(navCtrl: navCtrl)
                }else{
                    return selectedCtrl
                }
            }else{
                if let firstCtrl = tabbarCtrl.viewControllers?.first{
                    return firstCtrl
                }else{
                    return tabbarCtrl
                }
            }
        }else if let navCtrl = windowCtrl as? UINavigationController{
            return UIViewController.getCurrentViewCtrl(navCtrl: navCtrl)
        }else{
            return windowCtrl!
        }
    }
    
    // MARK: - private
    fileprivate class func getCurrentViewCtrl(navCtrl:UINavigationController) -> UIViewController {
        if let visibleCtrl = navCtrl.visibleViewController{
            if let tabbarCtrl = visibleCtrl as? UITabBarController{
                return UIViewController.getCurrentViewCtrl(subTabbarCtrl:tabbarCtrl)
            }else{
                return visibleCtrl
            }
        }else{
            if let firstCtrl = navCtrl.viewControllers.first{
                return firstCtrl
            }else{
                return navCtrl
            }
        }
    }
    
    fileprivate class func getCurrentViewCtrl(subTabbarCtrl:UITabBarController) -> UIViewController {
        if let selectedCtrl = subTabbarCtrl.selectedViewController{
            if let subNavCtrl = selectedCtrl as? UINavigationController {
                if let subVisibleCtrl = subNavCtrl.visibleViewController{
                    return subVisibleCtrl
                }else{
                    if let firstCtrl = subNavCtrl.viewControllers.first{
                        return firstCtrl
                    }else{
                        return subNavCtrl
                    }
                }
            }else{
                return selectedCtrl
            }
        }else{
            if let firstCtrl = subTabbarCtrl.viewControllers?.first{
                return firstCtrl
            }else{
                return subTabbarCtrl
            }
        }
    }

}
