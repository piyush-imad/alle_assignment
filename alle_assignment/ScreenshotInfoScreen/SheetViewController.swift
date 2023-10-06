//
//  SheetViewController.swift
//  alle_assignment
//
//  Created by Piyush Sharma on 04/10/23.

import UIKit
import CoreData

class SheetViewController: UIViewController, UITextFieldDelegate {
    
    var imageID: String?
    var image: UIImage?
    var labels: [String] = []
    var imageDescription: String = ""
    
    private let noteTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Add a note"
        textField.backgroundColor = .white
        textField.textColor = .black
        textField.layer.borderColor = UIColor.black.cgColor
        textField.layer.borderWidth = 1.0
        textField.layer.cornerRadius = 8.0
        textField.clipsToBounds = true
        return textField
    }()
    
    private let collectionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Collections"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: UIFont.systemFontSize)
        return label
    }()
    
    private let descriptionContentLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        return label
    }()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        setupUI()
        loadData()
        
        noteTextField.delegate = self
    }
    
    private func setupUI() {
        noteTextField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(noteTextField)
        NSLayoutConstraint.activate([
            noteTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            noteTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            noteTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            noteTextField.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        collectionsLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(collectionsLabel)
        NSLayoutConstraint.activate([
            collectionsLabel.topAnchor.constraint(equalTo: noteTextField.bottomAnchor, constant: 20),
            collectionsLabel.leadingAnchor.constraint(equalTo: noteTextField.leadingAnchor),
            collectionsLabel.trailingAnchor.constraint(equalTo: noteTextField.trailingAnchor)
        ])
        
        view.addSubview(labelsCollectionView)
        
        NSLayoutConstraint.activate([
            labelsCollectionView.topAnchor.constraint(equalTo: collectionsLabel.bottomAnchor, constant: 10),
            labelsCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            labelsCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            labelsCollectionView.heightAnchor.constraint(equalToConstant: 100)  // Adjust as needed
        ])
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(descriptionLabel)
        NSLayoutConstraint.activate([
            descriptionLabel.topAnchor.constraint(equalTo: collectionsLabel.bottomAnchor, constant: 50),
            descriptionLabel.leadingAnchor.constraint(equalTo: noteTextField.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: noteTextField.trailingAnchor)
        ])
        
        descriptionContentLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionContentLabel.numberOfLines = 0
        view.addSubview(descriptionContentLabel)
        NSLayoutConstraint.activate([
            descriptionContentLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 10),
            descriptionContentLabel.leadingAnchor.constraint(equalTo: noteTextField.leadingAnchor),
            descriptionContentLabel.trailingAnchor.constraint(equalTo: noteTextField.trailingAnchor),
            descriptionContentLabel.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
        
        
    }
    
    private lazy var labelsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.estimatedItemSize = CGSize(width: 50, height: 30)
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .white
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(LabelCollectionViewCell.self, forCellWithReuseIdentifier: LabelCollectionViewCell.reuseIdentifier)
        return collectionView
    }()
    
    
    private func loadData() {
        guard let imageID = imageID else { return }
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Screenshot>(entityName: "Screenshot")
        fetchRequest.predicate = NSPredicate(format: "id == %@", imageID)
        
        if let result = try? moc.fetch(fetchRequest), let screenshot = result.first {
            noteTextField.text = screenshot.note
            descriptionContentLabel.text = screenshot.imageDescription
            let storedDescription = screenshot.imageDescription
            
            //TODO: imagedescription started coming as empty after architecture changes check back
            if storedDescription!.isEmpty {
                DispatchQueue.global().async {
                    ImageProcessor.shared.processImageWithVision(for: self.image!) { [weak self] recognizedText in
                        DispatchQueue.main.async {
                            self?.descriptionContentLabel.text = recognizedText
                            self?.descriptionLabel.textColor = .black
                        }
                    }
                }
            } else {
                descriptionContentLabel.text = storedDescription
            }
            
            if let labelsData = screenshot.labels, let labelsArray = try? JSONDecoder().decode([String].self, from: labelsData) {
                self.labels = labelsArray
                labelsCollectionView.reloadData()
            }
        } else {
        }
    }
    
    private func addLabelsToContainer(_ labels: [String]) {
        self.labels = labels
        labelsCollectionView.reloadData()
    }
    
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        saveNote()
    }
    
    private func saveNote() {
        guard let imageID = imageID else { return }
        
        let moc = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<Screenshot>(entityName: "Screenshot")
        fetchRequest.predicate = NSPredicate(format: "id == %@", imageID)
        
        if let result = try? moc.fetch(fetchRequest), let screenshot = result.first {
            screenshot.note = noteTextField.text
            do {
                try moc.save()
            } catch {
                print("Error saving note to CoreData:", error.localizedDescription)
            }
        } else {
            print("No Core Data entry found for imageID:", imageID)
        }
    }
    
    private func displayLabels(from labelsData: Data) {
        if let labels = try? JSONDecoder().decode([String].self, from: labelsData) {
            var lastLabel: UILabel? = nil
            for labelString in labels {
                let label = UILabel()
                label.text = labelString
                label.backgroundColor = .yellow
                
                view.addSubview(label)
                
                label.translatesAutoresizingMaskIntoConstraints = false
                NSLayoutConstraint.activate([
                    label.topAnchor.constraint(equalTo: lastLabel?.bottomAnchor ?? collectionsLabel.bottomAnchor, constant: 5),
                    label.leadingAnchor.constraint(equalTo: collectionsLabel.leadingAnchor),
                    label.heightAnchor.constraint(equalToConstant: 30)
                ])
                
                lastLabel = label
            }
        }
    }
    
    private func processAndStoreImageDetails() {
        let processor = ImageProcessor.shared
        
        guard let imageID = self.imageID, let image = self.image else {
            print("Error: imageID or image is nil")
            return
        }
        
        DispatchQueue.main.sync {
            processor.processImage(imageID, image)
            loadData()
        }
    }
    
}

extension SheetViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return labels.count 
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: LabelCollectionViewCell.reuseIdentifier, for: indexPath) as! LabelCollectionViewCell
        cell.label.text = labels[indexPath.item]
        return cell
    }
}
