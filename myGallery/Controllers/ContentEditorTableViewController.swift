//
//  ContentEditorTableViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/12.
//

import UIKit

class ContentEditorTableViewController: UITableViewController {

    var selectedImage: UIImage!

    @IBOutlet var selectedImageView: UIImageView!
    
    var contentTextView = UITextView()
    
    var imageCellheght = CGFloat()
    var textCellHeight = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        selectedImageView.image = selectedImage
        
        print("2222")
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    
    func checkTextViewHeight() {
        
        print("11111")
        
        DispatchQueue.main.async {
            let indexPathForRow0 = IndexPath(row: 0, section: 0)
            if let cell = self.tableView.cellForRow(at: indexPathForRow0) {
                print("22222")
                let cellFrame = cell.frame
                self.textCellHeight = UIScreen.main.bounds.height - cellFrame.maxY
                print("33333 height",self.textCellHeight)
            }
        }
        tableView.reloadData()

        
    }

    // MARK: - Table view data source

    /*
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }
     */

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        print("1111")
        return 2
    }
    
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0 {
//            let cell = UITableViewCell(style: .default, reuseIdentifier: "imageCell")
//
//            imageCellheght = cell.frame.maxY
//            return cell
//        } else {
//            let cell = UITableViewCell(style: .default, reuseIdentifier: "textCell")
//
//
//            return cell
//        }
//
//    }

    
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        print("0000")
        
        if indexPath.row == 0 {
            return UIScreen.main.bounds.width
            
        } else {
            
            let naviHeight = (navigationController?.navigationBar.bounds.height) ?? 44
            print("naviHeight",naviHeight)

            return UIScreen.main.bounds.height - UIScreen.main.bounds.width - view.safeAreaInsets.top - naviHeight - 48
        }
    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
