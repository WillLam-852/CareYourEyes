//
//  InitialViewController.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import UIKit

class InitialViewController: UIViewController {

    @IBOutlet weak var movementsTableView: UITableView!
    @IBOutlet weak var startButton: UIButton!
    
    let movements: [any AbstractMovement] = [
        MovementOne(),
        MovementTwo(),
        MovementThree()
    ]
    var selectedIndexes: [Int] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.movementsTableView.delegate = self
        self.movementsTableView.dataSource = self
        self.startButton.setTitle(NSLocalizedString(K.Localization.start, comment: "Start"), for: .normal)
    }
    
    
    @IBAction func startButtonPressed(_ sender: UIButton) {
        if self.selectedIndexes.count == 0 {
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: NSLocalizedString(K.Localization.selectMovement, comment: "Please Select Movement First"),
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
                cameraVC.movementsList = self.filterMovementsByIndex(self.movements, self.selectedIndexes)
            }
        }
    }
    
    
    private func filterMovementsByIndex(_ movements: [any AbstractMovement], _ selectedIndexes: [Int]) -> [any AbstractMovement] {
        var selectedMovements: [any AbstractMovement] = []
        for index in selectedIndexes {
            selectedMovements.append(movements[index])
        }
        return selectedMovements
    }

}


extension InitialViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return movements.count
    }
    

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: K.TableViewCell.movementTableViewCell)!
        cell.textLabel?.text = self.movements[indexPath.row].name
        if self.selectedIndexes.contains(indexPath.row) {
            cell.accessoryType = .checkmark
        } else {
            cell.accessoryType = .none
        }
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if !self.selectedIndexes.contains(indexPath.row) {
            self.selectedIndexes.append(indexPath.row)
            self.selectedIndexes.sort()
        } else {
            self.selectedIndexes.removeAll { $0 == indexPath.row }
        }
        tableView.reloadRows(at: [indexPath], with: .automatic)
    }
        
}
