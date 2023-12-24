//
//  ChatNavgationViewController.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/19.
//

import UIKit

let WindowSizeWillChangNotification = "WindowSizeWillChangNotification"

let ViewSafeAreaInsetsDidChangeNotification = "ViewSafeAreaInsetsDidChangeNotification"

class ChatNavgationViewController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        let _ = ChatSessionsManager.shared
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        NotificationCenter.default.post(
            .init(
                name: .init(WindowSizeWillChangNotification),
                object: nil,
                userInfo: [
                    "oldSize": GlobleStateManager.shared.mainWindow.frame.size,
                    "newSize": size
                ]
            )
        )
    }
    
    override func viewSafeAreaInsetsDidChange() {
        NotificationCenter.default.post(
            .init(
                name: .init(ViewSafeAreaInsetsDidChangeNotification),
                object: nil,
                userInfo: [
                    "safeAreaInsets": GlobleStateManager.shared.mainWindow.safeAreaInsets
                ]
            )
        )
    }

}
