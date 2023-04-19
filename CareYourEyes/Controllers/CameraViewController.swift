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
    
    // MARK: - Tracker
    
    private lazy var holisticTracker = HolisticTracker()
    
    // MARK: - Controllers that manage functionality
    
    /// Handle the camera pipeline.
    private let cameraFeedManager = CameraFeedManager()
    /// Serial queue to control all tasks related to the AI model.
    private let AIModelQueue = DispatchQueue(label: K.DispatchQueueLabel.AIModelQueue)
    /// Flag to make sure there's only one frame processed at each moment.
    private var poseModelIsRunning = false
    /// Orientation of the device
    var deviceOrientation: UIInterfaceOrientation = .unknown
    
    // MARK: - Key Points Models
    
    /// Holistic Infromation from mediapipe to be shown in overlay view
    private var holistic = Holistic()
    
    // MARK: - Analyzer
    /// For analyzing movement
    private var movementAnalyzer = MovementAnalyzer()
    /// Count for consecutive detection
    private var currentCount: Float = 0.0
    /// Target count for consecutive detection
    private let targetCount: Float = K.KeyPointAnalysis.targetCount
    
    // MARK: - Movement
    /// Current movement
    var currentMovement: AbstractMovement = MovementOne()
    
    
    // MARK: - View Handling Methods

    override func viewDidLoad() {
        super.viewDidLoad()

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
        DispatchQueue.main.async {
            let cameraImage = UIImage(ciImage: CIImage(cvPixelBuffer: pixelBuffer))
            self.drawImage(image: cameraImage, movement: self.currentMovement)
        }
        
        do {
            let checkResult = try self.movementAnalyzer.check(holistic: self.holistic, movement: self.currentMovement)
            if checkResult {
                self.currentCount += 1
            } else {
                self.currentCount = 0
            }
            let progress = Float(self.currentCount / self.targetCount)
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
    func drawImage(image: UIImage, movement: AbstractMovement) {
        let overlayViewExtraInformation = OverlayViewExtraInformation(
            image: image,
            holistic: self.holistic,
            movement: self.currentMovement
        )
        self.overlayView.draw(overlayViewExtraInformation)
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
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputLeftHand leftHandLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.holistic.leftHand = Hand(leftHandLandmarks)
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputRightHand rightHandLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.holistic.rightHand = Hand(rightHandLandmarks)
    }
    
}
