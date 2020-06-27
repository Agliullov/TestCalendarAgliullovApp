//
//  AGLTaskTableViewCell.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 18.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

class AGLTaskTableViewCell: UITableViewCell {
    
    //Название задачи
    internal let mainLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black
        label.font = UIFont.boldSystemFont(ofSize: 17.0)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    //Описание задачи
    internal let detailLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    //Время задачи
    internal let timeIntervalLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.font = UIFont.boldSystemFont(ofSize: 14.0)
        label.textAlignment = .left
        label.backgroundColor = .clear
        label.numberOfLines = 0
        return label
    }()
    
    //Приоритет задачи
    internal let priorityView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //Иконка часов
    internal let clockImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = .clear
        imageView.image = UIImage(named: "clockImage")
        return imageView
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
        self.contentView.addSubview(self.priorityView)
        self.contentView.addSubview(self.mainLabel)
        self.contentView.addSubview(self.detailLabel)
        self.contentView.addSubview(self.timeIntervalLabel)
        self.contentView.addSubview(self.clockImageView)
        
        let constraints: [NSLayoutConstraint] = [
            
            //priorityView
            self.priorityView.heightAnchor.constraint(equalToConstant: PRIORITY_VIEW_HEIGHT),
            self.priorityView.widthAnchor.constraint(equalToConstant: PRIORITY_VIEW_HEIGHT),
            self.priorityView.leftAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.leftAnchor),
            self.priorityView.centerYAnchor.constraint(equalTo: self.mainLabel.firstBaselineAnchor),
            
            //mainLabel
            self.mainLabel.topAnchor.constraint(equalTo: self.contentView.layoutMarginsGuide.topAnchor),
            self.mainLabel.leftAnchor.constraint(equalTo: self.priorityView.rightAnchor, constant: 8.0),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.mainLabel.rightAnchor),
            
            //detailLabel
            self.detailLabel.leftAnchor.constraint(equalTo: self.mainLabel.leftAnchor),
            self.detailLabel.topAnchor.constraint(equalTo: self.mainLabel.bottomAnchor, constant: 8.0),
            self.contentView.layoutMarginsGuide.rightAnchor.constraint(equalTo: self.detailLabel.rightAnchor),
            
            //clockImageView
            self.clockImageView.heightAnchor.constraint(equalToConstant: 15.0),
            self.clockImageView.widthAnchor.constraint(equalToConstant: 15.0),
            self.clockImageView.leftAnchor.constraint(equalTo: self.detailLabel.leftAnchor),
            self.clockImageView.centerYAnchor.constraint(equalTo: self.timeIntervalLabel.centerYAnchor),
            
            //timeIntervalLabel
            self.timeIntervalLabel.topAnchor.constraint(equalTo: self.detailLabel.bottomAnchor, constant: 8.0),
            self.timeIntervalLabel.leftAnchor.constraint(equalTo: self.clockImageView.rightAnchor, constant: 6.0),
            self.timeIntervalLabel.widthAnchor.constraint(equalToConstant: self.contentView.frame.width / 2),
            self.contentView.layoutMarginsGuide.bottomAnchor.constraint(equalTo: self.timeIntervalLabel.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.priorityView.clipsToBounds = true
        self.priorityView.layer.cornerRadius = PRIORITY_VIEW_HEIGHT / 2
    }
    
    func UTCToLocal(date: String) -> String {
        let dateFormatter = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
        dateFormatter.timeZone = .current
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let convertedDate = dateFormatter.date(from: date)
        guard dateFormatter.date(from: date) != nil else { return "" }
        
        dateFormatter.dateFormat = "HH:mm"
        let timeStamp = dateFormatter.string(from: convertedDate!)
        return timeStamp
    }
    
    func setupWithTask(task: AGLTask) {
        
        self.mainLabel.text = task.mainDescriptionString
        self.detailLabel.text = task.detailsDescriptionString
        
        var colorPriority: UIColor = UIColor.gray
        if task.priorityStateString.lowercased() == PriorityState.low.rawValue.lowercased() {
            colorPriority = UIColor.green
        } else if task.priorityStateString.lowercased() == PriorityState.medium.rawValue.lowercased() {
            colorPriority = UIColor.orange
        } else if task.priorityStateString.lowercased() == PriorityState.high.rawValue.lowercased() {
            colorPriority = UIColor.red
        }
        self.priorityView.backgroundColor = colorPriority
        
        self.timeIntervalLabel.text = self.UTCToLocal(date: task.taskTime.description)
    }
}
