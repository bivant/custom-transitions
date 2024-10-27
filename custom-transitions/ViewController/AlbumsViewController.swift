//
//  ViewController.swift
//  custom-transitions
//
//  Created by Bruno Lorenzo on 1/4/21.
//

import UIKit

class AlbumsViewController: UIViewController {
    
    typealias TransitionComponents = (albumCoverImageView: UIImageView?, albumNameLabel: UILabel?)
    
    // MARK: - Subviews
    
    private var pageControl = UIPageControl(frame: .zero)
    public var transitionComponents = TransitionComponents(albumCoverImageView: nil, albumNameLabel: nil)
    public var albumsCollectionView: UICollectionView?
    public var currentCell: AlbumCollectionViewCell?
    
    // MARK: - Properties
    
    private var albums = [Album]()
    private var currentPage = 0 {
        didSet {
            pageControl.currentPage = currentPage
        }
    }
    private let transitionManager = TransitionManager(duration: 0.5)
    
    // MARK: - Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationController?.navigationBar.isHidden = true
        
        let provider = AlbumProvider()
        albums.append(contentsOf: provider.getAllAlbums())
        pageControl.numberOfPages = albums.count
        
        setupUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
}

// MARK: - Setups

private extension AlbumsViewController {
    
    func setupUI() {
        setupBackgroundColor()
        setupHeaderView()
        setupCollectionView()
        setupPageControl()
    }
    
    func setupBackgroundColor() {
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        gradient.colors = [UIColor.backgroundColorGradient1 ?? .black, UIColor.backgroundColorGradient2 ?? .black].map { $0.cgColor }
        gradient.startPoint = .init(x: 0.5, y: 0)
        gradient.endPoint = .init(x: 0.5, y: 1)
        gradient.locations = [0.5]
        view.layer.insertSublayer(gradient, at: 0)
    }
    
    func setupHeaderView() {
        let bandNameLabel = UILabel()
        bandNameLabel.font = .titleFont
        bandNameLabel.textColor = .textForegroundColor
        bandNameLabel.text = "AC/DC"
        
        view.addSubview(bandNameLabel)
        bandNameLabel.textAlignment = .center
        bandNameLabel.translatesAutoresizingMaskIntoConstraints = false
        bandNameLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 105).isActive = true
        bandNameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        bandNameLabel.widthAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    func setupCollectionView() {
        let collectionLayout = UICollectionViewFlowLayout()
        collectionLayout.scrollDirection = .horizontal
        collectionLayout.sectionInset = .init(top: 10, left: 10, bottom: 10, right: 10)
        collectionLayout.minimumLineSpacing = 10
        
        let albumCollection = UICollectionView(frame: .zero, collectionViewLayout: collectionLayout)
        albumCollection.isPagingEnabled = true
        albumCollection.showsHorizontalScrollIndicator = false
        albumCollection.backgroundColor = .clear
        albumCollection.dataSource = self
        albumCollection.delegate = self
        albumCollection.register(AlbumCollectionViewCell.self, forCellWithReuseIdentifier: AlbumCollectionViewCell.reuseIdentifier)
        self.albumsCollectionView = albumCollection
        view.addSubview(albumCollection)
        albumCollection.translatesAutoresizingMaskIntoConstraints = false
        albumCollection.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        albumCollection.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        albumCollection.widthAnchor.constraint(equalToConstant: 300).isActive = true
        albumCollection.heightAnchor.constraint(equalToConstant: 400).isActive = true
    }
    
    func setupPageControl() {
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.pageIndicatorTintColor = UIColor(hex: "#6D1405ff")
        pageControl.backgroundStyle = .minimal
        pageControl.currentPage = 0
        
        view.addSubview(pageControl)
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        pageControl.heightAnchor.constraint(equalToConstant: 50).isActive = true
        pageControl.widthAnchor.constraint(equalToConstant: 100).isActive = true
        pageControl.topAnchor.constraint(equalTo: view.bottomAnchor, constant: -200).isActive = true
    }
}

// MARK: - UICollectionView DataSource

extension AlbumsViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return albums.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumCollectionViewCell.reuseIdentifier, for: indexPath) as? AlbumCollectionViewCell else { return UICollectionViewCell() }
        
        let album = albums[indexPath.row]
        cell.configure(with: album)
        
        if indexPath.row == 0 {
            currentCell = cell
        }
        return cell
    }
}

// MARK: - UICollectionViewDelegateFlowLayout Delegate

extension AlbumsViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewSize = collectionView.bounds.size
        return .init(width: collectionViewSize.width - 20, height: collectionViewSize.height - 10)
    }
}

// MARK: - UICollectionView Delegate
extension AlbumsViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let albumDetailViewController = AlbumDetailViewController(album: albums[indexPath.row])
        navigationController?.delegate = transitionManager
        navigationController?.pushViewController(albumDetailViewController, animated: true)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage(in: scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        currentPage = getCurrentPage(in: scrollView)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        currentPage = getCurrentPage(in: scrollView)
    }
}

// MARK: - Helpers

extension AlbumsViewController {
    func getCurrentPage(in scrollView: UIScrollView) -> Int {
        
        guard let collection = scrollView as? UICollectionView else { return currentPage}
        
        let visibleRect = CGRect(origin: collection.contentOffset, size: collection.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if
            let visibleIndexPath = collection.indexPathForItem(at: visiblePoint),
            let cell = collection.cellForItem(at: visibleIndexPath) as? AlbumCollectionViewCell {
            
            currentCell = cell
            return visibleIndexPath.row
        }
        
        return currentPage
    }
}
