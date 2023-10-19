//
//  HomeViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/14.
//

import UIKit
import AlamofireImage


class HomeViewController: UIViewController {

    var tableName: String?
    var airTableRecords = AirtableRecords(records: [])
    
    @IBOutlet var contentCollectionView: UICollectionView!
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    fileprivate func updateRecords() {
        Airtable.shared.getRecords { records in
            if let records {
                self.airTableRecords = records
                DispatchQueue.main.async {
                    self.contentCollectionView.reloadData()
                    print(self.airTableRecords)
                }
                
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        contentCollectionView.dataSource = self
        contentCollectionView.delegate = self
        
        // Do any additional setup after loading the view.
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        checkFirstLaunch()
        
        updateRecords()

        
    }
    
    

    
    
    func checkFirstLaunch() {
        print(UserDefaults.standard.value(forKey: "FirstLaunch") ?? "no data yet")
        guard let firstLaunch: Bool = UserDefaults.standard.value(forKey: "FirstLaunch") as? Bool else {
            print("is first launch")
            tableName = Airtable.shared.createNewTable()
//            tableName = createNewTable()
            loadingIndicator.stopAnimating()
            loadingIndicator.isHidden = true
            
            UserDefaults.standard.setValue(false, forKey: "FirstLaunch")
            UserDefaults.standard.setValue(tableName, forKey: "TableName")
            print("TableName",tableName)
            
            return
        }

    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}


extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let records = airTableRecords.records {
            return records.count
        } else {
            return 0
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "\(PostsCollectionViewCell.self)", for: indexPath) as! PostsCollectionViewCell
        
        if let records = airTableRecords.records {
            let url = records[indexPath.item].fields.imageURL
            Airtable.shared.fetchImage(url: url) { image in
                DispatchQueue.main.async {
                    cell.contentImageView.image = image
                    self.loadingIndicator.stopAnimating()
                    self.loadingIndicator.isHidden = true
                }
                
            }
        }
        
        return cell
    }

    
}
