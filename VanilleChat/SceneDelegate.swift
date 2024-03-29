//
//  SceneDelegate.swift
//  VanilleChat
//
//  Created by lavanille on 2023/12/19.
//

import UIKit
import IQKeyboardManagerSwift
import SideMenu

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let scene = (scene as? UIWindowScene) else { return }
        
#if targetEnvironment(macCatalyst)
        if let titlebar = scene.titlebar {
            titlebar.titleVisibility = .hidden
            titlebar.toolbar = nil
        }
#endif
        
        let window = UIWindow(windowScene: scene)
        self.window = window
        GlobleStateManager.shared.mainWindow = window
        window.backgroundColor = .white
        window.makeKeyAndVisible()
        // Define the menus
        let leftMenuNavigationController = SideMenuNavigationController(rootViewController: SideMenuViewController())
        leftMenuNavigationController.blurEffectStyle = .systemUltraThinMaterial
        leftMenuNavigationController.menuWidth = 280
        let style: SideMenuPresentationStyle = .menuSlideIn
        style.presentingEndAlpha = 0.8
        style.presentingScaleFactor = 0.98
        style.onTopShadowOpacity = 0.3
        style.onTopShadowOffset = CGSize(width: 3, height: 0)
        style.onTopShadowRadius = 3
        style.onTopShadowColor = .black
        SideMenuManager.default.leftMenuNavigationController = leftMenuNavigationController
        
        leftMenuNavigationController.presentationStyle = style
        

        let chatVC = ChatViewController()
        GlobleStateManager.shared.rootController = ChatNavgationViewController(rootViewController: chatVC)
//        let chatVC = ChatNavgationViewController(rootViewController: ChatViewController())
        window.rootViewController = GlobleStateManager.shared.rootController
//        let rightMenuNavigationController = SideMenuNavigationController(rootViewController: YourViewController)
//        SideMenuManager.default.rightMenuNavigationController = rightMenuNavigationController

        // Setup gestures: the left and/or right menus must be set up (above) for these to work.
        // Note that these continue to work on the Navigation Controller independent of the view controller it displays!
        SideMenuManager.default.addPanGestureToPresent(toView: chatVC.view)
//        SideMenuManager.default.addScreenEdgePanGesturesToPresent(toView: chatVC.view)

        // (Optional) Prevent status bar area from turning black when menu appears:
        leftMenuNavigationController.statusBarEndAlpha = 0
        // Copy all settings to the other menu
//        rightMenuNavigationController.settings = leftMenuNavigationController.settings
        
        
        
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

