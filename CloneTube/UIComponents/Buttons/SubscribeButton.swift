//
//  SubscribeButton.swift
//  CloneTube
//
//  Created by George Partskhaladze on 25.10.25.
//

import UIKit

final class SubscribeButton: UIButton {

    init(title: String = "Subscribe") {
        super.init(frame: .zero)
        setup(title: title)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup(title: String) {
        var config = UIButton.Configuration.filled()
        config.title = title
        config.baseBackgroundColor = UIColor.systemRed
        config.baseForegroundColor = .white
        config.cornerStyle = .medium
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.titleAlignment = .center
        
        self.configuration = config
        self.translatesAutoresizingMaskIntoConstraints = false
    }
}
