//
//  NewTaskViewController.swift
//  CountDownTimer
//
//  Created by Nitin Bhatia on 24/09/22.
//

import UIKit

class NewTaskViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var lblNewTaskTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var nameDescContainerView: UIView!
    @IBOutlet weak var lblTaskType: UILabel!
    @IBOutlet weak var txtTaskName: UITextField!
    @IBOutlet weak var txtTaskDescription: UITextField!
    @IBOutlet weak var btnStart: UIButton!
    @IBOutlet weak var txtSecond: UITextField!
    @IBOutlet weak var txtMinute: UITextField!
    @IBOutlet weak var txtHour: UITextField!
    @IBOutlet weak var tasksCollectionView: UICollectionView!
    
    //variables
    var taskTypeViewModel : TaskTypeViewModel!
    private var keyboardOpened : Bool = false

    
    override func viewDidLoad() {
        super.viewDidLoad()
        taskTypeViewModel = TaskTypeViewModel()
        tasksCollectionView.register(UINib(nibName: TaskCollectionViewCell.description(), bundle: .main), forCellWithReuseIdentifier: TaskCollectionViewCell.description())
        tasksCollectionView.delegate = self
        tasksCollectionView.dataSource = self
        btnStart.layer.cornerRadius = 12
        nameDescContainerView.layer.cornerRadius = 12
        
        [txtHour,txtMinute,txtSecond].forEach({
            $0?.attributedPlaceholder = NSAttributedString(string: "00",attributes: [NSAttributedString.Key.font:UIFont(name: "Arial", size: 28), NSAttributedString.Key.foregroundColor: UIColor.black])
            $0?.delegate = self
            $0?.addTarget(self, action: #selector(textFieldInputChange), for: .editingChanged)
        })
        
        txtTaskName.attributedPlaceholder = NSAttributedString(string: "Task Name",attributes: [NSAttributedString.Key.font:UIFont(name: "Arial", size: 17),NSAttributedString.Key.foregroundColor: UIColor.black])
        txtTaskName.addTarget(self, action: #selector(textFieldInputChange), for: .editingChanged)

        txtTaskDescription.attributedPlaceholder = NSAttributedString(string: "Task Description",attributes: [NSAttributedString.Key.font:UIFont(name: "Arial", size: 17),NSAttributedString.Key.foregroundColor: UIColor.black])
        txtTaskDescription.addTarget(self, action: #selector(textFieldInputChange), for: .editingChanged)

        let gest = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        view.addGestureRecognizer(gest)
        gest.cancelsTouchesInView = false //this will allow collection did selection to work
        view.isUserInteractionEnabled = true
        
        taskTypeViewModel.hours.bind {hours in
            self.txtHour.text = hours.appendZeros()
        }
        
        taskTypeViewModel.minutes.bind {minutes in
            self.txtMinute.text = minutes.appendZeros()
        }
        
        taskTypeViewModel.seconds.bind {seconds in
            self.txtSecond.text = seconds.appendZeros()
        }
        
        disableButton()
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        
    }
    
    override class func description() -> String {
        return "NewTaskViewController"
    }
    
    //MARK: keyboard will show notification
    @objc func keyboardWillShow(_ notification: Notification) {
        if !Constants.hasTopNotch, !keyboardOpened {
            lblNewTaskTopConstraint.constant -= view.frame.height * 0.2
            view.layoutIfNeeded()
            keyboardOpened = true
        }
    }
    
    //MARK: keyboard will hide notification
    @objc func keyboardWillHide(_ notification: Notification) {
            lblNewTaskTopConstraint.constant = 20
            view.layoutIfNeeded()
        keyboardOpened = false
    }
    
    //MARK: btn start action
    @IBAction func btnStartAction(_ sender: Any) {
        guard let timerVC = storyboard?.instantiateViewController(withIdentifier: TimerViewController.description()) as? TimerViewController else {
            return
        }
        taskTypeViewModel.computeSeconds()
        timerVC.task = taskTypeViewModel.getTask()

        present(timerVC, animated: true)
    }
    
    //MARK: btn close action
    @IBAction func btnCloseAction(_ sender: Any) {
    }
    
    //MARK: view tapped gesture to close the keyboard
    @objc func viewTapped(_ sender : UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    //MARK: updates start button state
    fileprivate func updateStartButtonState() {
        if taskTypeViewModel.isTaskValid() {
            enableButton()
        } else {
            disableButton()
        }
    }
    
    //MARK: text field input change event
    @objc func textFieldInputChange(_ textField:UITextField) {
        guard let text  = textField.text else {
            return
        }
        if textField == txtTaskName {
            taskTypeViewModel.setTaskName(to: text)
        } else if textField == txtTaskDescription {
            taskTypeViewModel.setTaskDescription(to: text)
        } else if textField == txtHour {
            guard let hour = Int(text) else {return}
            taskTypeViewModel.setHours(to: hour)
        } else if textField == txtMinute {
            guard let minute = Int(text) else {return}
            taskTypeViewModel.setMinutes(to: minute)
        } else {
            guard let seconds = Int(text) else {return}
            taskTypeViewModel.setSeconds(to: seconds)
        }
        
        updateStartButtonState()
        
    }
    
    //MARK: enables button as per validation
    func enableButton() {
        if !btnStart.isUserInteractionEnabled {
            UIView.animate(withDuration: 0.25, delay: 0, animations: {
                self.btnStart.layer.opacity = 1
            },completion: {_ in
                self.btnStart.isUserInteractionEnabled = true
            })
        }
    }
    
    //MARK: disables button as per validation
    func disableButton() {
        if btnStart.isUserInteractionEnabled {
            UIView.animate(withDuration: 0.25, delay: 0, animations: {
                self.btnStart.layer.opacity = 0.5
            },completion: {_ in
                self.btnStart.isUserInteractionEnabled = false
            })
        }
    }
    
    //MARK: text field delegates
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 2
        
        let currentText : NSString = (textField.text ?? "") as NSString
        let newString: NSString = currentText.replacingCharacters(in: range, with: string) as NSString
        
        
        guard let text = textField.text else {return false}
        
        if text.count == 2 && text.starts(with: "0") {
            textField.text?.removeFirst()
            textField.text? += string
            textFieldInputChange(textField)
        }
        
        return newString.length <= maxLength
    }
    
    
    //MARK: collection view delegates
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return taskTypeViewModel.getTaskTypes().count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TaskCollectionViewCell.description(), for: indexPath) as! TaskCollectionViewCell
        cell.setupCell(taskType: taskTypeViewModel.getTaskTypes()[indexPath.row], isSelected: taskTypeViewModel.getSelectedIndex() == indexPath.row)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let columns : CGFloat = 3.75
        let width : CGFloat = collectionView.frame.width
        
        let flowLayout = collectionViewLayout as! UICollectionViewFlowLayout
        let adjustWidth = width - (flowLayout.minimumLineSpacing * (columns - 1)) //we want to show 3 columns to full and 4th one partial that is why we are substract - 1 from columns
        return CGSize(width: adjustWidth / columns, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        taskTypeViewModel.setSelectedIndex(to: indexPath.item)
        tasksCollectionView.reloadSections(IndexSet(0 ..< 1))
        updateStartButtonState()
    }
    
}
