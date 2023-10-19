//
//  HomeCollectionViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/19.
//

import UIKit

private let reuseIdentifier = "Cell"

class HomeCollectionViewController: UICollectionViewController {
    
    var tableName: String?
    var airTableRecords = AirtableRecords(records: [])

    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        loadingIndicator.isHidden = false
        loadingIndicator.startAnimating()
        checkFirstLaunch()
        
        updateRecords()

        setupCellSize()

        
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }

    fileprivate func updateRecords() {
        Airtable.shared.getRecords { records in
            if let records {
                self.airTableRecords = records
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
                    print(self.airTableRecords)
                }
                
            }
        }
    }
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: UICollectionViewDataSource

    /*
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return airTableRecords.records.count
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostsCollectionViewCell", for: indexPath) as! PostsCollectionViewCell
    
        // Configure the cell
        let url = airTableRecords.records[indexPath.item].fields.imageURL
        Airtable.shared.fetchImage(url: url) { image in
            DispatchQueue.main.async {
                
                cell.postImage.image = image
                cell.postImage.layer.cornerRadius = 8
                cell.postImage.clipsToBounds = true
                
//
//                cell.postButton.setImage(image, for: .normal)
//                cell.postButton.layer.cornerRadius = 8
//                cell.postButton.clipsToBounds = true
//                cell.postButton.tag = indexPath.item
//                cell.postButton.addAction(UIAction(handler: { _ in
//
//
//
//                }), for: .touchUpInside)
                
                self.loadingIndicator.stopAnimating()
                self.loadingIndicator.isHidden = true
            }
            
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
         
        if let controller = storyboard?.instantiateViewController(identifier: "\(NoteEditorViewController.self)") as? NoteEditorViewController {
            
            controller.detailImageURL =  airTableRecords.records[indexPath.item].fields.imageURL
            controller.detailNote = airTableRecords.records[indexPath.item].fields.notes
            controller.newRecord = false

            
            navigationController?.pushViewController(controller, animated: true)
        }
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
    
    func setupCellSize() {
        
        let itemSpace: Double = 2
        let columnCount: Double = 2

        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let width = floor((collectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
        flowLayout?.itemSize = CGSize(width: width, height: width)
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
    }
   

    
    
    
    
    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
