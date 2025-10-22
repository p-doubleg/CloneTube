//
//  TabBarItem.swift
//  CloneTube
//
//  Created by George Partskhaladze on 22.10.25.
//

import UIKit

enum TabBarItem: CaseIterable {
    case home, shorts, addVideo, subscriptions, library
    
    var title: String? {
        switch self {
        case .home: return "Home"
        case .shorts: return "Shorts"
        case .addVideo: return nil
        case .subscriptions: return "Subscriptions"
        case .library: return "Library"
        }
    }
    
    var icon: UIImage? {
        switch self {
        case .home: return UIImage(named: ImageAssets.homeOutline.rawValue)
        case .shorts: return UIImage(named: ImageAssets.shortsOutline.rawValue)
        case .addVideo: return UIImage(named: ImageAssets.addVideoOutline.rawValue)
        case .subscriptions: return UIImage(named:ImageAssets.subscriptionOutline.rawValue)
        case .library: return UIImage(named:ImageAssets.libraryOutline.rawValue)
        }
    }
    
    var selectedIcon: UIImage? {
        switch self {
        case .home: return UIImage(named: ImageAssets.homeFilled.rawValue)
        case .shorts: return nil
        case .addVideo: return nil
        case .subscriptions: return UIImage(named: ImageAssets.subscriptionFilled.rawValue)
        case .library: return UIImage(named: ImageAssets.libraryFilled.rawValue)
        }
    }
    
    var tag: Int {
        switch self {
        case .home: return 0
        case .shorts: return 1
        case .addVideo: return 2
        case .subscriptions: return 3
        case .library: return 4
        }
    }
    
    var imageInsets: UIEdgeInsets {
        switch self {
        case .addVideo: return UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)
        default: return UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        }
    }
    
    var viewController: UIViewController {
        switch self{
        case .home:
            return HomeViewController()
        default:
            return EmptyViewController()
        }
    }
}
