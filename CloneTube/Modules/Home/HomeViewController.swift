//
//  HomeViewController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 27.08.25.
//

import UIKit

class HomeViewController: UIViewController {
    
    private let topBarView: TopBarView = {
        let view = TopBarView()
        return view
    }()
    
    private let topBarHeight: CGFloat = 44
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutTopBar()
    }
    
    private func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(topBarView)
        topBarView.delegate = self
    }
    
    private func layoutTopBar() {
        let viewWidth = view.bounds.width
        let safeAreaTop = view.safeAreaInsets.top
        
        topBarView.frame = CGRect(
            x: 0,
            y: 0,
            width: viewWidth,
            height: topBarHeight + safeAreaTop
        )
    }
}

extension HomeViewController: TopBarViewDelegate {
    func castButtonTapped() {
        print("Cast button tapped")
    }
    
    func notificationButtonTapped() {
        print("Notification button tapped")
    }
    
    func searchButtonTapped() {
        print("Search button tapped")
    }
    
    func profileButtonTapped() {
        print("Profile button tapped")
    }
}
