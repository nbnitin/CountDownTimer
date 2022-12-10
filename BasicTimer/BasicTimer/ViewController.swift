//
//  ViewController.swift
//  BasicTimer
//
//  Created by Nitin Bhatia on 06/12/22.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var btnPauseTimer: UIButton!
    @IBOutlet weak var btnStartTimer: UIButton!
    @IBOutlet weak var lblTimer: UILabel!
    
    var countdownTimer : Timer?
    var totalTime = 60
    var startTime : Date!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        btnStartTimer.setTitle("Start Timer", for: .normal)
        btnStartTimer.setTitle("Stop Timer", for: .selected)
        btnPauseTimer.setTitle("Pause Timer", for: .normal)
        btnPauseTimer.setTitle("Resume Timer", for: .selected)
        startTime = Calendar.current.date(byAdding: .day, value: 2, to: Date())
        createSeconds(startTime)
        btnPauseTimer.isHidden = true
        NotificationCenter.default.addObserver(self, selector: #selector(restartTimer), name: UIApplication.willEnterForegroundNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(restartTimer), name: UIApplication.willResignActiveNotification, object: nil)
        // Do any additional setup after loading the view.
    }
    
    @objc func restartTimer() {
        endTimer()
        createSeconds(startTime)
        if btnStartTimer.isSelected {
            startTimer()
        }
    }
    
    @IBAction func btnPauseTimerAction(_ sender: Any) {
        btnPauseTimer.isSelected.toggle()
        endTimer(false)
        
        if !btnPauseTimer.isSelected {
            startTimer()
            btnStartTimer.isHidden = false
        } else {
            btnStartTimer.isHidden = true
        }
    }
    
    
    @IBAction func btnStartTimerAction(_ sender: Any) {
        
        if btnStartTimer.isSelected {
            endTimer()
            lblTimer.text = "\(timeFormatted(0))"
            btnStartTimer.isSelected.toggle()
            return
        }
        btnPauseTimer.isHidden = false
        startTimer()
        btnStartTimer.isSelected.toggle()
    }
    
    @objc func startTimer() {
        countdownTimer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
    }
    
    @objc func updateTime() {
        lblTimer.text = "\(timeFormatted(totalTime))"
        
        if totalTime != 0 {
            totalTime -= 1
        } else {
            endTimer()
        }
    }
    
    func endTimer(_ doHidePauseButton : Bool = true) {
        countdownTimer?.invalidate()
        countdownTimer = nil
        btnPauseTimer.isHidden = doHidePauseButton
    }
    
    func timeFormatted(_ totalSeconds: Int) -> String {
        let seconds: Int = totalSeconds % 60
        let minutes: Int = (totalSeconds / 60) % 60
        let hours: Int = totalSeconds / 3600
        return String(format: "%02dh : %02dm : %02ds", hours, minutes, seconds)
    }
    
    func createSeconds(_ date:Date) {
        totalTime = Calendar.current.dateComponents([.second], from: Date(), to: date).second ?? 0
    }
}

