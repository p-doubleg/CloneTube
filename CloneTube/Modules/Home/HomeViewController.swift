//
//  HomeViewController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 27.08.25.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private let topBarView = TopBarView()
    private let topBarContentHeight: CGFloat = 28
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
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
        let safeTop = view.safeAreaInsets.top
        topBarView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: topBarContentHeight + safeTop
        )
    }
}

extension HomeViewController: TopBarViewDelegate {
    func castButtonTapped() { print("Cast button tapped") }
    func notificationButtonTapped() { print("Notification button tapped") }
    func searchButtonTapped() { print("Search button tapped") }
    func profileButtonTapped() { print("Profile button tapped") }
}
