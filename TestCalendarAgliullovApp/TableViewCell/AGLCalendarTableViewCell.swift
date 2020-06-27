//
//  AGLCalendarTableViewCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 18.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit
import FSCalendar

class AGLCalendarTableViewCell: UITableViewCell {
    
    let calendar: FSCalendar = {
        let calendar = FSCalendar()
        calendar.translatesAutoresizingMaskIntoConstraints = false
        calendar.locale = Locale(identifier: "RU")
        calendar.today = nil
        calendar.firstWeekday = 2
        return calendar
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.setup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.setup()
    }
    
    fileprivate func setup() {
        self.contentView.backgroundColor = UIColor.groupTableViewBackground
        self.contentView.addSubview(self.calendar)
        
        let constraints: [NSLayoutConstraint] = [
            self.calendar.heightAnchor.constraint(equalToConstant: UIScreen.main.bounds.height / 2),
            self.calendar.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor),
            self.calendar.topAnchor.constraint(equalTo: self.contentView.topAnchor),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.calendar.rightAnchor),
            self.contentView.bottomAnchor.constraint(equalTo: self.calendar.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
