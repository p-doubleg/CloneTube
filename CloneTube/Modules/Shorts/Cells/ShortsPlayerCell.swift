//
//  ShortsPlayerCell.swift
//  CloneTube
//
//  Created by George Partskhaladze on 25.10.25.
//

import UIKit

protocol ShortsPlayerCellDelegate: AnyObject {
    func didBackButtonTapped(in cell: ShortsPlayerCell)
    func didMoreButtonTapped(in cell: ShortsPlayerCell)
    func didLikeButtonTapped(in cell: ShortsPlayerCell)
    func didDislikeButtonTapped(in cell: ShortsPlayerCell)
    func didCommentsButtonTapped(in cell: ShortsPlayerCell)
    func didShareButtonTapped(in cell: ShortsPlayerCell)
    func didSoundButtonTapped(in cell: ShortsPlayerCell)
    func didSubscribeButtonTapped(in cell: ShortsPlayerCell)
}

final class ShortsPlayerCell: UICollectionViewCell {
    
    static let reusID = "ShortsPlayerCell"
    weak var delegate: ShortsPlayerCellDelegate?
    
    private let rightButtonsView = UIView()
    private let videoInfoView = UIView()
    private let thumbnailImageView = ShortsThumbnailImageView(frame: .zero)
    private let titleLabel = UILabel()
    private let channelTitleLabel = UILabel()
    private let profileImageView = ProfileImageView(frame: .zero)
    private let backButton = IconButton(iconName: ImageAssets.arrowLeft.rawValue)
    private let moreButton = IconButton(iconName: ImageAssets.moreHorizontal.rawValue)
    private let likeButton = IconButton(iconName: ImageAssets.likeFilled.rawValue)
    private let dislikeButton = IconButton(iconName: ImageAssets.dislikeFilled.rawValue)
    private let commentsButton = IconButton(iconName: ImageAssets.commentsFilled.rawValue)
    private let shareButton = IconButton(iconName: ImageAssets.shareFilled.rawValue)
    private let soundButton = IconButton(iconName: ImageAssets.shortsSoundPlaceholder.rawValue)
    private let subscribeButton = SubscribeButton()
    
    
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
        channelTitleLabel.text = video.channel.name
        likeButton.setTitle(video.formattedLikeCount)
        commentsButton.setTitle(video.formattedCommentCount)
    }
}

private extension ShortsPlayerCell {
    
    func configureUI() {
        backgroundColor = .systemBackground
        contentView.backgroundColor = .systemBackground
        contentView.clipsToBounds = true
        
        contentView.addSubview(thumbnailImageView)
        thumbnailImageView.addSubview(rightButtonsView)
        thumbnailImageView.addSubview(videoInfoView)
        thumbnailImageView.addSubview(backButton)
        
        [
            titleLabel,
            profileImageView,
            channelTitleLabel,
            subscribeButton
        ].forEach {
            videoInfoView.addSubview($0)
        }
        
        [
            moreButton,
            likeButton,
            dislikeButton,
            commentsButton,
            shareButton,
            soundButton,
        ].forEach {
            rightButtonsView.addSubview($0)
        }
        
        setupTitleLabel()
        setupChanelTitleLabel()
        setUpBackButton()
        setUpMoreButton()
        setUpLikeButton()
        setUpDislikeButton()
        setUpCommentsButton()
        setUpShareButton()
        setUpSoundButton()
        setUpSubscribeButton()
        
    }
    
    func setupTitleLabel() {
        titleLabel.font = .systemFont(ofSize: 16, weight: .medium)
        titleLabel.textColor = .white
        titleLabel.numberOfLines = 4
    }
    
    func setupChanelTitleLabel() {
        channelTitleLabel.font = .systemFont(ofSize: 14, weight: .bold)
        channelTitleLabel.textColor = .white
    }
    
    func setUpBackButton() {
        backButton.addTarget(self, action: #selector(didBackButtonTapped), for: .touchUpInside)
    }
    
    func setUpMoreButton() {
        moreButton.addTarget(self, action: #selector(didMoreButtonTapped), for: .touchUpInside)
    }
    
    func setUpLikeButton() {
        likeButton.addTarget(self, action: #selector(didLikeButtonTapped), for: .touchUpInside)
    }
    
    func setUpDislikeButton() {
        dislikeButton.setTitle("Dislike")
        dislikeButton.addTarget(self, action: #selector(didDislikeButtonTapped), for: .touchUpInside)
    }
    
    func setUpCommentsButton() {
        commentsButton.addTarget(self, action: #selector(didCommentsButtonTapped), for: .touchUpInside)
    }
    
    func setUpShareButton() {
        shareButton.setTitle("Share")
        shareButton.addTarget(self, action: #selector(didShareButtonTapped), for: .touchUpInside)
    }
    
    func setUpSoundButton() {
        soundButton.addTarget(self, action: #selector(didSoundButtonTapped), for: .touchUpInside)
    }
    
    func setUpSubscribeButton() {
        subscribeButton.addTarget(self, action: #selector(didSubscribeButtonTapped), for: .touchUpInside)
    }
    
    
    func configureLayout() {
        let width = contentView.bounds.width
        let height = contentView.bounds.height
        
        thumbnailImageView.frame = CGRect(
            x: 0,
            y: 0,
            width: width,
            height: height
        )
        
        backButton.frame = CGRect(
            x: Layout.horizontalPadding,
            y: Layout.verticalPadding + safeAreaInsets.top,
            width: Layout.buttonSize,
            height: Layout.buttonSize
        )
        
        configureRightButtonsLayout()
        configureVideoInfoLayout()
    }
    
    func configureRightButtonsLayout() {
        
        rightButtonsView.frame = CGRect(
            x: thumbnailImageView.bounds.width - Layout.horizontalPadding - Layout.buttonSize,
            y: 0,
            width: Layout.horizontalPadding * 2 + Layout.buttonSize,
            height: thumbnailImageView.bounds.height
        )
        
        let buttonX: CGFloat = 0
        var buttonY = rightButtonsView.bounds.height - Layout.verticalPadding - Layout.buttonWithLabelHeight
        
        let buttons = [soundButton, shareButton, commentsButton, dislikeButton, likeButton, moreButton]
        for button in buttons {
            let height = button == moreButton ? Layout.buttonSize : Layout.buttonWithLabelHeight
            let buttonSize = button.intrinsicContentSize
            button.frame = CGRect(
                x: buttonX,
                y: buttonY,
                width: buttonSize.width,
                height: height
            )
            buttonY -= Layout.spacing + height
        }
        
    }
    
    func configureVideoInfoLayout() {
        
        videoInfoView.frame = CGRect(
            x: Layout.horizontalPadding,
            y: thumbnailImageView.bounds.height - Layout.verticalPadding - Layout.profileImageSize - 80 - Layout.spacing,
            width: thumbnailImageView.bounds.width - rightButtonsView.bounds.width - Layout.spacing,
            height: Layout.verticalPadding + Layout.profileImageSize + 80 + Layout.spacing
        )
        
        profileImageView.frame = CGRect(
            x: Layout.horizontalPadding,
            y: videoInfoView.bounds.height - Layout.verticalPadding - Layout.profileImageSize,
            width: Layout.profileImageSize,
            height: Layout.profileImageSize
        )

        let channelTitleLabelSize = channelTitleLabel.intrinsicContentSize
        channelTitleLabel.frame = CGRect(
            x: profileImageView.frame.maxX + Layout.spacing,
            y: videoInfoView.bounds.height - Layout.verticalPadding - Layout.profileImageSize,
            width: channelTitleLabelSize.width,
            height: Layout.profileImageSize
        )

        let subscribeButtonSize = subscribeButton.intrinsicContentSize
        subscribeButton.frame = CGRect(
            x: channelTitleLabel.frame.maxX + Layout.spacing,
            y: videoInfoView.bounds.height - Layout.verticalPadding - Layout.profileImageSize,
            width: subscribeButtonSize.width,
            height: Layout.profileImageSize
        )

        titleLabel.frame = CGRect(
            x: Layout.horizontalPadding,
            y: profileImageView.frame.minY - Layout.spacing - 60,
            width: subscribeButtonSize.width - Layout.spacing,
            height: 60
        )
    }
}

private extension ShortsPlayerCell {
    @objc func didBackButtonTapped() {
        delegate?.didBackButtonTapped(in: self)
    }
    
    @objc func didMoreButtonTapped() {
        delegate?.didMoreButtonTapped(in: self)
    }
    
    @objc func didLikeButtonTapped() {
        delegate?.didLikeButtonTapped(in: self)
    }
    
    @objc func didDislikeButtonTapped() {
        delegate?.didDislikeButtonTapped(in: self)
    }
    
    @objc func didCommentsButtonTapped() {
        delegate?.didCommentsButtonTapped(in: self)
    }
    
    @objc func didShareButtonTapped() {
        delegate?.didShareButtonTapped(in: self)
    }
    
    @objc func didSoundButtonTapped() {
        delegate?.didSoundButtonTapped(in: self)
    }
    
    @objc func didSubscribeButtonTapped() {
        delegate?.didSubscribeButtonTapped(in: self)
    }

}

private extension ShortsPlayerCell {
    enum Layout {
        static let horizontalPadding: CGFloat = 16
        static let verticalPadding: CGFloat = 30
        static let spacing: CGFloat = 20
        static let buttonWithLabelHeight: CGFloat = 54
        static let buttonSize: CGFloat = 36
        static let profileImageSize: CGFloat = 36
        static let subscribeButtonSize: CGSize = CGSize(width: 98, height: 28)
    }
}
