//
//  AGLDefaultButtonTableCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLDefaultButtonTableCell: AGLDefaultGridCell {
    
    var buttonActionBlock: (()->())?
    
    var buttonActionContainer: (()->())?
    
    fileprivate let buttonAction: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Прикрепить изображение", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = DEFAULT_BUTTON_HEIGHT / 2
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        return button
    }()
    
    fileprivate let imageContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor.clear
        return view
    }()
    
    fileprivate let openDetailsImageButton: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor.clear
        return button
    }()
    
    internal let taskImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func initialSetup() {
        self.contentView.addSubview(self.buttonAction)
        self.contentView.addSubview(self.imageContainer)
        self.setup()
    }
    
    internal func setup() {
        
        self.imageContainer.addSubview(taskImageView)
        self.imageContainer.addSubview(openDetailsImageButton)
        
        
        self.buttonAction.addTarget(self, action: #selector(openImagePickerButtonDidTapped), for: .touchUpInside)
        self.openDetailsImageButton.addTarget(self, action: #selector(openImageContainerButtonDidTapped), for: .touchUpInside)
        
        let constraints: [NSLayoutConstraint] = [
            //buttonAction
            self.imageContainer.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor),
            self.imageContainer.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.imageContainer.rightAnchor),
            self.imageContainer.heightAnchor.constraint(equalToConstant: 100.0),
            
            //buttonAction
            self.buttonAction.heightAnchor.constraint(equalToConstant: DEFAULT_BUTTON_HEIGHT),
            self.buttonAction.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor, constant: 30.0),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.buttonAction.rightAnchor, constant: 30.0),
            self.buttonAction.topAnchor.constraint(equalTo: self.taskImageView.bottomAnchor, constant: 8.0),
            self.contentView.bottomAnchor.constraint(equalTo: self.buttonAction.bottomAnchor, constant: 4.0),
            
            //openDetailsImageButton
            self.openDetailsImageButton.leftAnchor.constraint(equalTo: self.imageContainer.layoutMarginsGuide.leftAnchor),
            self.openDetailsImageButton.topAnchor.constraint(equalTo: self.imageContainer.layoutMarginsGuide.topAnchor),
            self.imageContainer.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.openDetailsImageButton.rightAnchor),
            self.openDetailsImageButton.heightAnchor.constraint(equalTo: self.imageContainer.layoutMarginsGuide.heightAnchor),
        
            //selfImageContainer
            self.taskImageView.leftAnchor.constraint(equalTo: self.imageContainer.layoutMarginsGuide.leftAnchor),
            self.taskImageView.topAnchor.constraint(equalTo: self.imageContainer.layoutMarginsGuide.topAnchor),
            self.imageContainer.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.taskImageView.rightAnchor),
            self.taskImageView.heightAnchor.constraint(equalTo: self.imageContainer.layoutMarginsGuide.heightAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
    
    @objc fileprivate func openImagePickerButtonDidTapped() {
        self.buttonActionBlock?()
    }
    
    @objc fileprivate func openImageContainerButtonDidTapped() {
        self.buttonActionContainer?()
    }
}
