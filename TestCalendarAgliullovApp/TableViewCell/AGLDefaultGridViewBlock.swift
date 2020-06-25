//
//  AGLDefaultGridViewBlock.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLDefaultGridViewBlock: AGLDefaultGridCell, UITextFieldDelegate  {
    
    internal let mainTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.textColor = UIColor.black
        textField.font = UIFont.boldSystemFont(ofSize: 17.0)
        textField.placeholder = "Введите название"
        textField.textAlignment = .left
        textField.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        textField.borderStyle = UITextField.BorderStyle.roundedRect
        return textField
    }()
    
    internal let detailTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.textColor = UIColor.black.withAlphaComponent(0.8)
        textView.font = UIFont.boldSystemFont(ofSize: 14.0)
        textView.textAlignment = .left
        textView.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        return textView
    }()
    
    override func initialSetup() {
        self.contentView.addSubview(self.mainTextField)
        self.contentView.addSubview(self.detailTextView)
        mainTextField.delegate = self
        
        let constraints: [NSLayoutConstraint] = [
            
            //mainTextField
            self.mainTextField.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor),
            self.mainTextField.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.mainTextField.rightAnchor),
            
            //detailTextView
            self.detailTextView.leftAnchor.constraint(equalTo: self.mainTextField.leftAnchor),
            self.detailTextView.topAnchor.constraint(equalTo: self.mainTextField.bottomAnchor, constant: 4.0),
            self.detailTextView.heightAnchor.constraint(equalToConstant: 100.0),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.detailTextView.rightAnchor),
            self.contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: self.detailTextView.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.detailTextView.layer.cornerRadius = 5
        self.detailTextView.layer.borderWidth = 1
        self.detailTextView.layer.borderColor = UIColor.gray.cgColor
        self.detailTextView.clipsToBounds = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == mainTextField {
            self.mainTextField.resignFirstResponder()
            self.detailTextView.becomeFirstResponder()
        }
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.mainTextField.resignFirstResponder()
        self.detailTextView.resignFirstResponder()
    }
}
