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
    var downloadedImages: [Bool] = []
    
    var columnCount: Double = 3
    var itemSpace: Double = 2

    var fetchCount = 0
    
    @IBOutlet var loadingIndicator: UIActivityIndicatorView!
    @IBOutlet var emptyReminder: UILabel!
    @IBOutlet var loadingView: UIView!
    
    
    func loadingToggle(on: Bool) {
        if on == true {
            loadingIndicator.isHidden = false
            loadingIndicator.startAnimating()
        } else {
            loadingIndicator.isHidden = true
            loadingIndicator.stopAnimating()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkFirstLaunch()
        setupCellSize()
//        updateRecords()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    var workItem: DispatchWorkItem?
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        emptyReminder.isHidden = true
        loadingToggle(on: true)
        
        workItem = DispatchWorkItem { [weak self] in
            self?.updateRecords() //default update
        }
        DispatchQueue.global().async(execute: workItem!)
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DataReceived"), object: nil, queue: nil) { notification in
            print("000 NotificationCenter observer")
            DispatchQueue.main.async {
                self.loadingToggle(on: true)
            }
            
            if let records = notification.object as? AirtableRecords {
                self.airTableRecords = records
                DispatchQueue.main.async {
                    
                    self.workItem?.cancel()
                    self.workItem = DispatchWorkItem {
                        self.fetchCount = 0
                        self.updateRecords() //updatest update
                   }
                    DispatchQueue.global().async(execute: self.workItem!)
                                
//                    self.updateRecords()
                }
            }
        }
        
    }
    

    fileprivate func updateRecords() {
        fetchCount = 0
        Airtable.shared.getRecords { records in
            if let records {
                self.airTableRecords = records
                DispatchQueue.main.async {
                    self.collectionView.reloadData()
//                    print(self.airTableRecords)
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
//        print("airTableRecords.records.count",airTableRecords.records?.count)
        if let records = airTableRecords.records {
            
            if !(records.count > 0) {
                print("emptyReminder should show or hide!")
                self.emptyReminder.isHidden = false
            } else {
                self.emptyReminder.isHidden = true
            }
            return records.count
        } else {
            return 0
        }
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PostsCollectionViewCell", for: indexPath) as! PostsCollectionViewCell
        collectionView.bringSubviewToFront(loadingView)
        
        // Configure the cell
        if let records = airTableRecords.records {
            
            if let url = records[indexPath.item].fields.imageURL {
//                print("url = records[indexPath.item].fields.imageURL")
                Airtable.shared.fetchImage(url: url) {
                    image in
//                    print("airtable.shared.fectchImage")
                    DispatchQueue.main.async {
                        cell.postImage.image = image
                        self.fetchCount += 1
                        print("run count:",self.fetchCount,records.count,"loadingIndicator.isHidden",self.loadingIndicator.isHidden,"loadingIndicator.isAnimating",self.loadingIndicator.isAnimating)
                        if self.fetchCount == records.count {
                            self.loadingToggle(on: false)
                            print("run end","loadingIndicator.isHidden",self.loadingIndicator.isHidden,"loadingIndicator.isAnimating",self.loadingIndicator.isAnimating)
                        }
                    }
                }
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let controller = storyboard?.instantiateViewController(identifier: "\(NoteEditorViewController.self)") as? NoteEditorViewController {
//            print("check airTableRecords.records.count wheh selected",airTableRecords.records?.count,[indexPath.item],"-----imageURL:",airTableRecords.records?[indexPath.item].fields.imageURL,"-----note:",airTableRecords.records?[indexPath.item].fields.notes)
            if let records = airTableRecords.records {
                controller.recordID = records[indexPath.item].id
                controller.selectedRecordField = records[indexPath.item].fields
                controller.detailImageURL =  records[indexPath.item].fields.imageURL
                controller.detailNote = records[indexPath.item].fields.notes
                controller.newRecord = false
                
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    
    func checkFirstLaunch() {
        print(UserDefaults.standard.value(forKey: "FirstLaunch") ?? "no data yet")
        guard let firstLaunch: Bool = UserDefaults.standard.value(forKey: "FirstLaunch") as? Bool else {
            print("is first launch")
            tableName = Airtable.shared.createNewTable()
//            tableName = createNewTable()
//            stopLoading()
            
            UserDefaults.standard.setValue(false, forKey: "FirstLaunch")
            UserDefaults.standard.setValue(tableName, forKey: "TableName")
            print("TableName",tableName)
            
            return
        }

    }
    
    func setupCellSize() {

        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let width = floor((collectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
        flowLayout?.itemSize = CGSize(width: width, height: width)
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
    }
   

    @IBAction func zoom(_ sender: UIBarButtonItem) {
//        print("zoom tapped")

        
        switch sender.tag {
        case 0:
            if columnCount < 7 {
                columnCount += 1
            }
        case 1:
            if columnCount > 1 {
                columnCount -= 1
            }
        default:
            return
        }
        

        switch columnCount {
        case 1:
            itemSpace = 4
        case 6:
            itemSpace = 1
        case 7:
            itemSpace = 0
        default:
            itemSpace = 2
        }
        
        setupCellSize()
//        collectionView.reloadData()

        
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
