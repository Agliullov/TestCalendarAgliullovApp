//
//  AGLDefaultButtonTableCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLDefaultButtonTableCell: AGLDefaultGridCell {
        
    internal let buttonAction: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Save", for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = DEFAULT_BUTTON_HEIGHT / 2
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 17.0)
        return button
    }()
    
    override func initialSetup() {
        self.contentView.addSubview(self.buttonAction)
        
        let constraints: [NSLayoutConstraint] = [
            self.buttonAction.heightAnchor.constraint(equalToConstant: DEFAULT_BUTTON_HEIGHT),
            self.buttonAction.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(greaterThanOrEqualTo: self.buttonAction.rightAnchor),
            self.buttonAction.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.buttonAction.centerYAnchor.constraint(greaterThanOrEqualTo: self.contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
