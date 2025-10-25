//
//  ShortsViewController.swift
//  CloneTube
//
//  Created by George Partskhaladze on 25.10.25.
//

import UIKit

final class ShortsViewController: UIViewController {
    
    private enum Section: Int, CaseIterable {
        case shorts
    }
    
    private enum Layout {
        static let spacing: CGFloat = 0
    }
    
    private var shorts: [Video] = []
    private var dataSource: UICollectionViewDiffableDataSource<Section, Video>!
    
    private lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        layout.itemSize = CGSize(width: view.bounds.width, height: view.bounds.height)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.isPagingEnabled = true
        collectionView.showsVerticalScrollIndicator = false
        collectionView.contentInsetAdjustmentBehavior = .never
        collectionView.register(ShortsPlayerCell.self, forCellWithReuseIdentifier: ShortsPlayerCell.reusID)
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.addSubview(collectionView)
        configureDataSource()
        loadShorts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
//        tabBarController?.tabBar.isHidden = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = view.bounds.size
        }
    }
}

private extension ShortsViewController {
    func configureDataSource() {
        dataSource = UICollectionViewDiffableDataSource<Section, Video>(
            collectionView: collectionView
        ) { collectionView, indexPath, video in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: ShortsPlayerCell.reusID,
                for: indexPath
            ) as! ShortsPlayerCell
            cell.configure(with: video)
            cell.delegate = self
            return cell
        }
    }
    
    func loadShorts() {
        Task {
            do {
                shorts = try await MockNetworkService.shared.fetchShorts(.all)
                applySnapshot()
            } catch {
                print("❌ Error fetching shorts: \(error)")
            }
        }
    }
    
    func applySnapshot(animatingDifferences: Bool = true) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Video>()
        snapshot.appendSections([.shorts])
        snapshot.appendItems(shorts, toSection: .shorts)
        dataSource.apply(snapshot, animatingDifferences: animatingDifferences)
    }
}

extension ShortsViewController: ShortsPlayerCellDelegate {
    func didBackButtonTapped(in cell: ShortsPlayerCell) {
        print("Back button tapped")
    }

    func didMoreButtonTapped(in cell: ShortsPlayerCell) {
        print("More button tapped")
    }

    func didLikeButtonTapped(in cell: ShortsPlayerCell) {
        print("Like button tapped")
    }

    func didDislikeButtonTapped(in cell: ShortsPlayerCell) {
        print("Dislike button tapped")
    }

    func didCommentsButtonTapped(in cell: ShortsPlayerCell) {
        print("Comments button tapped")
    }

    func didShareButtonTapped(in cell: ShortsPlayerCell) {
        print("Share button tapped")
    }

    func didSoundButtonTapped(in cell: ShortsPlayerCell) {
        print("Sound button tapped")
    }

    func didSubscribeButtonTapped(in cell: ShortsPlayerCell) {
        print("Subscribe button tapped")
    }
}
