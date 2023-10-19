//
//  NoteEditorViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/13.
//

import UIKit
import AlamofireImage

class NoteEditorViewController: UIViewController {

    var backgroundImage: UIImage!
    
    var newRecord: Bool = true
    var selectedRecordField: Fields?
    var recordID: String?
    var detailImageURL: URL?
    var detailNote: String?
    
    var editStatus: Bool = false
    
    @IBOutlet var mainImageView: UIImageView!
    
    @IBOutlet var backgroundImageView: UIImageView!

    @IBOutlet var backgroundTextView: UITextView!
    
    @IBOutlet var inputTextView: UITextView!
    
    @IBOutlet var textViews: [UITextView]!
    
    var contentHeight: Int = 0 {
        didSet {
            addBottomLine()
        }
    }
    
    var noteString: String?
    var completion: ((String)->Void)?
    
    @IBOutlet var toolButtons: [UIBarButtonItem]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundTextView.delegate = self
        inputTextView.delegate = self
        // Do any additional setup after loading the view.
        
        setUpBackground()
        
        if newRecord == false {
            if let detailImageURL {
                mainImageView.af.setImage(withURL: detailImageURL)
                backgroundImageView.af.setImage(withURL: detailImageURL)
                if let detailNote {
                    inputTextView.text = detailNote
                }
                inputTextView.isEditable = false
                
                for button in toolButtons {
                    button.isHidden = false
                }
            }
        } else {
            
            if let noteString {
                inputTextView.text = noteString
            }
            for button in toolButtons {
                button.isHidden = true
            }
        }
        
        
        NotificationCenter.default.addObserver(self,
        selector: #selector(keyboardWillShow), 
        name: UIResponder.keyboardWillShowNotification, object: nil)


        NotificationCenter.default.addObserver(self,
        selector: #selector(keyboardWillHide),
        name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    func setUpBackground() {
        mainImageView.image = backgroundImage
        
        backgroundImageView.image = backgroundImage
        backgroundImageView.alpha = 0.8
        
        backgroundTextView.backgroundColor = .white
        backgroundTextView.alpha = 0.85
//        inputTextView.backgroundColor = .white
//        inputTextView.alpha = 0.8
        backgroundTextView.textColor = .systemGray5
        
        for _ in 1...25*25 {
            backgroundTextView.text += "_"
        }
        backgroundTextView.font = UIFont.systemFont(ofSize: 20)
        backgroundTextView.layer.cornerRadius = 12
        backgroundTextView.clipsToBounds = true
//        print("check height:",inputTextView.contentSize.height,inputTextView.bounds.height)
        for textView in textViews {
            textView.textContainerInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        }

        let style = NSMutableParagraphStyle()
        style.lineSpacing = 2.4
        let font = UIFont.systemFont(ofSize: 18)
        
        let attributes:[NSAttributedString.Key:Any] = [
            .paragraphStyle:style,
            .font:font
        ]
        
        inputTextView.typingAttributes = attributes
        
        contentHeight = Int(inputTextView.contentSize.height)
//        print("initial:",contentHeight,backgroundTextView.text.count/25,backgroundTextView.text.count)
    }
    
    func addBottomLine() {
        
        if contentHeight > Int(inputTextView.bounds.height) {
            var bottomLine = ""
            for _ in 1...(contentHeight/25*25+25) {
                bottomLine += "_"
            }
            
            backgroundTextView.text = bottomLine
            
//            print(contentHeight,backgroundTextView.text.count/25,backgroundTextView.text.count)
        }
  
    }
    
    @IBAction func edit(_ sender: UIBarButtonItem) {
        
        if editStatus == false {
            inputTextView.isEditable = true
            inputTextView.becomeFirstResponder()
            sender.image = UIImage(systemName: "checkmark")
            editStatus.toggle()
        } else {
            let noteString = inputTextView.text
            if let recordID, let selectedRecordField {
                let record = AirtableRecords(records: [Records(id: recordID, fields: Fields(date: selectedRecordField.date, imageURL: selectedRecordField.imageURL, notes: noteString))])
                Airtable.shared.sentEditedRecord(record: record) {
                    Airtable.shared.getRecords { records in
                        print("editing delegate send data",records)
                        NotificationCenter.default.post(name: NSNotification.Name("DataReceived"), object: records)
                    }
                }
            }
            
            inputTextView.isEditable = false
            sender.image = UIImage(systemName: "square.and.pencil")
            editStatus.toggle()
        }
    }
    
    @IBAction func remove(_ sender: Any) {
        let alertController = UIAlertController(title: "Delete Alert", message: "This record will be deleted permanently.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) {_ in 
            print("confirm delete")
            if let id = self.recordID {
                Airtable.shared.removeRecord(id: id) {
                    Airtable.shared.getRecords { records in
                        print("removed delegate send data",records)
                        NotificationCenter.default.post(name: NSNotification.Name("DataReceived"), object: records)
                    }
                }
            }
            self.navigationController?.popToRootViewController(animated: true)
        }
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        present(alertController,animated: true,completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @objc func keyboardWillShow(notification: NSNotification) {
        //使用 notification 找出 keyboard 的高度
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        {
            let height = keyboardSize.height
            //修改 textView 底部距的 constant 來移動對話框。
            let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: height, right: 0)
            
            for textView in textViews {
                textView.contentInset = contentInsets
                textView.scrollIndicatorInsets = contentInsets
            }

        }
        if inputTextView.isFirstResponder {
            inputTextView.scrollRectToVisible(inputTextView.frame, animated: true)
             }
    }


    @objc func keyboardWillHide(notification: NSNotification) {
        let contentInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        
        for textView in textViews {
            textView.contentInset = contentInsets
            textView.scrollIndicatorInsets = contentInsets
        }
        
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }

}

extension NoteEditorViewController: UITextViewDelegate, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == inputTextView {
            backgroundTextView.contentOffset = inputTextView.contentOffset
        }
        
        contentHeight = Int(inputTextView.contentSize.height)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if let text = inputTextView.text {
            completion?(text)
//            print("NoteEditorVC",text)
        }
        
        
        
    }
    
    
}
