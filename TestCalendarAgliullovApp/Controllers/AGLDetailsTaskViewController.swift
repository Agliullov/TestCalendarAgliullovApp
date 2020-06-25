//
//  AGLDetailsTaskViewController.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 20.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit
import RealmSwift

enum PriorityState: String {
    case low
    case medium
    case high
}

struct SaveData {
    let mainDescriptionString: String?
    let detailsDescriptionString: String?
    let priorityString: String?
    let taskTime: Date?
    
    init(mainDescriptionString: String?, detailsDescriptionString: String?, priorityString: String?, taskTime: Date?) {
        self.mainDescriptionString = mainDescriptionString
        self.detailsDescriptionString = detailsDescriptionString
        self.priorityString = priorityString
        self.taskTime = taskTime
    }
}

fileprivate enum TaskCellType: Int {
    case description
    case priority
    case dateTime
    
    var cellClass: UITableViewCell.Type {
        let cellClass: UITableViewCell.Type
        switch self {
        case .description:
            cellClass = AGLDefaultGridViewBlock.self
        case .priority:
            cellClass = AGLPriorityTableViewCell.self
        case .dateTime:
            cellClass = AGLDatePickerTableCell.self
        }
        return cellClass
    }
}

fileprivate enum TasksSectionType: Int {
    case description
    case priority
    case dateTime
}

fileprivate struct TaskSection {
    let type: TasksSectionType
    
    private var _cellTypes: [TaskCellType] = []
    
    var cellTypes: [TaskCellType] {
        return _cellTypes
    }
    
    var cellCount: Int {
        return self.cellTypes.count
    }
    
    init?(type: TasksSectionType) {
        self.type = type
        
        var cellTypes: [TaskCellType] = []
        
        switch type {
        case .description:
            cellTypes.append(.description)
        case .dateTime:
            cellTypes.append(.dateTime)
        case .priority:
            cellTypes.append(.priority)
        }
        
        self._cellTypes = cellTypes
        
        guard cellTypes.count == 0 else { return }
        
        return nil
    }
    
    var header: String? {
        var header: String? = nil
        switch self.type {
        case .description:
            header = HEADER_DETAILS_TASKS_VIEW_DESCRIPTION
        case .priority:
            header = HEADER_DETAILS_TASKS_VIEW_PRIORITY
        case .dateTime:
            header = HEADER_DETAILS_TASKS_VIEW_DATETIME
        }
        return header
    }
}

class AGLDetailsTaskViewController: UIViewController {
    
    var task: AGLTask?
    
    var calendarSelectedDate: Date = Date()
    
    fileprivate lazy var realm: Realm? = {
        let realm = try? AGLRealmManager.shared.getDefaultRealm()
        return realm
    }()
    
    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = false
        if #available(iOS 13.0, *) {
            tableView.backgroundColor = UIColor.secondarySystemGroupedBackground
        } else {
            tableView.backgroundColor = UIColor.white
        }
        return tableView
    }()
    
    fileprivate var sections: [TaskSection] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(self.tableView)
        
        self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.frame = self.view.bounds
        self.tableView.register(AGLDefaultGridViewBlock.self, forCellReuseIdentifier: String(describing: AGLDefaultGridViewBlock.self))
        self.tableView.register(AGLPriorityTableViewCell.self, forCellReuseIdentifier: String(describing: AGLPriorityTableViewCell.self))
        self.tableView.register(AGLDatePickerTableCell.self, forCellReuseIdentifier: String(describing: AGLDatePickerTableCell.self))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.reloadData()
        
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTask))
        let save = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(saveTask))
        
        self.navigationItem.setRightBarButtonItems([delete, save], animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if self.task == nil {
            self.navigationItem.rightBarButtonItems?.first?.isEnabled = false
        }
    }
    
    fileprivate func reloadData() {
        
        var section: [TaskSection] = []
        
        if let descriptionSection = TaskSection(type: .description) {
            section.append(descriptionSection)
        }
        
        if let prioritySection = TaskSection(type: .priority) {
            section.append(prioritySection)
        }
        
        if let datePickerSection = TaskSection(type: .dateTime) {
            section.append(datePickerSection)
        }
        
        self.sections = section
    }
    
    @objc fileprivate func deleteTask() {
        if let task = self.task {
            try? self.realm?.safeWrite {
                self.realm?.delete(task)
            }
            self.presentActivityViewController()
        }
    }
    
    @objc fileprivate func saveTask() {
        
        //Название и описание
        var mainDescriptionString: String = ""
        var detailsDescriptionString: String = ""
        
        if let descriptionCellIndexPath = self.indexPaths(fotCellType: .description).first {
            if let descriptionCell = self.tableView.cellForRow(at: descriptionCellIndexPath) as? AGLDefaultGridViewBlock {
                mainDescriptionString = descriptionCell.mainTextField.text ?? ""
                detailsDescriptionString = descriptionCell.detailTextView.text ?? ""
            }
        }
        
        guard !mainDescriptionString.isEmpty, mainDescriptionString != "" else {
            //let alertVC = UIAlertController(title: "Task title is empty", message: "To save the task you need to enter its title", preferredStyle: .alert)
            let alertController = UIAlertController(title: "Заголовок задачи пуст", message: "Чтобы сохранить задачу заполните поле 'Заголововок'", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            
            alertController.addAction(okAction)
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        //Приоритет задачи
        var priorityString: String = ""
        if let priorityCellIndexPath = self.indexPaths(fotCellType: .priority).first {
            if let priorityCell = self.tableView.cellForRow(at: priorityCellIndexPath) as? AGLPriorityTableViewCell {
                switch priorityCell.prioritySegmentedControl.selectedSegmentIndex {
                case 0:
                    priorityString = "Low"
                case 1:
                    priorityString = "Medium"
                case 2:
                    priorityString = "High"
                default: ()
                }
            }
        }
        
        //Id
        var id: Int
        
        if let taskId = self.task?.taskId {
            id = taskId
        } else {
            id = (self.realm?.objects(AGLTask.self).count ?? 0) + 1
        }
        
        //Дата задачи
        var taskTime: Date = Date()
        
        if let dateTimeCellIndexPath = self.indexPaths(fotCellType: .dateTime).first {
            if let dateTimeCell = self.tableView.cellForRow(at: dateTimeCellIndexPath) as? AGLDatePickerTableCell {
                taskTime = dateTimeCell.timeIntervalPicker.date
            }
        }
        
        //Дата создания задачи
        var dateCreated: Date
        
        if let taskDate = self.task?.dateCreated {
            dateCreated = taskDate
        } else {
            dateCreated = self.calendarSelectedDate
        }
        
        let json: [String: Any] = [
            "id" : id,
            "mainDescription" : mainDescriptionString,
            "detailsDescription" : detailsDescriptionString,
            "priorityState" : priorityString,
            "date" : taskTime,
            "dateCreated" : dateCreated
        ]
        
        let _ = try? AGLTask.saveItem(json)
        self.presentActivityViewController()
    }
    
    //MARK: - Back to MainVC
    fileprivate func presentActivityViewController() {
        let presentingView = UIView()
        presentingView.frame = self.view.bounds
        presentingView.backgroundColor = UIColor.gray.withAlphaComponent(0.3)
        
        self.view.addSubview(presentingView)
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.tintColor = UIColor.blue.withAlphaComponent(0.9)
        self.navigationItem.rightBarButtonItems = nil
        self.navigationItem.setRightBarButton(UIBarButtonItem(customView: activityIndicator), animated: true)
        activityIndicator.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            activityIndicator.stopAnimating()
            presentingView.removeFromSuperview()
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    fileprivate func indexPaths(fotCellType type: TaskCellType) -> [IndexPath] {
        var indexPaths: [IndexPath] = []
        for (sectionIndex, section) in self.sections.enumerated() {
            for (cellIndex, cellType) in section.cellTypes.enumerated() {
                if cellType == type {
                    let indexPath = IndexPath(row: cellIndex, section: sectionIndex)
                    indexPaths.append(indexPath)
                }
            }
        }
        return indexPaths
    }
}

extension AGLDetailsTaskViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let cellType = section.cellTypes[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellType.cellClass), for: indexPath)
        
        switch cellType {
        case .description:
            let descriptionCell = cell as! AGLDefaultGridViewBlock
            
            let mainTitle: String? = (self.task != nil) ? self.task?.mainDescriptionString : ""
            let detailsText: String? = (self.task != nil) ? self.task?.detailsDescriptionString : ""
            descriptionCell.mainTextField.text = mainTitle
            descriptionCell.detailTextView.text = detailsText
        case .priority:
            let priorityCell = cell as! AGLPriorityTableViewCell
            
            if task?.priorityStateString == PriorityState.low.rawValue {
                priorityCell.prioritySegmentedControl.selectedSegmentIndex = 0
            } else if task?.priorityStateString == PriorityState.medium.rawValue {
                priorityCell.prioritySegmentedControl.selectedSegmentIndex = 1
            } else if task?.priorityStateString == PriorityState.high.rawValue {
                priorityCell.prioritySegmentedControl.selectedSegmentIndex = 2
            }
        case .dateTime:
            let dateTimeCell = cell as! AGLDatePickerTableCell
            
            if let date = task?.taskTime {
                dateTimeCell.timeIntervalPicker.date = date
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        return section.header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = self.sections[section].type
        var headerHeight: CGFloat = UITableView.automaticDimension
        
        switch sectionType {
        case .description, .priority:
            headerHeight = HEIGHT_FOR_SECTION_HEADER_WITH_TEXT
        default:
            headerHeight = HEIGHT_FOR_SECTION_HEADER_WITHOUT_TEXT
        }
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: UITableViewHeaderFooterView.self))
        return headerView
    }
    
    func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        if let descriptionCellIndexPath = self.indexPaths(fotCellType: .description).first {
            if let descriptionCell = self.tableView.cellForRow(at: descriptionCellIndexPath) as? AGLDefaultGridViewBlock {
                descriptionCell.mainTextField.resignFirstResponder()
                descriptionCell.detailTextView.resignFirstResponder()
            }
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let descriptionCellIndexPath = self.indexPaths(fotCellType: .description).first {
            if let descriptionCell = self.tableView.cellForRow(at: descriptionCellIndexPath) as? AGLDefaultGridViewBlock {
                descriptionCell.mainTextField.resignFirstResponder()
                descriptionCell.detailTextView.resignFirstResponder()
            }
        }
    }
}
