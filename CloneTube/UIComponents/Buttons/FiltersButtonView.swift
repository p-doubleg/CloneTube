//
//  FiltersButtonView.swift
//  CloneTube
//
//  Created by George Partskhaladze on 24.10.25.
//

import UIKit

final class FilterButton: UIButton {
    
    let filter: VideoCategory
    
    private let normalColor = UIColor.systemGray6
    private let selectedColor = UIColor.darkGray
    private let normalTextColor = UIColor.label
    private let selectedTextColor = UIColor.white
    
    override var isSelected: Bool {
        didSet { updateAppearance() }
    }
    
    init(filter: VideoCategory) {
        self.filter = filter
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

private extension FilterButton {
    
    func setupUI() {
        var config = UIButton.Configuration.plain()
        config.baseForegroundColor = normalTextColor
        config.background.backgroundColor = normalColor
        config.cornerStyle = .capsule
        config.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
        config.background.strokeColor = UIColor.systemGray2
        config.background.strokeWidth = 1
        
        let font = UIFont.systemFont(ofSize: 14, weight: .medium)
        let attributedTitle = AttributedString(filter.rawValue, attributes: AttributeContainer([.font: font]))
        config.attributedTitle = attributedTitle

        configuration = config
    }
    
    func updateAppearance() {
        guard var config = configuration else { return }
        config.background.backgroundColor = isSelected ? selectedColor : normalColor
        config.baseForegroundColor = isSelected ? selectedTextColor : normalTextColor
        configuration = config
    }
    
}
