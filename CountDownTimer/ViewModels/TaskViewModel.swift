//
//  TaskViewModel.swift
//  CountDownTimer
//
//  Created by Nitin Bhatia on 24/09/22.
//

import UIKit

struct Constants {
    static var hasTopNotch: Bool {
        let bottom = UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0
        return bottom > 0
    }
}

class Box<T> {
    typealias Listener = (T) -> ()
    
    var value : T {
        didSet {
            listener?(value)
        }
    }
    
    var listener: Listener?
    
    init(value: T) {
        self.value = value
    }
    
    func bind(listener:Listener?) {
        self.listener = listener
    }
    
    func removeBind() {
        listener = nil
    }
}

class TaskTypeViewModel {
    
    //variables
    private var task: Task!
    
    private let taskTypes : [TaskType] = [
            TaskType(symboName: "star", typeName: "Priority"),
            TaskType(symboName: "iphone", typeName: "Develop"),
            TaskType(symboName: "gamecontroller", typeName: "Gaming"),
            TaskType(symboName: "star", typeName: "Priority"),
            TaskType(symboName: "wand.and.stars.inverse", typeName: "Editing")
    ]
    
    private var selectedIndex = -1 {
        didSet {
            self.task.taskType = getTaskTypes()[selectedIndex]
        }
    }
    
    let hours = Box(value: 0)
    let minutes = Box(value: 0)
    let seconds = Box(value: 0)
    
    init() {
        task = Task(taskName: "", taskDesc: "", seconds: 0, taskType: .init(symboName: "", typeName: ""), timeStamp: 0)
    }
    
    func setSelectedIndex(to value:Int) {
        selectedIndex = value
    }
    
    func setTaskName(to value: String) {
        task.taskName = value
    }
    
    func setTaskDescription(to value:String) {
        task.taskDesc = value
    }
    
    func getSelectedIndex() -> Int {
        selectedIndex
    }
    
    func getTask() -> Task {
        task
    }
    
    func getTaskTypes() -> [TaskType] {
        taskTypes
    }
    
    func setHours(to value : Int) {
        hours.value = value
    }
    
    func setMinutes(to value : Int) {
        
        var newMinutes = value
        
        if value >= 60 {
            setHours(to: hours.value + 1)
            newMinutes -= 60
        }
        
       
        minutes.value = newMinutes
    }
    
    func setSeconds(to value : Int) {
        
        var newSeconds = value
        
        if value >= 60 {
            setMinutes(to: minutes.value + 1)
            newSeconds -= 60
        }
        
        if minutes.value >= 60 {
            minutes.value -= 60
            setHours(to: hours.value + 1)
        }
        
        seconds.value = newSeconds
    }
    
    func getHours() -> Box<Int> {
        hours
    }
    
    func getMinutes() -> Box<Int> {
        minutes
    }
    
    func getSeconds() -> Box<Int> {
        seconds
    }
    
    func computeSeconds() {
        task.seconds = (hours.value * 3600) + (minutes.value * 60) + seconds.value
        task.timeStamp = Date().timeIntervalSince1970
    }
    
    func isTaskValid() -> Bool {
        if (!task.taskName.isEmpty && !task.taskDesc.isEmpty && selectedIndex != -1 && (seconds.value > 0 || minutes.value > 0 || hours.value > 0)) {
            return true
        }
       return false
    }
}
