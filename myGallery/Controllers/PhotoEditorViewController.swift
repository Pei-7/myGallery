//
//  PhotoEditorViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/5.
//

import UIKit
import PhotosUI

class PhotoEditorViewController: UIViewController {
    
    @IBOutlet var imageResultView: UIView!

    @IBOutlet var resultImagebg: UIImageView!
    
    @IBOutlet var blurEffect: UIVisualEffectView!
    
    @IBOutlet var resultImage: UIImageView!
    
    @IBOutlet var addImageButton: UIButton!
    
    
    @IBOutlet var settingStackViews: [UIStackView]!
    
    
    @IBOutlet var cropStackView: UIStackView!
    @IBOutlet var ratioStackView: UIStackView!
    
    @IBOutlet var rotateStackView: UIStackView!
    

    
    @IBOutlet var blurStackView: UIStackView!
    
//    var pinchCount = 0
//    var cummulativeScale: CGFloat = 1
    var widthConstraints: [NSLayoutConstraint] = []
    var imageRatio: CGFloat = 1
    
    var cummulativeAngle:CGFloat = 0
    var reverseX = false
    var reverseY = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        resultImage.contentMode = .scaleAspectFill
        blurEffect.isHidden = true
        resultImagebg.contentMode = .scaleAspectFill
        
        defaultUI()

        setImageConstraints()

    }
    
    
    func setImageConstraints() {
        resultImage.translatesAutoresizingMaskIntoConstraints = false
        
        //變動 constraints
        widthConstraints = [
            resultImage.widthAnchor.constraint(lessThanOrEqualToConstant: imageResultView.frame.width)
        ]
            NSLayoutConstraint.activate(widthConstraints)
        
        //固定 constraints
        NSLayoutConstraint.activate([      resultImage.centerXAnchor.constraint(equalTo: imageResultView.centerXAnchor),
            resultImage.centerYAnchor.constraint(equalTo: imageResultView.centerYAnchor),
            resultImage.heightAnchor.constraint(equalToConstant: imageRatio*resultImage.frame.width)])
        
//        print("999 imageView width & height: ",resultImage.frame.width,resultImage.frame.height)
        
        resultImage.contentMode = .scaleAspectFit
            
    }
    
    func defaultUI() {

        for view in settingStackViews {
            view.isHidden = true
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: imageResultView.bottomAnchor, constant: 16),
                view.centerXAnchor.constraint(equalTo: imageResultView.centerXAnchor)
            ])

        }
        
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        defaultUI()
        
        var config = PHPickerConfiguration()
        config.filter = .images
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    

    
    @IBAction func crop(_ sender: Any) {
        defaultUI()

        cropStackView.isHidden = false
    }
    
    
    @IBAction func rotate(_ sender: Any) {
        defaultUI()
        rotateStackView.isHidden = false
    }
    
    @IBAction func addFilter(_ sender: Any) {
        defaultUI()
    }
    
    @IBAction func adjustBlur(_ sender: Any) {
        defaultUI()
        blurStackView.isHidden = false
    }
    
    
    @IBAction func adjustRatio(_ sender: UIButton) {
//        print("adjustRatio")
        
        resultImage.transform = CGAffineTransform(scaleX: 1, y: 1)
        
        NSLayoutConstraint.deactivate(widthConstraints)

        
        var newRatio: CGFloat = 1
        switch sender.tag {
        case 0:
            newRatio = 1
        case 1:
            newRatio = 3/4
        case 2:
            newRatio = 9/16

        default:
            return
        }

        if imageRatio > 1 {
            //portrait

            widthConstraints = [ resultImage.widthAnchor.constraint(equalToConstant: newRatio*imageResultView.frame.width)]
        }  else {
            //landscape

            widthConstraints = [
                resultImage.heightAnchor.constraint(equalToConstant: newRatio*imageResultView.frame.height)]
        }
        
//        print("11111 width & height",resultImage.frame.width,resultImage.frame.height)

        resultImage.contentMode = .scaleAspectFill
        
        NSLayoutConstraint.activate(widthConstraints)
        view.layoutIfNeeded()
        
        

    }
    
    
    @IBAction func adjustRotation(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            cummulativeAngle -= 90
            resultImage.transform = CGAffineTransform(rotationAngle: .pi/180*cummulativeAngle)

        case 1:
            cummulativeAngle += 90
            resultImage.transform = CGAffineTransform(rotationAngle: .pi/180*cummulativeAngle)

        case 2:
            reverseX.toggle()
            if reverseX == true {
                resultImage.transform = CGAffineTransform(scaleX: -1, y: 1)
            } else {
                resultImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        case 3:
            reverseY.toggle()
            if reverseY == true {
                resultImage.transform = CGAffineTransform(scaleX: 1, y: -1)
            } else {
                resultImage.transform = CGAffineTransform(scaleX: 1, y: 1)
            }
            
        default:
            return
        }
        
        
        
        
        
    }
    
    
    
    
    
    
    
    
    
    
    @IBAction func adjustBlurStyle(_ sender: UIButton) {
        
        var newBlurEffect : UIVisualEffectView?

        switch sender.tag {
        case 0:
            newBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
        case 1:
            newBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .prominent))
        case 2:
            newBlurEffect = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
        default:
            return
        }
        
        
        blurEffect.removeFromSuperview()
        blurEffect = newBlurEffect
        imageResultView.insertSubview(blurEffect, belowSubview: resultImage)
        
        blurEffect.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            blurEffect.widthAnchor.constraint(equalToConstant: imageResultView.frame.width),
            blurEffect.heightAnchor.constraint(equalToConstant: imageResultView.frame.height),
            blurEffect.leadingAnchor.constraint(equalTo: imageResultView.leadingAnchor),
            blurEffect.topAnchor.constraint(equalTo: imageResultView.topAnchor)
        ])
        
    }
//    
//    @IBSegueAction func showContentEditor(_ coder: NSCoder) -> ContentEditorTableViewController? {
//        let controller =  ContentEditorTableViewController(coder: coder)
//        
//        
//        let renderer = UIGraphicsImageRenderer(size: imageResultView.bounds.size)
//        let image = renderer.image { context in
//            imageResultView.drawHierarchy(in: imageResultView.bounds, afterScreenUpdates: true)
//        }
//        controller?.selectedImage = image
//        
//        return controller
//    }
    
    
    @IBAction func output(_ sender: Any) {
        
        let renderer = UIGraphicsImageRenderer(size: imageResultView.bounds.size)
        let image = renderer.image { context in
            imageResultView.drawHierarchy(in: imageResultView.bounds, afterScreenUpdates: true)
        }
            
        let controller = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(controller, animated: true)
        
    }
    
    @IBSegueAction func showNoteEditor(_ coder: NSCoder) -> NoteEditorViewController? {
        let controller = NoteEditorViewController(coder: coder)
        let renderer = UIGraphicsImageRenderer(size: imageResultView.bounds.size)
        let image = renderer.image { context in
            imageResultView.drawHierarchy(in: imageResultView.bounds, afterScreenUpdates: true)
        }

        controller?.backgroundImage = image
        
        return controller
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

extension PhotoEditorViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProviders = results.map { $0.itemProvider }
        if let itemProvider = itemProviders.first, itemProvider.canLoadObject(ofClass: UIImage.self) {
            let existedImage = self.resultImage.image
            itemProvider.loadObject(ofClass: UIImage.self) {[weak self] (image, error) in
                DispatchQueue.main.async {
                    if let self = self, let selectedImage = image as? UIImage,self.resultImage.image == existedImage {
                        self.resultImage.image = selectedImage
                        self.resultImagebg.image = selectedImage
                        self.blurEffect.isHidden = false
                        self.addImageButton.isHidden = true
                        self.view.layoutIfNeeded()
//                        print("*** imageView width & height: ",self.resultImage.frame.width,self.resultImage.frame.height)
                        self.resizeImage()
                    } else {
                        return
                    }
                }
            }
        }
        
    }
    
    func resizeImage() {
        
        var resizedImage = UIImage()
        
//        print("000 imageView width & height: ",resultImage.frame.width,resultImage.frame.height)
        
        if let image = resultImage.image {
//            print("555")
            imageRatio = image.size.height/image.size.width
            
            if imageRatio >= 1 {
//                print("666")
                //portrait
                
                let size = CGSize(width: resultImage.frame.height/imageRatio, height: resultImage.frame.height)
                let renderer = UIGraphicsImageRenderer(size: size)
                resizedImage = renderer.image(actions: { (context) in
                    image.draw(in: renderer.format.bounds)
                })

            } else {
//                print("777")
                let size = CGSize(width: resultImage.frame.width, height: imageRatio*resultImage.frame.width)
                let renderer = UIGraphicsImageRenderer(size: size)
                resizedImage = renderer.image(actions: { (context) in
                    image.draw(in: renderer.format.bounds)
                })

//                print("888 image width & height",resultImage.frame.width,imageRatio*resultImage.frame.width)
            }


            

        }

        resultImage.image = resizedImage
        
//        print("111 image width & height: ",resultImage.image?.size.width,resultImage.image?.size.height)
    }
    
}

