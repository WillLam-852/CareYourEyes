//
//  ResultViewController.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 21/4/2023.
//

import UIKit

class ResultViewController: UIViewController {
    
    @IBOutlet weak var resultLabel: UILabel!
    @IBOutlet weak var timeDescriptionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var eyeExercisesDescriptionLabel: UILabel!
    @IBOutlet weak var eyeExerciseTextView: UITextView!
    
    var time: TimeInterval? = nil
    var result: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.hidesBackButton = true
        
        self.resultLabel.text = NSLocalizedString(K.Localization.result, comment: "Result")
        self.timeDescriptionLabel.text = "\(NSLocalizedString(K.Localization.time, comment: "Time")):"
        
        let dateComponentsFormatter = DateComponentsFormatter()
        dateComponentsFormatter.allowedUnits = [.minute, .second]
        dateComponentsFormatter.unitsStyle = .abbreviated
        self.timeLabel.text = dateComponentsFormatter.string(from: self.time!)
        
        self.eyeExercisesDescriptionLabel.text = "\(NSLocalizedString(K.Localization.eyeExercises, comment: "Eye Exercises")):"
        
        self.eyeExerciseTextView.text = result
    }
    

    @IBAction func doneButtonPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popToRootViewController(animated: true)
    }

}
