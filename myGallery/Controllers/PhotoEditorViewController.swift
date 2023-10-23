//
//  PhotoEditorViewController.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/5.
//

import UIKit
import PhotosUI
import Alamofire
import CoreImage.CIFilterBuiltins


class PhotoEditorViewController: UIViewController {
    
    var airTableRecords = AirtableRecords(records: [])
    
    var selectedImage: UIImage?
    
    @IBOutlet var imageResultView: UIView!

    @IBOutlet var resultImagebg: UIImageView!
    
    @IBOutlet var blurEffect: UIVisualEffectView!
    
    @IBOutlet var resultImage: UIImageView!
    
    @IBOutlet var addImageButton: UIButton!
    
    
    @IBOutlet var mainStackView: UIStackView!
    
    @IBOutlet var settingStackViews: [UIStackView]!
    
    
    @IBOutlet var cropStackView: UIStackView!
    @IBOutlet var ratioStackView: UIStackView!
    
    @IBOutlet var rotateStackView: UIStackView!
    
    @IBOutlet var filterStackView: UIStackView!
    
    
    @IBOutlet var blurStackView: UIStackView!
    
    var widthConstraints: [NSLayoutConstraint] = []
    var imageRatio: CGFloat = 1
    
    var cummulativeAngle:CGFloat = 0
    var reverseX = false
    var reverseY = false
    var scaleX:CGFloat = 1
    var scaleY:CGFloat = 1
    
    var finalImage: UIImage?
    var noteString: String?
    var imageURL: URL?
    
    @IBOutlet var filterButtons: [UIButton]!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        resultImage.contentMode = .scaleAspectFill
        blurEffect.isHidden = true
        resultImagebg.contentMode = .scaleAspectFill
        
        defaultSettingStackViews()
        mainStackView.isHidden = true
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
        
        resultImage.contentMode = .scaleAspectFit
            
    }
    
    func defaultSettingStackViews() {

        for view in settingStackViews {
            view.isHidden = true
            
            view.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                view.topAnchor.constraint(equalTo: imageResultView.bottomAnchor, constant: 32),
                view.centerXAnchor.constraint(equalTo: imageResultView.centerXAnchor)
            ])

        }
        
    }
    
    @IBAction func addPhoto(_ sender: Any) {
        
        var config = PHPickerConfiguration()
        config.filter = .images
        let imagePicker = PHPickerViewController(configuration: config)
        imagePicker.delegate = self
        present(imagePicker, animated: true)
    }
    

    
    @IBAction func crop(_ sender: Any) {
        defaultSettingStackViews()
        cropStackView.isHidden = false
    }
    
    
    @IBAction func rotate(_ sender: Any) {
        defaultSettingStackViews()
        rotateStackView.isHidden = false
    }
    
    @IBAction func addFilter(_ sender: Any) {
        defaultSettingStackViews()
        filterStackView.isHidden = false
    }
    
    @IBAction func adjustBlur(_ sender: Any) {
        defaultSettingStackViews()
        blurStackView.isHidden = false
    }
    
    
    @IBAction func adjustRatio(_ sender: UIButton) {
        
        currentTransform()
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

        resultImage.contentMode = .scaleAspectFill
        NSLayoutConstraint.activate(widthConstraints)
        view.layoutIfNeeded()
        
        selectedImage = resultImage.image

    }
    
    
    fileprivate func currentTransform() {
        resultImage.transform =
        CGAffineTransform(scaleX: scaleX, y: scaleY).rotated(by: .pi/180*cummulativeAngle)
    }
    
    @IBAction func adjustRotation(_ sender: UIButton) {
        
        switch sender.tag {
        case 0:
            cummulativeAngle -= 90
            currentTransform()

        case 1:
            cummulativeAngle += 90
            currentTransform()

        case 2:
            reverseX.toggle()
            if reverseX == true {
                scaleX = -1
            } else {
                scaleX = 1
            }
            currentTransform()
            
        case 3:
            reverseY.toggle()
            if reverseY == true {
                scaleY = -1
            } else {
                scaleY = 1
            }
            currentTransform()
            
        default:
            return
        }

    }
    
    

    @IBAction func applyFilter(_ sender: UIButton) {
        
        var filter:CIFilter?
            
        switch sender.tag {
        case 0:
            resultImage.image = selectedImage
            resultImagebg.image = selectedImage
        case 1:
            filter = CIFilter.photoEffectChrome()
        case 2:
            filter = CIFilter.photoEffectFade()
        case 3:
            filter = CIFilter.photoEffectTransfer()
        case 4:
            filter = CIFilter.photoEffectInstant()
        case 5:
            filter = CIFilter.photoEffectNoir()
        default:
            return
        }
        
        if let selectedImage, let filter {
            updateFilter(image: selectedImage, filter: filter)
        }
        
    }

    
    func updateFilter(image: UIImage,filter: CIFilter) {
        
        var ciImage = CIImage(image: image)
        filter.setValue(ciImage, forKey: kCIInputImageKey)

        if let outputImage = filter.outputImage {
            
            // 創建 CIContext
            let context = CIContext(options: nil)
            // 轉換為 CGImage
            if let cgImage = context.createCGImage(outputImage, from: outputImage.extent) {
                // 將 CGImage 轉換為 UIImage 並應用圖片方向
                let filteredImage = UIImage(cgImage: cgImage, scale: UIScreen.main.scale, orientation: image.imageOrientation)
                resultImage.image = filteredImage
                resultImagebg.image = filteredImage

            }
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
    
    func graphicsImageRenderer() -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: imageResultView.bounds.size)
        let image = renderer.image { context in
            imageResultView.drawHierarchy(in: imageResultView.bounds, afterScreenUpdates: true)
        }
        return image
    }
    
    @IBSegueAction func showNoteEditor(_ coder: NSCoder) -> NoteEditorViewController? {
        let controller = NoteEditorViewController(coder: coder)

        let image = graphicsImageRenderer()
        controller?.backgroundImage = image
        controller?.newRecord = true
        
        controller?.completion = { [weak self] text in
            self?.noteString = text
        }
        
        if let noteString {
            controller?.noteString = noteString
        }
        
        return controller
    }


    func uploadImage(image: UIImage, completion: @escaping ((URL) -> Void)) {
        
        let apiURL = "https://api.imgur.com/3/image"
        let headers:HTTPHeaders = [
            "Authorization":"Client-ID 9934154cab5bcf5"]
        
        AF.upload(multipartFormData: { data in
            if let imageData = image.jpegData(compressionQuality: 0.8) {
                data.append(imageData, withName: "image")
            }
        }, to: apiURL, headers: headers).responseDecodable(of: UploadedImage.self, queue: .main, decoder: JSONDecoder()) { response in
            switch response.result {
            case .success(let result):
                self.imageURL = result.data.link
                completion(result.data.link)
            case .failure(let error):
                print("uploadImage error:",error)
            }
        }
        
    }
   
    
    @IBAction func uploadRecord(_ sender: Any) {
        let image = graphicsImageRenderer()
        uploadImage(image: image) { imageUrl in
            
            let iso8601Formatter = ISO8601DateFormatter()
            let dateString = iso8601Formatter.string(from: Date())
            
            let record = AirtableRecords(records: [Records(fields: Fields(date: dateString, imageURL: imageUrl, notes: self.noteString))])
            Airtable.shared.uploadToAirtable(record: record) {
                Airtable.shared.getRecords { records in
                    NotificationCenter.default.post(name: NSNotification.Name("DataReceived"), object: records)
                }
            }
        }
        
        navigationController?.popToRootViewController(animated: true)
        
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
                    if let self = self, let selectedImage = image as? UIImage, self.resultImage.image == existedImage {
                        
                        self.selectedImage = selectedImage
                        self.resultImage.image = selectedImage
                        self.resultImagebg.image = selectedImage
                        self.addImageButton.isHidden = true
                        self.blurEffect.isHidden = false
                        self.mainStackView.isHidden = false
                        self.view.layoutIfNeeded()
                        //將圖片大小調整與 imageView 一致，以便後續進行影像編輯。
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
        
        if let image = resultImage.image {
            imageRatio = image.size.height/image.size.width
            
            if imageRatio >= 1 {
                //portrait
                let size = CGSize(width: resultImage.frame.height/imageRatio, height: resultImage.frame.height)
                let renderer = UIGraphicsImageRenderer(size: size)
                resizedImage = renderer.image(actions: { (context) in
                    image.draw(in: renderer.format.bounds)
                })
//                resizedImage = image.af.imageScaled(to: size) //af.imageScaled 畫質壓縮太多啦
            } else {
                //landscape
                let size = CGSize(width: resultImage.frame.width, height: imageRatio*resultImage.frame.width)
                let renderer = UIGraphicsImageRenderer(size: size)
                resizedImage = renderer.image(actions: { (context) in
                    image.draw(in: renderer.format.bounds)
                })
//                resizedImage = image.af.imageScaled(to: size)
            }
        }

        resultImage.image = resizedImage
        
    }
    
}
