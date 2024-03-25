//
//  SceneDelegate.swift
//  Virtual Tourist
//
//  Created by Leena Alsayari on 6/2/23.
//
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        // If this scene's self.window is nil then set a new UIWindow object to it.
        self.window = self.window ?? UIWindow()

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let delegate = UIApplication.shared.delegate as! AppDelegate
        // Get rootViewController
        let rootViewController = self.window?.rootViewController as! UINavigationController
        // Get top view for root controller
        let travelMapViewController = rootViewController.topViewController as! TravelMapViewController
        // set the dataController to the delegate data controller
        travelMapViewController.dataController = delegate.dataController

        // Make this scene's window be visible.
        self.window!.makeKeyAndVisible()
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }


    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

