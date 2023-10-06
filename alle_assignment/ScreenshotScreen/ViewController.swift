//
//  ViewController.swift
//  alle_assignment
//
//  Created by Piyush Sharma on 02/10/23.
//

import UIKit
import Photos


class ViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITabBarDelegate, MainViewModelDelegate {
    
    var viewModel = MainViewModel()
    @IBOutlet weak var photosCollectionView: UICollectionView!
    @IBOutlet weak var tabBar: UITabBar!
    @IBOutlet weak var bottomBarCollectionView: UICollectionView!
    
    
    var allPhotos: PHFetchResult<PHAsset>!
    var isScrolling = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        viewModel.delegate = self
        photosCollectionView.delegate = self
        photosCollectionView.dataSource = self
        photosCollectionView.isPagingEnabled = true
        bottomBarCollectionView.delegate = self
        bottomBarCollectionView.dataSource = self
        tabBar.delegate = self
        
        
        
        if let flowLayout = photosCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            flowLayout.minimumLineSpacing = 0
            flowLayout.minimumInteritemSpacing = 0
        }
        
        if let flowLayout = bottomBarCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 5, bottom: 0, right: 5) // Small left and right padding
            flowLayout.minimumLineSpacing = 1 // Spacing between images
            flowLayout.minimumInteritemSpacing = 1
        }
        
        fetchAndDisplayPhotos()
        
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func fetchAndDisplayPhotos() {
        if let ss = viewModel.allPhotos {
            DispatchQueue.main.async { [weak self] in
                self!.allPhotos = ss
                self!.photosCollectionView.reloadData()
                self!.bottomBarCollectionView.reloadData()
                
                let lastPictureIndex = (self?.allPhotos.count ?? 1) - 1
                self?.photosCollectionView.scrollToItem(at: IndexPath(item: lastPictureIndex, section: 0), at: .left, animated: false)
            }
        } else {
            viewModel.checkAndRequestPhotoLibraryAccess { [weak self] (permissionGranted) in
                guard let self = self else { return }
                if permissionGranted {
                    self.viewModel.fetchPhotos { [weak self] photos in
                        guard let self = self else { return }
                        self.allPhotos = photos
                        self.photosCollectionView.reloadData()
                        self.bottomBarCollectionView.reloadData()
                        
                        // Get the index of the last picture
                        let lastPictureIndex = self.allPhotos.count - 1
                        
                        // Scroll to the last picture in the main collection view
                        self.photosCollectionView.scrollToItem(at: IndexPath(item: lastPictureIndex, section: 0), at: .left, animated: false)
                        self.bottomBarCollectionView.scrollToItem(at: IndexPath(item: lastPictureIndex, section: 0), at: .left, animated: false)
                    }
                } else {
                    // Handle permission denied
                }
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //        if scrollView == photosCollectionView {
        //            // Calculate the visible photo index based on the current content offset
        //            let visiblePhotoIndex = Int(scrollView.contentOffset.x / scrollView.bounds.width)
        //
        //            // Scroll the bottom bar collection view to the same index
        //            let bottomBarIndexPath = IndexPath(item: visiblePhotoIndex, section: 0)
        //            bottomBarCollectionView.scrollToItem(at: bottomBarIndexPath, at: .centeredHorizontally, animated: true)
        //        }
        //           else
        if scrollView == bottomBarCollectionView {
            // Calculate the center of the visible rect in the bottom collection view
            let visibleRect = CGRect(origin: bottomBarCollectionView.contentOffset, size: bottomBarCollectionView.bounds.size)
            let center = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
            
            // Find the index path for the center of the bottom collection view
            if let indexPath = bottomBarCollectionView.indexPathForItem(at: center) {
                // Scroll the main photo view to center the currently viewed image
                photosCollectionView.scrollToItem(at: indexPath, at: .left, animated: false)
            }
        }
    }
    
    @objc func appWillEnterForeground() {
        viewModel.refreshData()
    }
    
    @IBOutlet weak var infoButton: UITabBarItem!
    
    func dataDidUpdate() {
        fetchAndDisplayPhotos()
    }
    
}

// MARK: - UICollectionView DataSource & Delegate
extension ViewController {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return allPhotos?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell
        
        
        let asset = allPhotos[indexPath.row]
        if collectionView == photosCollectionView {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotosCell", for: indexPath) as! ImageCollectionViewCell
        } else {
            cell = collectionView.dequeueReusableCell(withReuseIdentifier: "BottomBarCell", for: indexPath) as! ImageCollectionViewCell
        }
        
        let manager = PHImageManager.default()
        var targetSize: CGSize
        if collectionView == photosCollectionView {
            targetSize = PHImageManagerMaximumSize
        } else {
            targetSize = CGSize(width: 100, height: 100)
        }
        manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: nil) { (image, _) in
            cell.imageView.image = image
            cell.imageView.contentMode = .scaleAspectFill
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == bottomBarCollectionView {
            let asset = allPhotos[indexPath.row]
            let manager = PHImageManager.default()
            
            let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
            manager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, _) in
                if let selectedImage = image {
                    DispatchQueue.global().async {
                        ImageProcessor().processImage(asset.localIdentifier, selectedImage)
                    }
                }
            }
            bottomBarCollectionView.scrollToItem(at: indexPath, at: .centeredHorizontally, animated: true)
            photosCollectionView.scrollToItem(at: indexPath, at: .left, animated: true)
        }
    }
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView == photosCollectionView {
            return collectionView.bounds.size
        } else {
            return CGSize(width: collectionView.bounds.height - 10, height: collectionView.bounds.height - 10)
        }
    }
}

extension ViewController {
    func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if item.tag == 1 {
            let sheetVC = SheetViewController()
            sheetVC.modalPresentationStyle = .pageSheet
            if let sheet = sheetVC.sheetPresentationController {
                sheet.detents = [.medium(), .large()]
            }
            self.present(sheetVC, animated: true, completion: nil)
        }
    }
}

