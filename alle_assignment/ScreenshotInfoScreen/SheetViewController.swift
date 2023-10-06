//
//  SheetViewController.swift
//  alle_assignment
//
//  Created by Piyush Sharma on 04/10/23.
//

import UIKit

class SheetViewController: UIViewController {
    
    // UI Elements
    private let textView: UITextView = {
        let textView = UITextView()
        textView.text = "I love this 💜"
        textView.font = UIFont.systemFont(ofSize: 20)
        textView.layer.borderWidth = 1
        textView.layer.cornerRadius = 12
        textView.layer.borderColor = UIColor.black.cgColor
        return textView
    }()
    
    private let collectionsLabel: UILabel = {
        let label = UILabel()
        label.text = "Collections"
        label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private let animalButton: UIButton = {
        let button = UIButton()
        button.setTitle("Animal", for: .normal)
        return button
    }()
    
    private let rabbitButton: UIButton = {
        let button = UIButton()
        button.setTitle("Rabbit", for: .normal)
        return button
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "Description"
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.numberOfLines = 0
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        // Add subviews
        [textView, collectionsLabel, animalButton, rabbitButton, descriptionLabel].forEach { view.addSubview($0) }
        
        // Disable autoresizing masks
        [textView, collectionsLabel, animalButton, rabbitButton, descriptionLabel].forEach { $0.translatesAutoresizingMaskIntoConstraints = false }
        
        // Layout constraints
        NSLayoutConstraint.activate([
            // TextView
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            textView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            textView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            textView.heightAnchor.constraint(equalToConstant: 50),
            
            // CollectionsLabel
            collectionsLabel.topAnchor.constraint(equalTo: textView.bottomAnchor, constant: 20),
            collectionsLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            
            // AnimalButton
            animalButton.topAnchor.constraint(equalTo: collectionsLabel.bottomAnchor, constant: 10),
            animalButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            animalButton.heightAnchor.constraint(equalToConstant: 30),
            
            // RabbitButton
            rabbitButton.topAnchor.constraint(equalTo: collectionsLabel.bottomAnchor, constant: 10),
            rabbitButton.leadingAnchor.constraint(equalTo: animalButton.trailingAnchor, constant: 10),
            rabbitButton.heightAnchor.constraint(equalToConstant: 30),
            
            // DescriptionLabel
            descriptionLabel.topAnchor.constraint(equalTo: animalButton.bottomAnchor, constant: 20),
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
