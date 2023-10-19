//
//  DetailViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/19.
//

import UIKit
import AlamofireImage

class DetailViewController: UIViewController {
    
    var detailImageURL: URL!
    var detailNote: String!
    
    @IBOutlet var detailImageVIew: UIImageView!
    @IBOutlet var detailTextview: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        detailImageVIew.af.setImage(withURL: detailImageURL)
        detailTextview.text = detailNote
        
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
