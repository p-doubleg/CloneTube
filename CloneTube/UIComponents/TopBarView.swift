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

final class TopBarView: UIView {
    
    weak var delegate: TopBarViewDelegate?
    
    private struct Layout {
        static let buttonSize: CGFloat = 24
        static let padding: CGFloat = 12
        static let logoSize = CGSize(width: 92, height: 22)
    }
    
    private let youtubeLogo: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: ImageAssets.youtubeLogo.rawValue)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var castButton = makeButton(image: ImageAssets.castIcon.rawValue, action: #selector(castButtonTapped))
    private lazy var notificationButton = makeButton(image: ImageAssets.notificationIcon.rawValue, action: #selector(notificationButtonTapped))
    private lazy var searchButton = makeButton(image: ImageAssets.searchIcon.rawValue, action: #selector(searchButtonTapped))
    private lazy var profileButton = makeButton(image: ImageAssets.profileIcon.rawValue, action: #selector(profileButtonTapped))
    
    private lazy var rightButtons: [UIButton] = [castButton, notificationButton, searchButton, profileButton]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        backgroundColor = .systemBackground
        isUserInteractionEnabled = true
        
        addSubview(youtubeLogo)
        rightButtons.forEach(addSubview)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutComponents()
    }
    
}

private extension TopBarView {
    func layoutComponents() {
        let safeTop = safeAreaInsets.top
        let y = safeTop + Layout.padding
        let buttonSize = Layout.buttonSize
        let padding = Layout.padding
        
        youtubeLogo.frame = CGRect(
            x: padding,
            y: y,
            width: Layout.logoSize.width,
            height: Layout.logoSize.height
        )
        
        var currentX = bounds.maxX - padding - buttonSize
        for button in rightButtons.reversed() {
            button.frame = CGRect(x: currentX, y: y, width: buttonSize, height: buttonSize)
            currentX -= (buttonSize + padding)
        }
    }
    
    func makeButton(image: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: image), for: .normal)
        button.tintColor = .label
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

private extension TopBarView {
    @objc private func castButtonTapped() { delegate?.castButtonTapped() }
    @objc private func notificationButtonTapped() { delegate?.notificationButtonTapped() }
    @objc private func searchButtonTapped() { delegate?.searchButtonTapped() }
    @objc private func profileButtonTapped() { delegate?.profileButtonTapped() }
}
