//
//  Task.swift
//  CountDownTimer
//
//  Created by Nitin Bhatia on 24/09/22.
//

import Foundation

struct TaskType {
    let symboName : String
    let typeName : String
}

struct Task {
    var taskName : String
    var taskDesc : String
    var seconds : Int
    var taskType : TaskType
    
    var timeStamp : Double //to store task creation date into timeStamp
}

enum CountDownState {
    case suspended
    case running
    case paused
}
