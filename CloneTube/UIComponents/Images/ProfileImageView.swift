//
//  ProfileImageView.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

import UIKit

class ProfileImageView: UIImageView {
    
    private enum Layout {
        static let imageSize: CGFloat = 36
    }
    
    let placeholderImage = UIImage(named: ImageAssets.profilePlaceholder.rawValue)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        clipsToBounds = true
        layer.cornerRadius = Layout.imageSize / 2
        image = placeholderImage
    }
    
}
