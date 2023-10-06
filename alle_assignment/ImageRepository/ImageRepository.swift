////
////  ImageRepository.swift
////  alle_assignment
////
////  Created by Piyush Sharma on 05/10/23.
////
//
//import Foundation
//
//struct AlleImage {
//    let id: String
//    let labels: Data
//    let imageDescription: String
//    let isProcessed: Bool
//    let note: String
//}
//
//enum RepoError: Error {
//    
//}
//
//protocol ImageRepository {
//    func saveImage(imageInfo: AlleImage) -> Result<Bool, RepoError>
//    func getImage(id: String) -> Result<AlleImage, RepoError>
//}
//
//struct ImageRepositoryImpl: ImageRepository {
//    func saveImage(imageInfo: AlleImage) -> Result<Bool, RepoError> {
//        <#code#>
//    }
//    
//    func getImage(id: String) -> Result<AlleImage, RepoError> {
//        <#code#>
//    }
//}
