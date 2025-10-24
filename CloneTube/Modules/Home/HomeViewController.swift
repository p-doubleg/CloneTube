//
//  HomeViewController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 27.08.25.
//

import UIKit

final class HomeViewController: UIViewController {
    
    private enum Section {
        case main
    }
    
    private enum Layout {
        static let topBarContentHeight: CGFloat = 28
        static let filtersContentHeight: CGFloat = 34
        static let topBarVerticalPadding: CGFloat = 12
        static let thumbnailAspectRatio: CGFloat = 16.0 / 9.0
        static let cellBottomContentHeight: CGFloat = 88
        static let dividerWidth: CGFloat = 1
    }
    
    private var videos: [Video] = []
    private var videosCollectionDataSource: UICollectionViewDiffableDataSource<Section, Video>?
    
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
    
    private lazy var videosCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(
            width: view.bounds.width,
            height: view.bounds.width / Layout.thumbnailAspectRatio + Layout.cellBottomContentHeight
        )
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(VideoCell.self, forCellWithReuseIdentifier: VideoCell.reuseID)
        collectionView.showsVerticalScrollIndicator = false
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
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
    
    func setupView() {
        view.backgroundColor = .systemBackground
        view.addSubview(topBarView)
        view.addSubview(dividerView)
        view.addSubview(filtersView)
        view.addSubview(videosCollectionView)
    }
    
    func layoutUI() {
        topBarView.frame = CGRect(
            x: 0,
            y: 0,
            width: view.bounds.width,
            height: view.safeAreaInsets.top + Layout.topBarContentHeight + Layout.topBarVerticalPadding * 2
        )
        
        dividerView.frame = CGRect(
            x: 0,
            y: topBarView.frame.maxY,
            width: view.bounds.width,
            height: Layout.dividerWidth
        )
        
        filtersView.frame = CGRect(
            x: 0,
            y: dividerView.frame.maxY,
            width: view.bounds.width,
            height: Layout.filtersContentHeight + Layout.topBarVerticalPadding * 2
        )
        
        videosCollectionView.frame = CGRect(
            x: 0,
            y: filtersView.frame.maxY,
            width: view.bounds.width,
            height: view.bounds.height - filtersView.frame.maxY
        )
    }
}

private extension HomeViewController {
    
    func configureDataSource() {
        videosCollectionDataSource = UICollectionViewDiffableDataSource<Section, Video>(
            collectionView: videosCollectionView
        ) { collectionView, indexPath, video in
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: VideoCell.reuseID,
                for: indexPath
            ) as? VideoCell else {
                return UICollectionViewCell()
            }
            
            cell.configure(with: video)
            cell.delegate = self
            return cell
        }
        
        videosCollectionView.dataSource = videosCollectionDataSource
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        snapshot.appendSections([.main])
        snapshot.appendItems(videos)
        videosCollectionDataSource?.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

private extension HomeViewController {
    
    func loadVideos() {
        Task {
            do {
                videos = try await MockNetworkService.shared.fetchVideos()
                applySnapshot()
            } catch {
                print("Error:", error)
            }
        }
    }
}

extension HomeViewController: TopBarViewDelegate {
    func castButtonTapped() { print("Cast tapped") }
    func notificationButtonTapped() { print("Notifications tapped") }
    func searchButtonTapped() { print("Search tapped") }
    func profileButtonTapped() { print("Profile tapped") }
}

extension HomeViewController: VideoCellDelegate {
    func didTapMoreButton(in cell: VideoCell) {
        print("More button tapped in cell")
    }
}

extension HomeViewController: FiltersScrollViewDelegate {
    func onFilterSelected(_ filter: VideoCategory) {
        print("Filter button tapped")
    }
}

