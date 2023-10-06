//
//  MainViewModel.swift
//  alle_assignment
//
//  Created by Piyush Sharma on 06/10/23.
//

import Foundation
import Photos

protocol MainViewModelDelegate: AnyObject {
    func dataDidUpdate()
}

class MainViewModel {
    
    weak var delegate: MainViewModelDelegate?
    var allPhotos: PHFetchResult<PHAsset>?
    
    func processImages()->Void {
        
    }
    
    func checkAndRequestPhotoLibraryAccess(completion: @escaping (Bool) -> Void) {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized:
            // Permission already granted
            completion(true)
        case .notDetermined:
            // Request permission to access the photo library
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                if newStatus == .authorized {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        default:
            // Permission denied or restricted
            completion(false)
        }
    }
    
    func fetchPhotos(completion: @escaping (PHFetchResult<PHAsset>)->()) {
        DispatchQueue.global(qos: .background).async {
            let fetchOptions = PHFetchOptions()
            
            fetchOptions.predicate = NSPredicate(format: "mediaSubtype == %ld", PHAssetMediaSubtype.photoScreenshot.rawValue)
            self.allPhotos = PHAsset.fetchAssets(with: .image, options: fetchOptions)
            self.delegate?.dataDidUpdate()
            DispatchQueue.main.async{
                completion(self.allPhotos!)
            }
        }
    }
    
    func refreshData() {
        fetchPhotos { _ in
            self.delegate?.dataDidUpdate()
            
        }
    }
    
}
