//
//  TimerViewController.swift
//  CountDownTimer
//
//  Created by Nitin Bhatia on 24/09/22.
//

import UIKit

class TimerViewController: UIViewController {
    
    //outlets
    @IBOutlet weak var imgTask: UIImageView!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var lblTime: UILabel!
    @IBOutlet weak var btnRefresh: UIButton!
    @IBOutlet weak var btnPause: UIButton!
    @IBOutlet weak var btnPlay: UIButton!
    @IBOutlet weak var refreshView: UIView!
    @IBOutlet weak var pauseView: UIView!
    @IBOutlet weak var playView: UIView!
    @IBOutlet weak var timerView: UIView!
    @IBOutlet weak var imgTaskContainerView: UIView!
    @IBOutlet weak var timerCircleContainer: UIView!
    @IBOutlet weak var lblTaskDesc: UILabel!
    
    //varaibles
    var task : Task!
    let timeAttributes = [NSAttributedString.Key.font:UIFont(name: "Arial", size: 46), .foregroundColor: UIColor.black]
//    let boldArialFont = UIFont(name: "Arial", size: 36)?.fontDescriptor.fontDescriptorWithSymbolicTraits(UIFontDescriptor.SymbolicTraits.traitBold)

    let semiBoldAttributes = [NSAttributedString.Key.font:UIFont(name: "Arial-BoldMT", size: 32), .foregroundColor: UIColor.black]
    
    var totalSeconds = 0 {
        didSet {
            timerSeconds = totalSeconds
        }
    }
    
    var timerSeconds : Int = 0
    var timerTrackLayer = CAShapeLayer()
    var timerCircleFillLayer = CAShapeLayer()
    var timerState : CountDownState = .suspended
    var countDownTimer : Timer? = Timer()
    
    lazy var timerEndAnimation: CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.fromValue = 1
        strokeEnd.toValue = 0
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = true
        return strokeEnd
    }()
    
    lazy var timerResetAnimation : CABasicAnimation = {
        let strokeEnd = CABasicAnimation(keyPath: "strokeEnd")
        strokeEnd.toValue = 1
        strokeEnd.duration = 1
        strokeEnd.fillMode = .forwards
        strokeEnd.isRemovedOnCompletion = false
        return strokeEnd
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //task = Task(taskName: "dd", taskDesc: "dd", seconds: 60, taskType: .init(symboName: "iphone", typeName: "Develop"), timeStamp: Date().timeIntervalSince1970)
        
        totalSeconds = task.seconds
        lblTaskName.text = task.taskName
        lblTaskDesc.text = task.taskDesc
        
        imgTaskContainerView.layer.cornerRadius = imgTaskContainerView.frame.width / 2
        imgTask.layer.cornerRadius = imgTask.frame.width / 2
        imgTask.image = UIImage(systemName: task.taskType.symboName)
        
        [pauseView,refreshView].forEach({
            $0?.layer.opacity = 0
            $0?.isUserInteractionEnabled = false
        })
        
        [playView,pauseView,refreshView].forEach({
            $0?.layer.cornerRadius = 17
        })
        
        timerCircleContainer.transform = timerCircleContainer.transform.rotated(by: 270.degreeToRadians())
        lblTime.transform = lblTime.transform.rotated(by: 90.degreeToRadians())
        timerView.transform = timerView.transform.rotated(by: 90.degreeToRadians())
        
        updateLabel()
        addCircle()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        DispatchQueue.main.async {
            self.setupLayer()
        }
    }
    
    //MARK: setting up the layer
    private func setupLayer() {
        let minValue = min(timerCircleContainer.frame.width,timerCircleContainer.frame.height)
        let radius = minValue / 2
        
        let arcPath = UIBezierPath(arcCenter: CGPoint(x: timerCircleContainer.frame.height / 2, y: timerCircleContainer.frame.width / 2), radius: radius, startAngle: 0, endAngle: 360.degreeToRadians(), clockwise: true)
        
        timerTrackLayer.path = arcPath.cgPath
        timerTrackLayer.strokeColor = UIColor(hex: "f2A041").cgColor
        timerTrackLayer.lineWidth = 20
        timerTrackLayer.fillColor = UIColor.clear.cgColor
        timerTrackLayer.lineCap = .round
        
        timerCircleFillLayer.path = arcPath.cgPath
        timerCircleFillLayer.strokeColor = UIColor.black.cgColor
        timerCircleFillLayer.lineWidth = 21
        timerCircleFillLayer.fillColor = UIColor.clear.cgColor
        timerCircleFillLayer.lineCap = .round
        timerCircleFillLayer.strokeEnd = 1
        
        timerCircleContainer.layer.addSublayer(timerTrackLayer)
        timerCircleContainer.layer.addSublayer(timerCircleFillLayer)
        
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.timerView.layer.cornerRadius = self.timerView.frame.width / 2
        })
    }
    
    class override func description() -> String {
        return "TimerViewController"
    }
    
    //MARK: btn reset action
    @IBAction func btnResetAction(_ sender: Any) {
        timerState = .suspended
        resetTimer()
        timerSeconds = task.seconds
        
        timerCircleFillLayer.add(timerResetAnimation, forKey: "reset")
        animatePauseButton(symbol: "play.fill")
        animatePlayPauseResetViews(timerPlaying: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.playView.isUserInteractionEnabled = true

        })
    }
    
    //MARK: btn play action
    @IBAction func btnPlayAction(_ sender: Any) {
        guard timerState == .suspended else {
            return
        }

        if timerState != .paused {
            timerEndAnimation.duration = Double(timerSeconds)
        }
        animatePauseButton(symbol: "pause.fill")
        animatePlayPauseResetViews(timerPlaying: false)
        startTimer()
    }
    
    //MARK: btn pause action
    @IBAction func btnPauseAction(_ sender: Any) {
        switch timerState {
        case .running:
            timerState = .paused
            resetTimer()
            animatePauseButton(symbol: "play.fill")
            
            UIView.animate(withDuration: 1.0, animations: {
                self.timerCircleFillLayer.strokeEnd = CGFloat(self.timerSeconds) / CGFloat(self.totalSeconds)
            })
            

        case.paused:
            timerState = .running
            timerEndAnimation.duration = Double(timerSeconds) + 1
            startTimer()
            animatePauseButton(symbol: "pause.fill")
        default:
            break
        }
    }
    
    //MARK: btn close action
    @IBAction func btnCloseAction(_ sender: Any) {
        timerTrackLayer.removeFromSuperlayer()
        timerCircleFillLayer.removeFromSuperlayer()
        
        countDownTimer?.invalidate()
        
        dismiss(animated: true)
    }
    
    //MARK: animate pause button
    func animatePauseButton(symbol:String) {
        UIView.transition(with: btnPause, duration: 0.3, options: .transitionCrossDissolve) {
            self.btnPause.setImage(UIImage(systemName: symbol,withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold,scale: .default)), for: .normal)
        }
    }
    
    //MARK: animate play pause reset views
    func animatePlayPauseResetViews(timerPlaying:Bool) {
        UIView.animate(withDuration: 0.3, delay: 0, animations: {
            self.playView.layer.opacity = timerPlaying ? 1 : 0
            self.pauseView.layer.opacity = timerPlaying ? 0 : 1
            self.refreshView.layer.opacity = timerPlaying ? 0 : 1
        },completion: {[weak self] _ in
            [self?.refreshView,self?.pauseView,self?.playView].forEach({
                guard let view = $0 else {
                    return
                }
                
                view.isUserInteractionEnabled = timerPlaying ? false : true
            })
            
        })
    }
    
    //MARK: starts the count down timer
    private func startTimer() {
        updateLabel()
        countDownTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true,block: {timer in
            self.timerSeconds -= 1
            self.updateLabel()
            
            if self.timerSeconds == 0 {
                self.countDownTimer?.invalidate()
                self.timerState = .suspended
                self.animatePlayPauseResetViews(timerPlaying: true)
                self.timerSeconds = self.totalSeconds
                self.resetTimer()
                self.timerEndAnimation.fromValue = 1
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
                    self.playView.isUserInteractionEnabled = true

                })
            }
        })
        
        if timerState == .running {
            timerEndAnimation.fromValue = timerCircleFillLayer.strokeEnd
        }
        
        timerState = .running
        
        
        timerCircleFillLayer.add(timerEndAnimation,forKey: "timerEnds")
    }
    
    //MARK: resets the timer
    private func resetTimer() {
        countDownTimer?.invalidate()
        timerCircleFillLayer.removeAllAnimations()
        updateLabel()
    }
    
    //MARK: updates label
    private func updateLabel() {
        let seconds = timerSeconds % 60
        let minutes = timerSeconds / 60 % 60
        let hours = timerSeconds / 3600
        
        if hours > 0 {
            let hourCount = String(hours).count
            let minuteCount = String(minutes).count
            let secondCount = String(seconds).count
            
            
            let timeString = "\(hours)h  \(minutes)m  \(seconds.appendZeros())s"
            let attributedString = NSMutableAttributedString(string: timeString,attributes: semiBoldAttributes)
            
            attributedString.addAttributes(timeAttributes, range: NSRange(location: 0, length: hourCount))
            attributedString.addAttributes(timeAttributes, range: NSRange(location: hourCount + 2, length: minuteCount))
            attributedString.addAttributes(timeAttributes, range: NSRange(location: hourCount + 2 + minuteCount + 2, length: secondCount))
            lblTime.attributedText = attributedString
        } else {
            let minuteCount = String(minutes).count
            let secondCount = String(seconds).count
            
            
            let timeString = "\(minutes)m \(seconds.appendZeros())s"
            let attributedString = NSMutableAttributedString(string: timeString,attributes: semiBoldAttributes)
            
            attributedString.addAttributes(timeAttributes, range: NSRange(location: 0, length: minuteCount))
            attributedString.addAttributes(timeAttributes, range: NSRange(location: minuteCount + 1, length: secondCount))
            lblTime.attributedText = attributedString
        }
    }
    
    //MARK: add bottom circle behind description label
    func addCircle() {
        let circleLayer = CAShapeLayer()
        circleLayer.path = UIBezierPath(arcCenter: CGPoint(x: 0, y: view.frame.height - 20), radius: 120, startAngle: 0, endAngle: 360.degreeToRadians(), clockwise: true).cgPath
        circleLayer.fillColor = UIColor(hex: "F6A63A").cgColor
        circleLayer.opacity = 0.15
        
        let circleLayerTwo = CAShapeLayer()
        circleLayerTwo.path = UIBezierPath(arcCenter: CGPoint(x: 0, y: view.frame.height - 60), radius: 110, startAngle: 0, endAngle: 360.degreeToRadians(), clockwise: true).cgPath
        circleLayerTwo.fillColor = UIColor(hex: "F6A63A").cgColor
        circleLayerTwo.opacity = 0.35
        
        view.layer.insertSublayer(circleLayer, below: view.layer)
        view.layer.insertSublayer(circleLayerTwo, below: view.layer)

        
        view.bringSubviewToFront(lblTaskDesc)
    }
}
