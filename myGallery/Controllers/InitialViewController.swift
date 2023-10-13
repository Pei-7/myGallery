//
//  InitialViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/5.
//

import UIKit

class InitialViewController: UIViewController {
    
    @IBOutlet var tagsCollectionView: UICollectionView!
    
    let tagsChoices = ["藝術","心情","美食","風景","自拍","穿搭","美妝","旅行","天空","自然","寵物","健身"]
    var userSelection:[String] = []
    
    fileprivate func setLabels() {
        let titleLabel = UILabel()
        titleLabel.text = "請選擇適合您相片的標籤："
        view.addSubview(titleLabel)
        
        
        let descriptionLabel = UILabel()
        descriptionLabel.text = "＊未來仍可增減或設置自定義標籤。"
        view.addSubview(descriptionLabel)
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: tagsCollectionView.leadingAnchor),
            titleLabel.bottomAnchor.constraint(equalTo: tagsCollectionView.topAnchor, constant: -30),
            descriptionLabel.trailingAnchor.constraint(equalTo: tagsCollectionView.trailingAnchor),
            descriptionLabel.topAnchor.constraint(equalTo: tagsCollectionView.bottomAnchor, constant: 30)
            
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tagsCollectionView.dataSource = self
        tagsCollectionView.delegate = self
        
        
        setLabels()
        
        let nextButton = UIButton()
        view.addSubview(nextButton)
        nextButton.configuration = .plain()
        nextButton.setTitle("下一步 ⏵", for: .normal)
        nextButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nextButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            nextButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -30)
        ])
        
    }
    
    
    

    
}



extension InitialViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        tagsChoices.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(TagsCollectionViewCell.self)", for: indexPath) as! TagsCollectionViewCell
        cell.tagButton.setTitle(tagsChoices[indexPath.item], for: .normal)
//        cell.tagButton.titleLabel?.font = UIFont.systemFont(ofSize: 21)
        cell.tagButton.layer.cornerRadius = cell.tagButton.frame.height/2 //=75/2
//        print(cell.tagButton.frame.height)
        cell.tagButton.clipsToBounds = true
        cell.tagButton.configuration = .filled()
        cell.tagButton.configuration?.contentInsets = .init(top: 20, leading: 20, bottom: 20, trailing: 20)
        
        cell.tagButton.addAction(UIAction(handler: { _ in
            cell.tagButton.isEnabled = false
            self.userSelection.append(self.tagsChoices[indexPath.item])
            print(self.userSelection)
        }), for: .touchUpInside)
        
        return cell
    }
    
    
}
