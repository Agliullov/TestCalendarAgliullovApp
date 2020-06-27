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
internal let HEIGHT_FOR_SECTION_HEADER_WITH_TEXT: CGFloat = 55.0
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
    static public func dataBaseNotConfiguratedError() -> NSError {
        return NSError(domain: "Rain.TestCalendarAgliullovApp.DataErrorDomain", code: 555, userInfo: nil)
    }
    
    static public func incorrectDataToSaveDB() -> NSError {
        return NSError(domain: "Rain.TestCalendarAgliullovApp.incorrectDataToSaveDB", code: 666, userInfo: nil)
    }
}

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

    //MARK: - Separator refactor
//    override func layoutSubviews() {
//        super.layoutSubviews()
//
//        for view in self.subviews where view.frame.height <= 1.0 && view != self.contentView && view != self.selectedBackgroundView && view != self.backgroundView {
//            if view.frame.origin.y < CGFloat.ulpOfOne {
//
//                if self.additionalOffset > CGFloat.ulpOfOne {
//                    var frame: CGRect = view.frame
//                    var originX: CGFloat = self.separatorInset.left
//                    if originX < self.layoutMargins.left {
//                        originX += self.additionalOffset
//                    }
//                    frame.origin.x = originX
//                    frame.size.width = self.frame.width - originX - self.additionalOffset - self.separatorInset.right
//                    view.frame = frame
//                }
//            }
//        }
//    }

//MARK: - Сравнение объектов
/*
fileprivate func < <T : Comparable>(lhs: [T], rhs: [T]) -> Bool {
    if lhs.count == 0, rhs.count > 0 { return true }
    if rhs.count == 0 { return false }
    
    var i = 0
    while lhs[i] == rhs[i], i < lhs.count-1, i < rhs.count-1 {
        i += 1
    }
    
    let lastLhsItem = lhs[i]
    let lastRhsItem = rhs[i]
    
    if lastLhsItem == lastRhsItem {
        return lhs.count < rhs.count
    }
    return lastLhsItem < lastRhsItem
}
*/
