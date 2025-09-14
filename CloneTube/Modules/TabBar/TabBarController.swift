//
//  TabBarController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 27.08.25.
//

import UIKit

class TabBarController: UITabBarController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Home", image: UIImage(named: ImageAssets.homeFilled.rawValue), tag: 0)
        
        let shortsVS = UINavigationController(rootViewController: EmptyViewController())
        shortsVS.tabBarItem = UITabBarItem(title: "Shorts", image: UIImage(named: ImageAssets.shortsOutline.rawValue), tag: 1)
        
        let addVideoVC = UINavigationController(rootViewController: EmptyViewController())
        addVideoVC.tabBarItem = UITabBarItem(title: nil, image: UIImage(named: ImageAssets.addVideoOutline.rawValue), tag: 2)
        
        let subscriptionsVC = UINavigationController(rootViewController: EmptyViewController())
        subscriptionsVC.tabBarItem = UITabBarItem(title: "Subscriptions", image: UIImage(named: ImageAssets.subscriptionOutline.rawValue), tag: 3)
        
        let libraryVC = UINavigationController(rootViewController: EmptyViewController())
        libraryVC.tabBarItem = UITabBarItem(title: "Library", image: UIImage(named: ImageAssets.libraryOutline.rawValue), tag: 4)

        viewControllers = [homeVC, shortsVS, addVideoVC, subscriptionsVC, libraryVC]
    }
}
