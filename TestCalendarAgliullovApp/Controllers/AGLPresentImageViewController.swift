//
//  AGLPresentImageViewController.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 25.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLPresentImageViewController: UIViewController {
        
    internal var selectedImage: UIImage? {
        didSet {
            if let image = self.selectedImage {
                self.imageView.image = image
            }
        }
    }
    
    internal let imageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.contentMode = .scaleAspectFit
        return image
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Изображение события"
        self.view.backgroundColor = UIColor.white
        self.imageView.frame = self.view.bounds
        self.navigationItem.setLeftBarButton(UIBarButtonItem(title: "Закрыть", style: .done, target: self, action: #selector(closeImage)), animated: false)
        self.view.addSubview(imageView)
    }
    
    @objc fileprivate func closeImage() {
        self.dismiss(animated: true, completion: nil)
    }
}
