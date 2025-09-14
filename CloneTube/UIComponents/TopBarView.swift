//
//  TopBarView.swift
//  CloneTube
//
//  Created by George Partskhaladze on 27.08.25.
//

import UIKit

protocol TopBarViewDelegate: AnyObject {
    func castButtonTapped()
    func notificationButtonTapped()
    func searchButtonTapped()
    func profileButtonTapped()
}

class TopBarView: UIView {
    
    weak var delegate: TopBarViewDelegate?
    private let youtubeLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.youtubeLogo.rawValue)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let castButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: ImageAssets.castIcon.rawValue), for: .normal)
        button.tintColor = .label
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let notificationButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: ImageAssets.notificationIcon.rawValue), for: .normal)
        button.tintColor = .label
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: ImageAssets.searchIcon.rawValue), for: .normal)
        button.tintColor = .label
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let profileButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: ImageAssets.profileIcon.rawValue), for: .normal)
        button.tintColor = .label
        button.isUserInteractionEnabled = true
        return button
    }()
    
    private let buttonSize: CGFloat = 32
    private let horizontalPadding: CGFloat = 16
    private let buttonSpacing: CGFloat = 16
    private let logoHeight: CGFloat = 24
    private let logoMaxWidth: CGFloat = 120
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = .systemBackground
        isUserInteractionEnabled = true
        
        addSubview(youtubeLogo)
        addSubview(castButton)
        addSubview(notificationButton)
        addSubview(searchButton)
        addSubview(profileButton)
        castButton.addTarget(self, action: #selector(castButtonTapped), for: .touchUpInside)
        notificationButton.addTarget(self, action: #selector(notificationButtonTapped), for: .touchUpInside)
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        profileButton.addTarget(self, action: #selector(profileButtonTapped), for: .touchUpInside)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
//        guard bounds.width > 0 && bounds.height > 0 else { return }
        layoutComponents()
    }
    
    private func layoutComponents() {
        let viewHeight = bounds.height
        let viewWidth = bounds.width
        let safeAreaTop = safeAreaInsets.top
        let centerY = safeAreaTop + (viewHeight - safeAreaTop) / 2
        let rightEdge = viewWidth - horizontalPadding
        
        profileButton.frame = CGRect(
            x: rightEdge - buttonSize,
            y: centerY - (buttonSize / 2),
            width: buttonSize,
            height: buttonSize
        )
        
        searchButton.frame = CGRect(
            x: profileButton.frame.minX - buttonSize - buttonSpacing,
            y: centerY - (buttonSize / 2),
            width: buttonSize,
            height: buttonSize
        )
        
        notificationButton.frame = CGRect(
            x: searchButton.frame.minX - buttonSize - buttonSpacing,
            y: centerY - (buttonSize / 2),
            width: buttonSize,
            height: buttonSize
        )
        
        castButton.frame = CGRect(
            x: notificationButton.frame.minX - buttonSize - buttonSpacing,
            y: centerY - (buttonSize / 2),
            width: buttonSize,
            height: buttonSize
        )
        
        let logoWidth = min(logoMaxWidth, castButton.frame.minX - (horizontalPadding * 2))
        youtubeLogo.frame = CGRect(
            x: horizontalPadding,
            y: centerY - (logoHeight / 2),
            width: logoWidth,
            height: logoHeight
        )
    }
    
    @objc private func castButtonTapped() {
        print("TopBarView: Cast button tapped!")
        delegate?.castButtonTapped()
    }
    
    @objc private func notificationButtonTapped() {
        print("TopBarView: Notification button tapped!")
        delegate?.notificationButtonTapped()
    }
    
    @objc private func searchButtonTapped() {
        print("TopBarView: Search button tapped!")
        delegate?.searchButtonTapped()
    }
    
    @objc private func profileButtonTapped() {
        print("TopBarView: Profile button tapped!")
        delegate?.profileButtonTapped()
    }
}
