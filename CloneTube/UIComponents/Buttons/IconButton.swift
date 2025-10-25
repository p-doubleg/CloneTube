//
//  IconButton.swift
//  CloneTube
//
//  Created by George Partskhaladze on 25.10.25.
//

import UIKit

final class IconButton: UIButton {
    
    init(iconName: String) {
        super.init(frame: .zero)
        setIcon(iconName)
        setupAppearance()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setTitle(_ title: String) {
        guard var config = configuration else { return }
        config.attributedTitle = AttributedString(title, attributes: .init([
            .font: UIFont.systemFont(ofSize: 12, weight: .medium),
            .foregroundColor: UIColor.white
        ]))
        configuration = config
    }
    
    private func setIcon(_ iconName: String) {
        var config = UIButton.Configuration.plain()
        config.image = UIImage(named: iconName)
        config.imagePlacement = .top
        config.imagePadding = 6
        config.baseForegroundColor = .white
        config.contentInsets = .zero
        configuration = config
    }
    
    private func setupAppearance() {
        translatesAutoresizingMaskIntoConstraints = false
        contentHorizontalAlignment = .center
        contentVerticalAlignment = .center
        imageView?.contentMode = .scaleAspectFit
        titleLabel?.textAlignment = .center
    }
}
