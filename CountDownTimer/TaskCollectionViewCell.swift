//
//  TaskCollectionViewCell.swift
//  CountDownTimer
//
//  Created by Nitin Bhatia on 24/09/22.
//

import UIKit



class TaskCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imgContainerView: UIView!
    @IBOutlet weak var lblTaskName: UILabel!
    @IBOutlet weak var imgTask: UIImageView!
    

    override func awakeFromNib() {
        super.awakeFromNib()
        DispatchQueue.main.async {
            self.imgContainerView.layer.cornerRadius = self.imgContainerView.frame.width / 2
        }
    }

    class override func description() -> String {
        return "TaskCollectionViewCell"
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        reset()
        imgTask.image = nil
    }
    
    fileprivate func reset() {
        imgContainerView.backgroundColor = .clear
        lblTaskName.textColor = .black
        imgTask.tintColor = .black
    }
    
    func setupCell(taskType: TaskType, isSelected: Bool) {
        
        lblTaskName.text = taskType.typeName
        
        if isSelected {
            imgContainerView.backgroundColor = UIColor(hex: "17b890").withAlphaComponent(0.5)
            lblTaskName.textColor = UIColor(hex: "006666")
            imgTask.tintColor = .white
            imgTask.image = UIImage(systemName: taskType.symboName,withConfiguration: UIImage.SymbolConfiguration(pointSize: 24, weight: .medium))
        } else {
            reset()
                imgTask.image = UIImage(systemName: taskType.symboName,withConfiguration: UIImage.SymbolConfiguration(pointSize: 22, weight: .regular))
        }
        
    }
}
