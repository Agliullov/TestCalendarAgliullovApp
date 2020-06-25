//
//  AGLDefaultGridCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLDefaultGridCell: UITableViewCell {
    
    var additionalOffset: CGFloat = 0 {
        didSet {
            guard self.additionalOffset != oldValue else { return }
            self.setNeedsLayout()
        }
    }
    
    internal var separatorIsHidden: Bool = false {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    override var separatorInset: UIEdgeInsets {
        didSet {
            guard self.separatorInset != oldValue else { return }
            self.setNeedsLayout()
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.initialSetup()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.initialSetup()
    }
    
    internal func initialSetup() {
        
    }
    
    //MARL: - Separator refactor
    override func layoutSubviews() {
        super.layoutSubviews()
        
        for view in self.subviews where view.frame.height <= 1.0 && view != self.contentView && view != self.selectedBackgroundView && view != self.backgroundView {
            if view.frame.origin.y < CGFloat.ulpOfOne {
                
                if self.additionalOffset > CGFloat.ulpOfOne {
                    var frame: CGRect = view.frame
                    var originX: CGFloat = self.separatorInset.left
                    if originX < self.layoutMargins.left {
                        originX += self.additionalOffset
                    }
                    frame.origin.x = originX
                    frame.size.width = self.frame.width - originX - self.additionalOffset - self.separatorInset.right
                    view.frame = frame
                }
            }
        }
    }
}
