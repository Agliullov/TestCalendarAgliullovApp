//
//  AGLHelpers.swift
//  TestCalendarAgliullovApp
//
//  Created by Ильдар Аглиуллов on 21.06.2020.
//  Copyright © 2020 Ильдар Аглиуллов. All rights reserved.
//

import UIKit

internal let PRIORITY_VIEW_HEIGHT: CGFloat = 15.0
internal let HEIGHT_FOR_SECTION_HEADER_WITHOUT_TEXT: CGFloat = 32.0
internal let HEIGHT_FOR_SECTION_HEADER_WITH_TEXT: CGFloat = 30.0
internal let DEFAULT_BUTTON_HEIGHT: CGFloat = 50.0

internal let HEIGHT_HEADER_CALENDAR: CGFloat = 0.0
internal let HEIGHT_HEADER_TASKS: CGFloat = 38.0

internal let MAIN_VIEW_CONTROLLER_TITLE: String = "Дела на сегодня"
internal let HEADER_MAIN_TASKS_VIEW: String = "Задачи на сегодня"
internal let HEADER_DETAILS_TASKS_VIEW_DESCRIPTION: String = "Описание задачи"
internal let HEADER_DETAILS_TASKS_VIEW_PRIORITY: String = "Приоритет задачи"
internal let HEADER_DETAILS_TASKS_VIEW_DATETIME: String = "Время события"


//MARK: - Throws description
extension NSError {
    static func dataBaseNotConfiguratedError() -> NSError {
        return NSError(domain: "Rain.TestCalendarAgliullovApp.DataErrorDomain", code: 555, userInfo: nil)
    }
    
    static func incorrectDataToSaveDB() -> NSError {
        return NSError(domain: "Rain.TestCalendarAgliullovApp.incorrectDataToSaveDB", code: 666, userInfo: nil)
    }
}


////MARK: - Date
//private let dateFormatter: DateFormatter = {
//    let formatter = DateFormatter()
//    formatter.calendar = Calendar(identifier: .gregorian)
//    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss ZZZ"
//    formatter.locale = Locale(identifier: "en_US_POSIX")
//    formatter.timeZone = .current
//    return formatter
//}()
//


extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
