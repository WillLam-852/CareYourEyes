//
//  CameraViewController.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import AVFoundation
import os
import UIKit

class CameraViewController: UIViewController {
    
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var tickImageView: UIImageView!
    @IBOutlet weak var progressBar: ProgressBarView!
    @IBOutlet weak var countLabel: UILabel!
    
    // MARK: - Tracker
    
    private lazy var holisticTracker = HolisticTracker()
    
    // MARK: - Controllers that manage functionality
    
    /// Handle the camera pipeline.
    private let cameraFeedManager = CameraFeedManager()
    /// Orientation of the device
    var deviceOrientation: UIInterfaceOrientation = .unknown
    
    // MARK: - Key Points Models
    
    /// Holistic Infromation from mediapipe to be shown in overlay view
    private var holistic = Holistic()
    
    // MARK: - Analyzer
    /// For analyzing movement
    private var movementAnalyzer = MovementAnalyzer()
    /// Current count for consecutive detection
    private var currentDetectionCount: Float = 0.0
    /// Target count for consecutive detection
    private let targetDetectionCount: Float = K.KeyPointAnalysis.targetDetectionCount
    /// Current count for this movement
    private var currentMovementCount: Int = 0
    /// Target count for this movement
    private let targetMovementCount: Int = K.KeyPointAnalysis.targetMovementCount

    
    // MARK: - Movement
    /// Movement list
    var movementsList: [any AbstractMovement] = []
    /// Current movement
    var currentMovement: (any AbstractMovement)?
    /// Current movement index
    var currentMovementIndex: Int = 0
    
    // MARK: - CountdownTimer (for dots disappearance)
    private var faceCountdownTimer = CountdownTimer(totalTime: 0.3)
    private var leftHandCountdownTimer = CountdownTimer(totalTime: 0.3)
    private var rightHandCountdownTimer = CountdownTimer(totalTime: 0.3)
    
    // MARK: - View Handling Methods

    override func viewDidLoad() {
        super.viewDidLoad()

        self.currentMovement = self.movementsList[self.currentMovementIndex]
        self.countLabel.text = "\(self.currentMovementCount) / \(self.targetMovementCount)"

        self.cameraFeedManager.authorizeCamera()
        self.cameraFeedManager.configureSession(interfaceOrientation: deviceOrientation, sampleBufferDelegate: self)
        
        self.holisticTracker!.delegate = self
        self.holisticTracker!.startGraph()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let setupResult = self.cameraFeedManager.getVideoSetupResult()
        switch setupResult {
        case .success:
            // Only setup observers and start the session if setup succeeded.
            self.cameraFeedManager.startRunning {
                // Set up something
            }
            
        case .notAuthorized:
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: NSLocalizedString(K.Localization.permissionRequest, comment: "Permission Required"),
                    message: NSLocalizedString(K.Localization.enablePermission, comment: "Please enable Camera Permission to use this function."),
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString(K.Localization.OK, comment: "OK"),
                    style: .cancel,
                    handler: nil
                ))
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString(K.Localization.settings, comment: "Settings"),
                    style: .default,
                    handler: { _ in
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!,
                                                  options: [:],
                                                  completionHandler: nil)
                    }
                ))
                self.present(alertController, animated: true, completion: nil)
            }
            
        case .configurationFailed:
            DispatchQueue.main.async {
                let alertController = UIAlertController(
                    title: NSLocalizedString(K.Localization.error, comment: "Error"),
                    message: NSLocalizedString(K.Localization.unableCaptureMedia, comment: "Unable to capture media"),
                    preferredStyle: .alert
                )
                alertController.addAction(UIAlertAction(
                    title: NSLocalizedString(K.Localization.OK, comment: "OK"),
                    style: .cancel,
                    handler: nil
                ))
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.cameraFeedManager.stopRunning()
    }

}



// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate Methods

extension CameraViewController: AVCaptureVideoDataOutputSampleBufferDelegate {

    /// Called whenever an AVCaptureVideoDataOutput instance outputs a new video frame.
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer) else {
            return
        }
        CVPixelBufferLockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
        
        // Show the real-time video thread
        let cameraImage = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
        self.drawImage(image: cameraImage, holistic: self.holistic, movement: self.currentMovement!)
        
        do {
            let checkResult = try self.movementAnalyzer.check(holistic: self.holistic, movement: self.currentMovement!)
            if checkResult {
                self.currentDetectionCount += 1
            } else {
                if self.currentDetectionCount >= self.targetDetectionCount {
                    self.currentMovementCount += 1
                }
                self.currentDetectionCount = 0
            }
            let progress = Float(self.currentDetectionCount / self.targetDetectionCount)
            self.progressBar.progress = progress
            switch progress {
            case ..<0.5:
                self.progressBar.progressTintColor = .red
            case 0.5..<0.9:
                self.progressBar.progressTintColor = .yellow
            case 0.9...:
                self.progressBar.progressTintColor = .green
            default:
                self.progressBar.progressTintColor = .red
            }
            if progress >= 1.0 {
                self.tickImageView.isHidden = false
            } else {
                self.tickImageView.isHidden = true
            }
            if self.currentMovementCount >= self.targetMovementCount {
                self.currentMovementIndex += 1
                if self.currentMovementIndex >= self.movementsList.count {
                    DispatchQueue.main.async {
                        self.navigationController?.popViewController(animated: true)
                    }
                } else {
                    self.currentMovement = self.movementsList[self.currentMovementIndex]
                    self.currentMovementCount = 0
                }
            }
            self.countLabel.text = "\(self.currentMovementCount) / \(self.targetMovementCount)"
        } catch {
            if #available(iOS 14.0, *) {
                os_log("\(error.localizedDescription)")
            }
        }
        
        // Send the image to analyse information
        self.holisticTracker!.send(pixelBuffer, timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }
    
    /// Draw keypoints in the image
    func drawImage(image: UIImage, holistic: Holistic, movement: any AbstractMovement) {
        let overlayViewExtraInformation = OverlayViewExtraInformation(
            image: image,
            holistic: holistic,
            movement: movement
        )
        DispatchQueue.main.async {
            self.overlayView.draw(overlayViewExtraInformation)
        }
    }

}


// MARK: - HolisticTrackerDelegate

extension CameraViewController: HolisticTrackerDelegate {
    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputPixelBuffer pixelBuffer: CVPixelBuffer!) {
//        DispatchQueue.main.async {
//            self.overlayView.image = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
//        }
    }
    
    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputPoseLandmarks poseLandmarks: [Landmark]!, timestamp time: CMTime) {
        // TODO
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputFace faceLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.holistic.face = Face(faceLandmarks)
        DispatchQueue.main.async {
            self.faceCountdownTimer.start(
                onCompletion:  {
                    self.holistic.face = nil
                }
            )
        }
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputLeftHand leftHandLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.holistic.leftHand = Hand(leftHandLandmarks)
        DispatchQueue.main.async {
            self.leftHandCountdownTimer.start(
                onCompletion:  {
                    self.holistic.leftHand = nil
                }
            )
        }
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputRightHand rightHandLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.holistic.rightHand = Hand(rightHandLandmarks)
        DispatchQueue.main.async {
            self.rightHandCountdownTimer.start(
                onCompletion:  {
                    self.holistic.rightHand = nil
                }
            )
        }
    }
    
}
