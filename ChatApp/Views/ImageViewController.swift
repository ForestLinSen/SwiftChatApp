//
//  ImageViewController.swift
//  ChatApp
//
//  Created by Sen Lin on 18/1/2022.
//

import UIKit

class ImageViewController: UIViewController {
    
    let imgUrl: URL
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    init(imgUrl: URL){
        self.imgUrl = imgUrl
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(imageView)
        imageView.sd_setImage(with: self.imgUrl, completed: nil)
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        imageView.frame = view.bounds
    }

}
