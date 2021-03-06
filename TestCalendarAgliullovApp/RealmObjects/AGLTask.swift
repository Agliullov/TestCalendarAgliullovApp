//
//  AGLTask.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import RealmSwift

//MARK: - JSON properties
internal class AGLTask: Object {
    
    //id
    dynamic var id = RealmOptional<Int64>()
    
    //Описание задачи
    @objc dynamic var mainDescription: String?
    @objc dynamic var detailsDescription: String?
    
    //Приоритет
    @objc dynamic var priorityState: String?
    
    //Дата задачи
    @objc dynamic var date: Date?
    
    //Время создания задачи
    @objc dynamic var dateCreated: Date?
    
    //Изображение
    @objc dynamic var imagePath: String?
    
    //Первичный ключ
    override class func primaryKey() -> String? {
        return "id"
    }
}

extension AGLTask {
    
    internal var taskId: Int {
        return Int(self.id.value ?? 0)
    }
    
    internal var mainDescriptionString: String {
        return self.mainDescription ?? ""
    }
    
    internal var detailsDescriptionString: String {
        return self.detailsDescription ?? ""
    }
    
    internal var priorityStateString: String {
        return self.priorityState ?? ""
    }
    
    internal var taskTime: Date {
        return self.date ?? Date()
    }
    
    internal var taskCreatedTime: Date {
        return self.dateCreated ?? Date()
    }
    
    //MARK: - Save JSON
    @discardableResult
    static func saveItem(_ json: [String: Any], realm aRealm: Realm? = nil) throws -> AGLTask {
        guard let taskId = json["id"] as? Int else { throw NSError.incorrectDataToSaveDB() }
        
        let realm: Realm
        if let aRealm = aRealm {
            realm = aRealm
        } else {
            realm = try AGLRealmManager.shared.getDefaultRealm()
        }
        
        var task: AGLTask!
        
        try realm.safeWrite {
            task = realm.create(AGLTask.self, value: ["id" : taskId], update: .modified)
            
            task.mainDescription = json["mainDescription"] as? String
            task.detailsDescription = json["detailsDescription"] as? String
            task.priorityState = json["priorityState"] as? String
            task.date = json["date"] as? Date
            task.dateCreated = json["dateCreated"] as? Date
            task.imagePath = json["imagePath"] as? String
        }
        return task
    }
}
