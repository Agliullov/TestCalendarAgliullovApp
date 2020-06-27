//
//  AGLPriorityTableViewCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLPriorityTableViewCell: AGLDefaultGridCell {
        
    var prioritySegmentedControl: UISegmentedControl = {
        let actions: [String] = ["Low", "Medium", "High"]
        let segment = UISegmentedControl(items: actions)
        segment.translatesAutoresizingMaskIntoConstraints = false
        segment.selectedSegmentIndex = 0
        return segment
    }()
    
    override func initialSetup() {
        self.contentView.addSubview(self.prioritySegmentedControl)
        
        let constraints: [NSLayoutConstraint] = [
            self.prioritySegmentedControl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            self.prioritySegmentedControl.centerYAnchor.constraint(equalTo: self.contentView.centerYAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
    }
}
