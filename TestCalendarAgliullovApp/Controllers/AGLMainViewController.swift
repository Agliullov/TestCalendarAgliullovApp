//
//  AGLViewController.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 17.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit
import FSCalendar
import RealmSwift

fileprivate enum CalendarCellType: Int {
    case calendarCell
    case taskCell
    
    var cellClass: UITableViewCell.Type {
        let cellClass: UITableViewCell.Type
        switch self {
        case .calendarCell:
            cellClass = AGLCalendarTableViewCell.self
        case .taskCell:
            cellClass = AGLTaskTableViewCell.self
        }
        return cellClass
    }
    
    var accessoryType: UITableViewCell.AccessoryType {
        var accessoryType: UITableViewCell.AccessoryType
        switch self {
        case .calendarCell:
            accessoryType = UITableViewCell.AccessoryType.none
        case .taskCell:
            accessoryType = UITableViewCell.AccessoryType.disclosureIndicator
        }
        return accessoryType
    }
}

fileprivate enum CalendarSectionType: Int {
    case calendarSection
    case taskSection
}

fileprivate struct CalendarSection {
    let sectionType: CalendarSectionType
    private var _cellTypes: [CalendarCellType] = []
    
    var cellTypes: [CalendarCellType] {
        return _cellTypes
    }
    
    var cellCount: Int {
        return self.cellTypes.count
    }
    
    init?(type: CalendarSectionType, count: Int) {
        self.sectionType = type
        
        var cellTypes: [CalendarCellType] = []
        
        switch type {
        case .calendarSection:
            cellTypes.append(.calendarCell)
        case.taskSection:
            cellTypes.append(contentsOf: [CalendarCellType](repeatElement(.taskCell, count: count)))
        }
        
        self._cellTypes = cellTypes
        
        guard cellTypes.count == 0 else { return }
        
        return nil
    }
    
    var headerSection: String? {
        var header: String? = nil
        
        switch self.sectionType {
        case .taskSection:
            header = HEADER_MAIN_TASKS_VIEW
        default:()
        }
        return header
    }
}


class AGLMainViewController: UIViewController {
    
    fileprivate var tasks: Results<AGLTask>?
    fileprivate var filteredTasks: [AGLTask]?
    
    //Получаем реалм
    fileprivate lazy var realm: Realm? = {
        let realm =  try? AGLRealmManager.shared.getDefaultRealm()
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
    
    fileprivate var sections: [CalendarSection] = []
    
    fileprivate var notificationToken: NotificationToken?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = MAIN_VIEW_CONTROLLER_TITLE
        
        self.view.addSubview(self.tableView)
        self.tableView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        self.tableView.frame = self.view.bounds
        self.tableView.register(AGLCalendarTableViewCell.self, forCellReuseIdentifier: String(describing: AGLCalendarTableViewCell.self))
        self.tableView.register(AGLTaskTableViewCell.self, forCellReuseIdentifier: String(describing: AGLTaskTableViewCell.self))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.navigationItem.setRightBarButton(UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(createNewTask)), animated: true)
        
        self.tasks = self.realm?.objects(AGLTask.self)
        self.reloadData()
        self.registerNotificationToken()
    }
    
    //MARK: - Data change notification
    fileprivate func registerNotificationToken() {
        self.notificationToken = self.realm?.observe({ (notification, realm) in
            switch notification {
            case .didChange:
                var calendarSelectedDate: Date?
                
                if let calendareCellIndexPath = self.indexPaths(fotCellType: .calendarCell).first {
                    if let calendareCell = self.tableView.cellForRow(at: calendareCellIndexPath) as? AGLCalendarTableViewCell {
                        if let selectedDate = calendareCell.calendar.selectedDate {
                            calendarSelectedDate = selectedDate
                        }
                    }
                }
                self.reloadData(date: calendarSelectedDate)
            default: ()
            }
        })
    }
    
    fileprivate func reloadData(date: Date? = nil) {
        var section: [CalendarSection] = []
        
        if let calendarSection = CalendarSection(type: .calendarSection, count: 1) {
            section.append(calendarSection)
        }
        
        var calendar = Calendar.current
        if let timeZone = TimeZone(identifier: "UTC") {
            calendar.timeZone = timeZone
        }
        
        var todayStart: Date!
        if let date = date {
            todayStart = calendar.startOfDay(for: date)
        } else {
            todayStart = calendar.startOfDay(for: Date())
        }
        let todayEnd: Date = {
            let components = DateComponents(day: 1, second: -1)
            return calendar.date(byAdding: components, to: todayStart) ?? todayStart
        }()
        
        let timePredicate: NSPredicate = NSPredicate(format: "dateCreated BETWEEN %@", [todayStart, todayEnd])
        if let tasks = self.tasks?.filter(timePredicate) {
            self.filteredTasks = Array(tasks)
        }
        
        if let taskSection = CalendarSection(type: .taskSection, count: self.filteredTasks?.count ?? 0) {
            section.append(taskSection)
        }
        
        self.sections = section
        self.tableView.reloadData()
    }
    
    @objc fileprivate func openDetailsTask(task: AGLTask?) {
        guard let taskDetails = task else { return }
        
        let detailsTaskVC = AGLDetailsTaskViewController()
        detailsTaskVC.task = taskDetails
        self.navigationController?.pushViewController(detailsTaskVC, animated: true)
    }
    
    @objc fileprivate func createNewTask() {
        if let calendareCellIndexPath = self.indexPaths(fotCellType: .calendarCell).first {
            if let calendareCell = self.tableView.cellForRow(at: calendareCellIndexPath) as? AGLCalendarTableViewCell,
                let selectedDate = calendareCell.calendar.selectedDate {
                let detailsTaskVC = AGLDetailsTaskViewController()
                detailsTaskVC.calendarSelectedDate = selectedDate
                self.navigationController?.pushViewController(detailsTaskVC, animated: true)
            }
            else {
                let alertController = UIAlertController(title: "Выберите день", message: "Укажите день для создания задачи", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    fileprivate func indexPaths(fotCellType type: CalendarCellType) -> [IndexPath] {
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

extension AGLMainViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.sections[section].cellCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = self.sections[indexPath.section]
        let cellType = section.cellTypes[indexPath.row]
        
        var cell = tableView.dequeueReusableCell(withIdentifier: String(describing: cellType.cellClass), for: indexPath)
        
        switch cellType {
        case .calendarCell:
            let calendarCell = cell as! AGLCalendarTableViewCell
            calendarCell.selectionStyle = .none
            calendarCell.calendar.delegate = self
            cell = calendarCell
        case .taskCell:
            let taskCell = cell as! AGLTaskTableViewCell
            taskCell.selectionStyle = .default
            if let task = self.filteredTasks?[indexPath.row] {
                taskCell.setupWithTask(task: task)
            }
            cell = taskCell
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        let cellType = section.cellTypes[indexPath.row]
        switch cellType {
        case .taskCell:
            if let task = self.filteredTasks?[indexPath.row] {
                self.openDetailsTask(task: task)
            }
        default:()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let section = self.sections[section]
        var titleSection: String? = ""
        switch section.sectionType {
        case .taskSection:
            titleSection = section.headerSection
        default:()
        }
        return titleSection
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let sectionType = self.sections[section].sectionType
        
        var headerHeight: CGFloat = UITableView.automaticDimension
        
        switch sectionType {
        case .calendarSection:
            headerHeight = HEIGHT_HEADER_CALENDAR
        case .taskSection:
            headerHeight = HEIGHT_HEADER_TASKS
        }
        return headerHeight
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let sectionType = self.sections[section].sectionType
        
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: String(describing: UITableViewHeaderFooterView.self))
        
        switch sectionType {
        case .calendarSection:
            return nil
        case .taskSection:
            return headerView
        }
    }
}

extension AGLMainViewController: FSCalendarDelegate {
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        self.reloadData(date: date)
    }
}
