//
//  InitialViewController.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var eyeExercisesTabelView: UITableView!
    @IBOutlet weak var startButton: UIBarButtonItem!
    
    let eyeExercises: [any AbstractEyeExercise] = [
        EyeExerciseOne(),
        EyeExerciseTwo(),
        EyeExerciseThree()
    ]
    var selectedIndexes: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = NSLocalizedString(K.Localization.appTitle, comment: "App Title")
        self.startButton.title = NSLocalizedString(K.Localization.start, comment: "Start")
        
        self.eyeExercisesTabelView.register(UINib(nibName: K.NIBName.SelectEyeExercisesTableViewCell, bundle: nil), forCellReuseIdentifier: K.TableViewCell.selectEyeExercisesTableViewCell)
        self.eyeExercisesTabelView.delegate = self
        self.eyeExercisesTabelView.dataSource = self
    }
    
    
    @IBAction func startButtonPressed(_ sender: UIBarButtonItem) {
        if self.selectedIndexes.count == 0 {
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: NSLocalizedString(K.Localization.selectEyeExercise, comment: "Please Select Eye Exercise First"),
                    message: nil,
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString(K.Localization.OK, comment: "OK"),
                    style: .cancel,
                    handler: nil
                ))
                self.present(alertController, animated: true, completion: nil)
            }
            return
        }
        self.performSegue(withIdentifier: K.StoryboardSegue.initialToCameraSegue, sender: self)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == K.StoryboardSegue.initialToCameraSegue {
            // Tell the camera view which orientation currently is
            let deviceOrientation = self.view.window?.windowScene?.interfaceOrientation ?? .unknown
            if let cameraVC = segue.destination as? CameraViewController {
                cameraVC.deviceOrientation = deviceOrientation
                cameraVC.eyeExercisesList = self.filterEyeExercisesByIndex(self.eyeExercises, self.selectedIndexes)
            }
        }
    }
    
    
    private func filterEyeExercisesByIndex(_ eyeExercises: [any AbstractEyeExercise], _ selectedIndexes: [Int]) -> [any AbstractEyeExercise] {
        var selectedEyeExercises: [any AbstractEyeExercise] = []
        for index in selectedIndexes {
            selectedEyeExercises.append(eyeExercises[index])
        }
        return selectedEyeExercises
    }

}


extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return eyeExercises.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViewCell.selectEyeExercisesTableViewCell) as? SelectEyeExercisesTableViewCell {
            cell.eyeExerciseImageView.image = self.eyeExercises[indexPath.row].image
            cell.titleLabel.text = self.eyeExercises[indexPath.row].name
            cell.descriptionLabel.text = self.eyeExercises[indexPath.row].description
            if self.selectedIndexes.contains(indexPath.row) {
                cell.cellBackgroundView.backgroundColor = .systemGray.withAlphaComponent(0.3)
                cell.tickImageView.isHidden = false
            } else {
                cell.cellBackgroundView.backgroundColor = .systemBackground
                cell.tickImageView.isHidden = true
            }
            return cell
        }
        return UITableViewCell()
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 350
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.selectedIndexes.contains(indexPath.row) {
            self.selectedIndexes.append(indexPath.row)
            self.selectedIndexes.sort()
        } else {
            self.selectedIndexes.removeAll { $0 == indexPath.row }
        }
        tableView.reloadData()
    }
        
}
