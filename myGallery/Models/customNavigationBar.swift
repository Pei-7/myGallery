//
//  customNavigationBar.swift
//  myGallery
//
//  Created by 陳佩琪 on 2023/10/21.
//

import Foundation
import UIKit

class CustomNavigationController: UINavigationController {
    
    let progressBar = UIProgressView(progressViewStyle: .default)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 設定進度條的顏色
        progressBar.trackTintColor = UIColor.lightGray
        progressBar.progressTintColor = UIColor.tintColor

        // 設定進度條的初始值
        progressBar.progress = 0.0

        // 將進度條添加到導航欄的底部
        navigationBar.addSubview(progressBar)
    }

    // 在視圖控制器的網頁載入進度改變時更新進度條
    func updateProgressBar(progress: Float) {
        progressBar.setProgress(progress, animated: true)
    }
}
