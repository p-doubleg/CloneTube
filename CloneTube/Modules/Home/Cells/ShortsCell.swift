//
//  ShortsCell.swift
//  CloneTube
//
//  Created by George Partskhaladze on 24.10.25.
//

import UIKit

protocol ShortsCellDelegate: AnyObject {
    func didTapMoreButton(in cell: ShortsCell)
}

final class ShortsCell: UICollectionViewCell {
    
    static let reuseID = "ShortsCell"
    weak var delegate: ShortsCellDelegate?
    
    private let thumbnailImageView = ShortsThumbnailImageView(frame: .zero)
    private let titleLabel = UILabel()
    private let viewsLabel = UILabel()
    private let moreButton = UIButton(type: .system)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        configureLayout()
    }
    
    func configure(with video: Video) {
        titleLabel.text = video.title
        viewsLabel.text = video.formattedViewCount
    }
}

private extension ShortsCell {
    func configureUI() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        [
            thumbnailImageView,
            titleLabel,
            viewsLabel,
            moreButton
        ].forEach {
            contentView.addSubview($0)
        }
        
        setupTitleLabel()
        setupViewsLabel()
        setupMoreButton()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 12, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 1
    }
    
    func setupViewsLabel() {
        viewsLabel.font = .systemFont(ofSize: 10)
        viewsLabel.textColor = .white
    }
    
    
    func setupMoreButton() {
        moreButton.setImage(UIImage(named: ImageAssets.moreVertcal.rawValue), for: .normal)
        moreButton.tintColor = .secondaryLabel
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }
}

private extension ShortsCell {
    func configureLayout() {

        let width = contentView.bounds.width
        let thumbnailHeight = width / Layout.thumbnailAspectRatio
        
        thumbnailImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: thumbnailHeight
        )
        
        moreButton.frame = CGRect(
            x: width - Layout.horizontalPadding - Layout.moreButtonSize,
            y: Layout.verticalPadding,
            width: Layout.moreButtonSize,
            height: Layout.moreButtonSize
        )
        
        let viewsLabelHeight = viewsLabel.intrinsicContentSize.height
        viewsLabel.frame = CGRect(
            x: Layout.horizontalPadding,
            y: contentView.bounds.height - Layout.verticalPadding - viewsLabelHeight,
            width: width - Layout.horizontalPadding * 2,
            height: viewsLabelHeight
        )
        
        let titleLabelHeight = titleLabel.intrinsicContentSize.height
        titleLabel.frame = CGRect(
            x: Layout.horizontalPadding,
            y: viewsLabel.frame.minY - Layout.verticalPadding - titleLabelHeight,
            width: width - Layout.horizontalPadding * 2,
            height: titleLabelHeight + Layout.verticalPadding
        )
        
    }
}

private extension ShortsCell {
    @objc func didTapMoreButton() {
        delegate?.didTapMoreButton(in: self)
    }
}

private extension ShortsCell {
    enum Layout {
        static let thumbnailAspectRatio: CGFloat = 9 / 16
        static let horizontalPadding: CGFloat = 8
        static let verticalPadding: CGFloat = 12
        static let moreButtonSize: CGFloat = 24
    }
}
