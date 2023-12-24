//
//  GlobleStateManager.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/19.
//

import UIKit

class GlobleStateManager: NSObject {
    public static let shared = GlobleStateManager()
    
    var mainWindow: UIWindow!
    
    var keyboardFrame: CGRect = .zero
    
    var isKeyboardShow: Bool = false
    
    var openaiKey: String = ""
    
    var isSideMenuShow: Bool = false
    
    var rootController: UINavigationController?
    
    private override init() {
        super.init()
    }
}
