//
//  AGLDatePickerTableViewCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLDatePickerTableViewCell: AGLDefaultGridCell {
    
    internal let timeIntervalPicker: UIDatePicker = {
        let timePicker = UIDatePicker()
        timePicker.translatesAutoresizingMaskIntoConstraints = false
        timePicker.minimumDate = Date()
        timePicker.locale = Locale(identifier: "RU")
        timePicker.datePickerMode = .time
        return timePicker
    }()
    
    override func initialSetup() {
        self.contentView.addSubview(self.timeIntervalPicker)
        
        let constraints: [NSLayoutConstraint] = [
            self.timeIntervalPicker.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            self.timeIntervalPicker.widthAnchor.constraint(equalToConstant: self.contentView.frame.width),
            self.timeIntervalPicker.heightAnchor.constraint(equalToConstant: 200.0),
            self.timeIntervalPicker.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor),
            self.timeIntervalPicker.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
