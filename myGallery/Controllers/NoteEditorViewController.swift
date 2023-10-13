//
//  NoteEditorViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/13.
//

import UIKit

class NoteEditorViewController: UIViewController {

    var backgroundImage: UIImage!
    @IBOutlet var backgroundImageView: UIImageView!
    
    @IBOutlet var backgroundTextView: UITextView!
    
    @IBOutlet var inputTextView: UITextView!
    
    @IBOutlet var textViews: [UITextView]!
    
    var contentHeight: Int = 0 {
        didSet {
            addBottomLine()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        backgroundTextView.delegate = self
        inputTextView.delegate = self
        // Do any additional setup after loading the view.
        
        setUpBackground()
        
        //設置 NotificationCenter ".addObserver" 於鍵盤顯示時通知
        NotificationCenter.default.addObserver(self,
        selector: #selector(keyboardWillShow), //selector 欄位填寫下方設置的 @objc func 名稱
        name: UIResponder.keyboardWillShowNotification, object: nil)

        //設置 NotificationCenter ".addObserver" 於鍵盤隱藏時通知
        NotificationCenter.default.addObserver(self,
        selector: #selector(keyboardWillHide),
        name: UIResponder.keyboardWillHideNotification, object: nil)
        
        
    }
    
    func setUpBackground() {
        backgroundImageView.image = backgroundImage
        backgroundImageView.alpha = 0.8
        
        backgroundTextView.backgroundColor = .white
        backgroundTextView.alpha = 0.8
//        inputTextView.backgroundColor = .white
//        inputTextView.alpha = 0.8
        backgroundTextView.textColor = .systemGray5
        
        for _ in 1...25*25 {
            backgroundTextView.text += "_"
        }
        backgroundTextView.font = UIFont.systemFont(ofSize: 20)
        backgroundTextView.layer.cornerRadius = 12
        backgroundTextView.clipsToBounds = true
        print("check height:",inputTextView.contentSize.height,inputTextView.bounds.height)
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
        print("initial:",contentHeight,backgroundTextView.text.count/25,backgroundTextView.text.count)
    }
    
    func addBottomLine() {
        
        if contentHeight > Int(inputTextView.bounds.height) {
            var bottomLine = ""
            for _ in 1...(contentHeight/25*25+25) {
                bottomLine += "_"
            }
            
            backgroundTextView.text = bottomLine
            
            print(contentHeight,backgroundTextView.text.count/25,backgroundTextView.text.count)
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

    //當鍵盤隱藏時再次修改 textView 底部距離的 constraint
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
}
