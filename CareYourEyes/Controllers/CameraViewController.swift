//
//  CameraViewController.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import UIKit
import AVFoundation

class CameraViewController: UIViewController {
    
    @IBOutlet weak var overlayView: OverlayView!
    @IBOutlet weak var tickImageView: UIImageView!
    
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
    
    /// Face Infromation from mediapipe to be shown in overlay view
    private var face: Face?
    /// Hand Infromation from mediapipe to be shown in overlay view
    private var leftHand: Hand?
    private var rightHand: Hand?
    
    // MARK: - Analyzer
    /// For analyzing movement
    private var movementAnalyzer = MovementAnalyzer()
    
    
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
            self.drawImage(image: cameraImage)
        }
        if let face = self.face,
           let leftHand = self.leftHand,
           let rightHand = self.rightHand {
            self.movementAnalyzer.importKeyPoints(face, leftHand, rightHand)
        }
        if self.movementAnalyzer.movementOne() {
            self.tickImageView.isHidden = false
        } else {
            self.tickImageView.isHidden = true
        }
        // Send the image to analyse information
        self.holisticTracker!.send(pixelBuffer, timestamp: CMSampleBufferGetPresentationTimeStamp(sampleBuffer))
        CVPixelBufferUnlockBaseAddress(pixelBuffer, CVPixelBufferLockFlags.readOnly)
    }
    
    /// Draw keypoints in the image
    func drawImage(image: UIImage) {
        let overlayViewExtraInformation = OverlayViewExtraInformation(
            image: image,
            face: self.face,
            leftHand: self.leftHand,
            rightHand: self.rightHand
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
        self.face = Face(faceLandmarks)
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputLeftHand leftHandLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.leftHand = Hand(leftHandLandmarks)
    }

    
    func holisticTracker(_ tracker: HolisticTracker!, didOutputRightHand rightHandLandmarks: [Landmark]!, timestamp time: CMTime) {
        self.rightHand = Hand(rightHandLandmarks)
    }
    
}
