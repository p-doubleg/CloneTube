//
//  VideoCell.swift
//  CloneTube
//
//  Created by George Partskhaladze on 23.10.25.
//

import UIKit

protocol VideoCellDelegate: AnyObject {
    func didTapMoreButton(in cell: VideoCell)
}

final class VideoCell: UICollectionViewCell {
    
    static let reuseID = "VideoCell"
    weak var delegate: VideoCellDelegate?
    
    private let thumbnailImageView = ThumbnailImageView(frame: .zero)
    private let profileImageView = ProfileImageView(frame: .zero)
    private let titleLabel = UILabel()
    private let viewsLabel = UILabel()
    private let dateLabel = UILabel()
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
        dateLabel.text = video.timeAgoText
    }
}

private extension VideoCell {
    
    func configureUI() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        [
            thumbnailImageView,
            profileImageView,
            titleLabel,
            viewsLabel,
            dateLabel,
            moreButton
        ].forEach {
            contentView.addSubview($0)
        }
        
        setupTitleLabel()
        setupViewsLabel()
        setupDateLabel()
        setupMoreButton()
    }
    
    func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
    }
    
    func setupViewsLabel() {
        viewsLabel.font = .systemFont(ofSize: 14)
        viewsLabel.textColor = .secondaryLabel
    }
    
    func setupDateLabel() {
        dateLabel.font = .systemFont(ofSize: 14)
        dateLabel.textColor = .secondaryLabel
        dateLabel.textAlignment = .right
    }
    
    func setupMoreButton() {
        moreButton.setImage(UIImage(named: ImageAssets.more.rawValue), for: .normal)
        moreButton.tintColor = .secondaryLabel
        moreButton.addTarget(self, action: #selector(didTapMoreButton), for: .touchUpInside)
    }
}

private extension VideoCell {
    
    func configureLayout() {
        
        let width = contentView.bounds.width
        let thumbnailHeight = width / Layout.thumbnailAspectRatio
        
        thumbnailImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: thumbnailHeight
        )
        
        let yOffset = thumbnailImageView.frame.maxY + Layout.verticalPadding
        
        profileImageView.frame = CGRect(
            x: Layout.horizontalPadding,
            y: yOffset,
            width: Layout.profileImageSize,
            height: Layout.profileImageSize
        )
        
        moreButton.frame = CGRect(
            x: width - Layout.horizontalPadding - Layout.moreButtonSize,
            y: yOffset,
            width: Layout.moreButtonSize,
            height: Layout.moreButtonSize
        )
        
        let textStartX = profileImageView.frame.maxX + Layout.spacing
        let textWidth = moreButton.frame.minX - textStartX - Layout.spacing
        
        titleLabel.frame = CGRect(
            x: textStartX,
            y: yOffset,
            width: textWidth,
            height: Layout.titleHeight
        )
        
        let viewsLabelWidth = viewsLabel.intrinsicContentSize.width
        viewsLabel.frame = CGRect(
            x: textStartX,
            y: titleLabel.frame.maxY + Layout.spacingSmall,
            width: viewsLabelWidth,
            height: Layout.subtitleHeight
        )
        
        let dateLabelWidth = dateLabel.intrinsicContentSize.width
        dateLabel.frame = CGRect(
            x: viewsLabel.frame.maxX + Layout.spacingSmall,
            y: titleLabel.frame.maxY + Layout.spacingSmall,
            width: dateLabelWidth,
            height: Layout.subtitleHeight
        )
    }
}

private extension VideoCell {
    @objc func didTapMoreButton() {
        delegate?.didTapMoreButton(in: self)
    }
}

private extension VideoCell {
    enum Layout {
        static let thumbnailAspectRatio: CGFloat = 16 / 9
        static let horizontalPadding: CGFloat = 12
        static let verticalPadding: CGFloat = 12
        static let spacing: CGFloat = 8
        static let spacingSmall: CGFloat = 4
        static let profileImageSize: CGFloat = 36
        static let moreButtonSize: CGFloat = 24
        static let titleHeight: CGFloat = 20
        static let subtitleHeight: CGFloat = 16
    }
}
