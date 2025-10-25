//
//  FiltersScrollView.swift
//  CloneTube
//
//  Created by George Partskhaladze on 24.10.25.
//

import UIKit

protocol FiltersScrollViewDelegate: AnyObject {
    func onFilterSelected(_ filter: VideoCategory)
}

final class FiltersScrollView: UIView {
    
    private let scrollView = UIScrollView()
    private var buttons: [FilterButton] = []
    private var selectedButton: FilterButton?
    
    weak var delegate: FiltersScrollViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureScrollView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        layoutScrollView()
    }
    
    func configure(with filters: [VideoCategory]) {
        buttons.forEach { $0.removeFromSuperview() }
        buttons.removeAll()
        
        filters.forEach { category in
            let button = FilterButton(filter: category)
            button.addTarget(self, action: #selector(filterButtonTapped(_:)), for: .touchUpInside)
            
            scrollView.addSubview(button)
            buttons.append(button)
            
            if category == .all {
                updateSelection(for: button)
            }
        }
        
        setNeedsLayout()
    }
}

private extension FiltersScrollView {
    
    func configureScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.alwaysBounceHorizontal = true
        addSubview(scrollView)
    }
    
    func layoutScrollView() {
        scrollView.frame = bounds
        
        var xOffset: CGFloat = 16
        let verticalPadding: CGFloat = 12
        let buttonHeight = bounds.height - verticalPadding * 2
        
        for button in buttons {
            let fittingSize = button.sizeThatFits(
                CGSize(width: .greatestFiniteMagnitude, height: buttonHeight)
            )
            let buttonWidth = fittingSize.width
            button.frame = CGRect(
                x: xOffset,
                y: (bounds.height - buttonHeight) / 2,
                width: buttonWidth,
                height: buttonHeight
            )
            xOffset += buttonWidth + 8
        }
        
        scrollView.contentSize = CGSize(width: xOffset, height: bounds.height)
    }
}

private extension FiltersScrollView {
    
    @objc func filterButtonTapped(_ sender: FilterButton) {
        guard sender !== selectedButton else { return }
        updateSelection(for: sender)
        delegate?.onFilterSelected(sender.filter)
    }
    
    func updateSelection(for newSelectedButton: FilterButton) {
        selectedButton?.isSelected = false
        newSelectedButton.isSelected = true
        selectedButton = newSelectedButton
    }
}
