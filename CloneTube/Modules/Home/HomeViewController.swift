//
//  HomeViewController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 27.08.25.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private enum Section: Int, CaseIterable {
        case shorts
        case videos
    }
    
    private enum Layout {
        static let topBarHeight: CGFloat = 60
        static let filtersHeight: CGFloat = 56
        static let dividerHeight: CGFloat = 1
        
        static let shortsItemLeadingInset: CGFloat = 4
        static let shortsItemTrailingInset: CGFloat = 4
        static let shortsGroupWidthFraction: CGFloat = 0.4
        static let shortsGroupHeight: CGFloat = 250
        static let shortsSectionTopInset: CGFloat = 8
        static let shortsSectionBottomInset: CGFloat = 16
        static let shortsSectionHorizontalInset: CGFloat = 16
        
        static let videosItemBottomInset: CGFloat = 12
        static let videosItemHeightEstimate: CGFloat = 300
        static let videosSectionBottomInset: CGFloat = 16
    }
    
    private var shorts: [Video] = []
    private var videos: [Video] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Video>!
    
    private lazy var topBarView: TopBarView = {
        let view = TopBarView()
        view.delegate = self
        return view
    }()
    
    private lazy var dividerView: UIView = {
        let view = UIView()
        view.backgroundColor = .systemGray5
        return view
    }()
    
    private lazy var filtersView: FiltersScrollView = {
        let view = FiltersScrollView()
        view.delegate = self
        view.configure(with: VideoCategory.allCases)
        return view
    }()
    
    private lazy var collectionView: UICollectionView = {
        let layout = createCompositionalLayout()
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseID)
        collectionView.register(ShortsCell.self, forCellWithReuseIdentifier: ShortsCell.reuseID)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureDataSource()
        loadVideos()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        layoutUI()
    }
}

private extension HomeViewController {
    
    func setupUI() {
        view.backgroundColor = .systemBackground
        view.addSubview(topBarView)
        view.addSubview(dividerView)
        view.addSubview(filtersView)
        view.addSubview(collectionView)
    }
    
    func layoutUI() {
        let safeArea = view.safeAreaInsets
        
        topBarView.frame = CGRect(
            x: 0,
            y: safeArea.top,
            width: view.bounds.width,
            height: Layout.topBarHeight
        )
        
        dividerView.frame = CGRect(
            x: 0,
            y: topBarView.frame.maxY,
            width: view.bounds.width,
            height: Layout.dividerHeight
        )
        
        filtersView.frame = CGRect(
            x: 0,
            y: dividerView.frame.maxY,
            width: view.bounds.width,
            height: Layout.filtersHeight
        )
        
        collectionView.frame = CGRect(
            x: 0,
            y: filtersView.frame.maxY,
            width: view.bounds.width,
            height: view.bounds.height - filtersView.frame.maxY
        )
    }
}

private extension HomeViewController {
    
    func createCompositionalLayout() -> UICollectionViewCompositionalLayout {
        return UICollectionViewCompositionalLayout { sectionIndex, _ in
            guard let section = Section(rawValue: sectionIndex) else { return nil }
            
            switch section {
                
            case .shorts:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .fractionalHeight(1.0)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: Layout.shortsItemLeadingInset,
                    bottom: 0,
                    trailing: Layout.shortsItemTrailingInset
                )
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(Layout.shortsGroupWidthFraction),
                    heightDimension: .absolute(Layout.shortsGroupHeight)
                )
                let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.orthogonalScrollingBehavior = .continuous
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: Layout.shortsSectionTopInset,
                    leading: Layout.shortsSectionHorizontalInset,
                    bottom: Layout.shortsSectionBottomInset,
                    trailing: Layout.shortsSectionHorizontalInset
                )
                return sectionLayout
                
            case .videos:
                let itemSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(Layout.videosItemHeightEstimate)
                )
                let item = NSCollectionLayoutItem(layoutSize: itemSize)
                item.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: Layout.videosItemBottomInset,
                    trailing: 0
                )
                
                let groupSize = NSCollectionLayoutSize(
                    widthDimension: .fractionalWidth(1.0),
                    heightDimension: .estimated(Layout.videosItemHeightEstimate)
                )
                let group = NSCollectionLayoutGroup.vertical(layoutSize: groupSize, subitems: [item])
                
                let sectionLayout = NSCollectionLayoutSection(group: group)
                sectionLayout.contentInsets = NSDirectionalEdgeInsets(
                    top: 0,
                    leading: 0,
                    bottom: Layout.videosSectionBottomInset,
                    trailing: 0
                )
                return sectionLayout
            }
        }
    }
}

private extension HomeViewController {
    
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Video>(
            collectionView: collectionView
        ) { collectionView, indexPath, video in
            let section = Section(rawValue: indexPath.section)!
            switch section {
            case .shorts:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: ShortsCell.reuseID, for: indexPath
                ) as! ShortsCell
                cell.delegate = self
                cell.configure(with: video)
                return cell
            case .videos:
                let cell = collectionView.dequeueReusableCell(
                    withReuseIdentifier: VideoCell.reuseID, for: indexPath
                ) as! VideoCell
                cell.delegate = self
                cell.configure(with: video)
                return cell
            }
        }
    }
    
    func loadVideos(_ filter: VideoCategory = .all) {
        Task {
            do {
                shorts = try await MockNetworkService.shared.fetchShorts(filter)
                videos = try await MockNetworkService.shared.fetchVideos(filter)
                applySnapshot()
            } catch {
                print("❌ Error fetching videos:", error)
            }
        }
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        snapshot.appendSections([.shorts, .videos])
        snapshot.appendItems(shorts, toSection: .shorts)
        snapshot.appendItems(videos, toSection: .videos)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension HomeViewController: FiltersScrollViewDelegate {
    func onFilterSelected(_ filter: VideoCategory) {
        loadVideos(filter)
    }
}

extension HomeViewController: VideoCellDelegate {
    func didTapMoreButton(in cell: VideoCell) {
        print("More on video tapped")
    }
}

extension HomeViewController: ShortsCellDelegate {
    func didTapMoreButton(in cell: ShortsCell) {
        print("More on shorts tapped")
    }
}

extension HomeViewController: TopBarViewDelegate {
    func castButtonTapped() { print("Cast tapped") }
    func notificationButtonTapped() { print("Notifications tapped") }
    func searchButtonTapped() { print("Search tapped") }
    func profileButtonTapped() { print("Profile tapped") }
}
