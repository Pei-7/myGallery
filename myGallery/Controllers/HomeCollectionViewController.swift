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
    
    var columnCount: Double = 3
    var itemSpace: Double {
        switch columnCount {
        case 1:
            return 4
        case 6:
            return 1
        case 7:
            return 0
        default:
            return 2
        }
    }
    

    var receivedNotification: Bool = false
    var fetchCount = 0
    
    @IBOutlet var emptyReminder: UILabel!
    @IBOutlet var loadingView: UIView!
    
    let progressBar = UIProgressView(progressViewStyle: .default)

    
    func createProgressBar() {
        // 設定進度條的顏色
        progressBar.trackTintColor = UIColor.lightGray
        progressBar.progressTintColor = UIColor.tintColor
        progressBar.progress = 0.0

        // 計算進度條的尺寸，以使其填滿導航欄的底部
        let progressBarHeight: CGFloat = 2.0 // 設定進度條的高度
        let progressBarWidth = navigationController?.navigationBar.frame.width ?? 0.0
        let progressBarFrame = CGRect(x: 0, y: navigationController?.navigationBar.frame.height ?? 0.0 - progressBarHeight, width: progressBarWidth, height: progressBarHeight)
        progressBar.frame = progressBarFrame

        // 將進度條添加到導航欄
        navigationController?.navigationBar.addSubview(progressBar)
    }

    func updateProgressBar(progress: Float) {
        print("progress bar = \(progress)")
        progressBar.setProgress(progress, animated: true)
        if progress == 1 {
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { _ in
                self.progressBar.isHidden = true
            }
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkFirstLaunch()
        
        if let savedColumnCount = UserDefaults.standard.value(forKey: "columnCount") as? Double {
            columnCount = savedColumnCount
        }
        setupCellSize(columnCount: columnCount)

        createProgressBar()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        progressBar.setProgress(0, animated: false)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("viewDidAppear")
        emptyReminder.isHidden = true
        DispatchQueue.main.async {
            self.progressBar.isHidden = false
            self.updateProgressBar(progress: 0.1)
        }

        receivedNotification = false
        NotificationCenter.default.addObserver(forName: NSNotification.Name("DataReceived"), object: nil, queue: nil) { notification in
            print("000 NotificationCenter observer")
            self.receivedNotification = true
            DispatchQueue.main.async {
                self.updateProgressBar(progress: 0.3)
            }
            if let records = notification.object as? AirtableRecords {
                self.airTableRecords = records
                DispatchQueue.main.async {
                    self.updateProgressBar(progress: 0.7)
                    self.fetchCount = 0
                    print("reset fetchCount",self.fetchCount)
                    self.updateRecords() //updatest update
                }
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: 2.4, repeats: false) { _ in
            DispatchQueue.main.async {
                self.updateProgressBar(progress: 0.4)
                print("receivedNotification",self.receivedNotification)
                if self.receivedNotification == false {
                    self.updateRecords()
                } else {
                    self.updateProgressBar(progress: 1)

                }
            }
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        DispatchQueue.main.async {
            self.progressBar.isHidden = true
            print("view did disappear",self.progressBar.isHidden)
        }
        
    }
    

    fileprivate func updateRecords() {
        fetchCount = 0
        Airtable.shared.getRecords { records in
            if let records {
                self.airTableRecords = records
                DispatchQueue.main.async {
                    self.updateProgressBar(progress: 0.75)
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
        if let records = airTableRecords.records {
            
            if !(records.count > 0) {
                print("emptyReminder should show!")
                self.emptyReminder.isHidden = false
                Timer.scheduledTimer(withTimeInterval: 4.5, repeats: false) {[weak self] _ in
                    self?.updateProgressBar(progress: 1)
                }
                
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
        
        // Configure the cell
        if let records = airTableRecords.records {
            
            if let url = records[indexPath.item].fields.imageURL {
                Airtable.shared.fetchImage(url: url) { image in
                    DispatchQueue.main.async {
                        // 檢查 cell 的標記是否與當前 indexPath 相符
                        if cell.tag == indexPath.item {
                            cell.postImage.image = image
                            self.fetchCount += 1
                            
                            if self.fetchCount == records.count {
                                self.updateProgressBar(progress: 1)
                            }
                        }
                    }
                }
                // 設置 cell 的標記，以便在下載完成後確認
                cell.tag = indexPath.item
            }
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let controller = storyboard?.instantiateViewController(identifier: "\(NoteEditorViewController.self)") as? NoteEditorViewController {

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
        guard let firstLaunch: Bool = UserDefaults.standard.value(forKey: "FirstLaunch") as? Bool else {
            print("is first launch")
            tableName = Airtable.shared.createNewTable()
            
            UserDefaults.standard.setValue(false, forKey: "FirstLaunch")
            UserDefaults.standard.setValue(tableName, forKey: "TableName")
            print("TableName",tableName)
            
            return
        }

    }
    
    func setupCellSize(columnCount: Double) {

        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let width = floor((collectionView.bounds.width - itemSpace * (columnCount-1)) / columnCount)
        flowLayout?.itemSize = CGSize(width: width, height: width)
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumInteritemSpacing = itemSpace
        flowLayout?.minimumLineSpacing = itemSpace
    }
   

    @IBAction func zoom(_ sender: UIBarButtonItem) {

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
            
        setupCellSize(columnCount: columnCount)
        UserDefaults.standard.setValue(columnCount, forKey: "columnCount")

        
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
