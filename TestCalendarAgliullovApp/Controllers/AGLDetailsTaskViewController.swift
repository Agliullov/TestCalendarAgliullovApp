//
//  AGLDetailsTaskViewController.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 20.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit
import RealmSwift
import QBImagePickerController

enum PriorityState: String {
    case low
    case medium
    case high
}

fileprivate enum TaskCellType: Int {
    case description
    case priority
    case dateTime
    case action
    
    var cellClass: UITableViewCell.Type {
        let cellClass: UITableViewCell.Type
        switch self {
        case .description:
            cellClass = AGLDescriptionGridViewCell.self
        case .priority:
            cellClass = AGLPriorityTableViewCell.self
        case .dateTime:
            cellClass = AGLDatePickerTableViewCell.self
        case .action:
            cellClass = AGLImageButtonTableViewCell.self
        }
        return cellClass
    }
}

fileprivate enum TasksSectionType: Int {
    case description
    case priority
    case dateTime
    case action
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
        case .action:
            cellTypes.append(.action)
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
        default: ()
        }
        return header
    }
}

class AGLDetailsTaskViewController: UIViewController {
    
    var task: AGLTask?
    
    var calendarSelectedDate: Date = Date()
    
    fileprivate var imagePath: String?
    
    fileprivate lazy var realm: Realm? = {
        let realm = try? AGLRealmManager.shared.getDefaultRealm()
        return realm
    }()
    
    fileprivate let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.allowsMultipleSelection = false
        tableView.separatorStyle = .none
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
        self.tableView.register(AGLDescriptionGridViewCell.self, forCellReuseIdentifier: String(describing: AGLDescriptionGridViewCell.self))
        self.tableView.register(AGLPriorityTableViewCell.self, forCellReuseIdentifier: String(describing: AGLPriorityTableViewCell.self))
        self.tableView.register(AGLDatePickerTableViewCell.self, forCellReuseIdentifier: String(describing: AGLDatePickerTableViewCell.self))
        self.tableView.register(AGLImageButtonTableViewCell.self, forCellReuseIdentifier: String(describing: AGLImageButtonTableViewCell.self))
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.reloadData()
        
        let delete = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteTask))
        let save = UIBarButtonItem(title: "Сохранить", style: .done, target: self, action: #selector(saveTask))
        
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
        
        if let actionSection = TaskSection(type: .action) {
            section.append(actionSection)
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
    
    @objc fileprivate func openImageTask(image: UIImage?) {
        
        guard let imageTask = image else { return }
        
        let imageTaskVC = AGLPresentImageViewController()
        let imageNavVC = UINavigationController(rootViewController: imageTaskVC)
        
        imageTaskVC.selectedImage = imageTask
        self.present(imageNavVC, animated: true, completion: nil)
    }
    
    @objc fileprivate func saveTask() {
        
        //Название и описание
        var mainDescriptionString: String = ""
        var detailsDescriptionString: String = ""
        
        if let descriptionCellIndexPath = self.indexPaths(fotCellType: .description).first {
            if let descriptionCell = self.tableView.cellForRow(at: descriptionCellIndexPath) as? AGLDescriptionGridViewCell {
                mainDescriptionString = descriptionCell.mainTextField.text ?? ""
                detailsDescriptionString = descriptionCell.detailTextView.text ?? ""
            }
        }
        
        guard !mainDescriptionString.isEmpty, mainDescriptionString != "" else {
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
            if let dateTimeCell = self.tableView.cellForRow(at: dateTimeCellIndexPath) as? AGLDatePickerTableViewCell {
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
        
        var json: [String: Any] = [
            "id" : id,
            "mainDescription" : mainDescriptionString,
            "detailsDescription" : detailsDescriptionString,
            "priorityState" : priorityString,
            "date" : taskTime,
            "dateCreated" : dateCreated
        ]
        
        
        if let imagePath = self.imagePath {
            json["imagePath"] = imagePath
        } else {
            if let taskImagePath = self.task?.imagePath {
                json["imagePath"] = taskImagePath
            }
        }
        
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
    
    fileprivate func openImagePicker() {
        let pickerVC = QBImagePickerController()
        pickerVC.delegate = self
        pickerVC.mediaType = .image
        pickerVC.allowsMultipleSelection = false
        pickerVC.showsNumberOfSelectedAssets = false
        pickerVC.modalPresentationStyle = .pageSheet
        
        self.present(pickerVC, animated: true, completion: nil)
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
        cell.selectionStyle = .none
        switch cellType {
        case .description:
            let descriptionCell = cell as! AGLDescriptionGridViewCell
            
            let mainTitle: String? = (self.task != nil) ? self.task?.mainDescriptionString : ""
            let detailsText: String? = (self.task != nil) ? self.task?.detailsDescriptionString : ""
            descriptionCell.mainTextField.text = mainTitle
            descriptionCell.detailTextView.text = detailsText
        case .priority:
            let priorityCell = cell as! AGLPriorityTableViewCell
            
            if task?.priorityStateString.lowercased() == PriorityState.low.rawValue.lowercased() {
                priorityCell.prioritySegmentedControl.selectedSegmentIndex = 0
            } else if task?.priorityStateString.lowercased() == PriorityState.medium.rawValue.lowercased() {
                priorityCell.prioritySegmentedControl.selectedSegmentIndex = 1
            } else if task?.priorityStateString.lowercased() == PriorityState.high.rawValue.lowercased() {
                priorityCell.prioritySegmentedControl.selectedSegmentIndex = 2
            }
        case .dateTime:
            let dateTimeCell = cell as! AGLDatePickerTableViewCell
            
            if let date = task?.taskTime {
                dateTimeCell.timeIntervalPicker.date = date
            }
        case .action:
            let actionCell = cell as! AGLImageButtonTableViewCell
            
            if let task = task, let imagePath = task.imagePath, !imagePath.isEmpty, let image = UIImage(contentsOfFile: imagePath) {
                actionCell.taskImageView.image = image
            } else {
                actionCell.taskImageView.image = UIImage(named: "photoPlaceholder")
            }
            
            actionCell.buttonActionContainer = { [weak self] in
                self?.openImageTask(image: actionCell.taskImageView.image!)
            }
            
            actionCell.buttonActionBlock = { [weak self] in
                self?.openImagePicker()
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = self.sections[indexPath.section]
        let cellType = section.cellTypes[indexPath.row]
        switch cellType {
        default:
            if let descriptionCellIndexPath = self.indexPaths(fotCellType: .description).first {
                if let descriptionCell = self.tableView.cellForRow(at: descriptionCellIndexPath) as? AGLDescriptionGridViewCell {
                    descriptionCell.mainTextField.resignFirstResponder()
                    descriptionCell.detailTextView.resignFirstResponder()
                }
            }
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension AGLDetailsTaskViewController: QBImagePickerControllerDelegate {
    func qb_imagePickerController(_ imagePickerController: QBImagePickerController!, didFinishPickingAssets assets: [Any]!) {
        
        for case let asset as PHAsset in assets {
            if asset.mediaType == .image {
                PHImageManager.default().requestImageData(for: asset, options: nil) { (data, name, orientation, info) in
                    if let data = data {
                        let fileName = (info?["PHImageFileURLKey"] as? URL)?.lastPathComponent ?? "file.jpeg"
                        let cachedUrlPath = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/\(NSUUID().uuidString)"
                        try? FileManager.default.createDirectory(atPath: cachedUrlPath, withIntermediateDirectories: true, attributes: nil)
                        let fullPath = cachedUrlPath + "\(fileName)"
                        FileManager.default.createFile(atPath: fullPath, contents: data, attributes: nil)
                        
                        if let image = UIImage(data: data) {
                            if let defaultButtonTableCellIndexPath = self.indexPaths(fotCellType: .action).first {
                                if let defaultButtonTableCell = self.tableView.cellForRow(at: defaultButtonTableCellIndexPath) as? AGLImageButtonTableViewCell {
                                    DispatchQueue.main.async {
                                        defaultButtonTableCell.taskImageView.image = image
                                    }
                                }
                            }
                        }
                        self.imagePath = fullPath
                    }
                }
            }
        }
        imagePickerController.dismiss(animated: true, completion: nil)
    }
    
    func qb_imagePickerControllerDidCancel(_ imagePickerController: QBImagePickerController!) {
        imagePickerController.dismiss(animated: true, completion: nil)
    }
}
