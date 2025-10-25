//
//  TabBarController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 22.10.25.
//

import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViewControllers()
        configureTabBarAppearance()
    }
}

private extension TabBarViewController {
    
    func setupViewControllers() {
        viewControllers = TabBarItem.allCases.map { createNavController(for: $0) }
    }
    
    func configureTabBarAppearance() {
        tabBar.tintColor = .label
        tabBar.unselectedItemTintColor = .secondaryLabel
        tabBar.backgroundColor = .systemBackground
        tabBar.isTranslucent = false
    }
    
    func createNavController(for item: TabBarItem) -> UINavigationController {
        let viewController = item.viewController
        viewController.tabBarItem = UITabBarItem(
            title: item.title,
            image: item.icon,
            selectedImage: item.selectedIcon
        )
        viewController.tabBarItem.imageInsets = item.imageInsets
        viewController.tabBarItem.tag = item.tag
        
        return UINavigationController(rootViewController: viewController)
    }
}
