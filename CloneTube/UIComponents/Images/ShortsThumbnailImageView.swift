//
//  ShortsThumbnailImageView.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

import UIKit

class ShortsThumbnailImageView: UIImageView {
    
    let placeholderImage = UIImage(named: ImageAssets.shortsTumbnailPlaceholder.rawValue)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configure() {
        clipsToBounds = true
        image = placeholderImage
        isUserInteractionEnabled = true
    }
    
}
