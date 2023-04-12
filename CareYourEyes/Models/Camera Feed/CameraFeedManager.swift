//
//  CameraFeedManager.swift
//  CareYourEyes
//
//  Created by Lam Wun Yin on 11/4/2023.
//

import AVFoundation
import UIKit

/// Manage the camera pipeline
final class CameraFeedManager: NSObject {
    
    /// Communicate with the session and other session objects on this queue.
    private let sessionQueue = DispatchQueue(label: K.DispatchQueueLabel.sessionQueue)
    
    /// An object that manages capture activity and coordinates the flow of data from input devices to capture outputs.
    lazy var captureSession: AVCaptureSession = .init()
    private var isSessionRunning: Bool = false
    
    /// A capture input that provides media from a capture device to a capture session. (Check if front / back camera)
    @objc dynamic var videoDeviceInput: AVCaptureDeviceInput!
    
    /// A capture output that records video and provides access to video frames for processing.
    lazy var videoDeviceOutput: AVCaptureVideoDataOutput = .init()
    
    private var setupResult: SessionSetupResult = .success
    
    private var videoOrientation: AVCaptureVideoOrientation = .portrait
    
    private var keyValueObservations = [NSKeyValueObservation]()
    
    
    // MARK: - Start, Stop, Resume Camera
    
    /// Start capturing frames from the camera.
    public func startRunning(completionHandler: @escaping () -> Void) {
        self.sessionQueue.async {
            self.addObservers()
            self.captureSession.startRunning()
            self.isSessionRunning = self.captureSession.isRunning
            completionHandler()
        }
    }
    
    
    /// Stop capturing frames from the camera.
     public func stopRunning() {
        self.sessionQueue.async {
            self.captureSession.stopRunning()
            self.isSessionRunning = self.captureSession.isRunning
            self.removeObservers()
        }
    }
    
    
    /// Resume capturing frames from the camera.
    public func resumeRunning(completionHandler: @escaping () -> Void) {
        self.sessionQueue.async {
            /*
             The session might fail to start running, for example, if a phone or FaceTime call is still
             using audio or video. This failure is communicated by the session posting a
             runtime error notification. To avoid repeatedly failing to start the session,
             only try to restart the session in the error handler if you aren't
             trying to resume the session.
             */
            self.captureSession.startRunning()
            self.isSessionRunning = self.captureSession.isRunning
            completionHandler()
        }
    }
    
    
    /// Check the video authorization status. Video access is required and audio access is optional. If the user denies audio access, AVCam won't record audio during movie recording.
    public func authorizeCamera() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            // The user has previously granted access to the camera.
            break
            
        case .notDetermined:
            /*
             The user has not yet been presented with the option to grant
             video access. Suspend the session queue to delay session
             setup until the access request has completed.
             
             Note that audio access will be implicitly requested when we
             create an AVCaptureDeviceInput for audio during session setup.
             */
            self.sessionQueue.suspend()
            AVCaptureDevice.requestAccess(for: .video, completionHandler: { granted in
                if !granted {
                    self.setupResult = .notAuthorized
                }
                self.sessionQueue.resume()
            })
            
        default:
            // The user has previously denied access.
            self.setupResult = .notAuthorized
        }
    }
    
    
    public func getVideoSetupResult() -> SessionSetupResult {
        return self.setupResult
    }
    
    
    /// Get current camera position
    public func getCurrentCameraPosition() -> AVCaptureDevice.Position {
        let currentVideoDevice = self.videoDeviceInput.device
        let currentPosition = currentVideoDevice.position
        return currentPosition
    }
        
    
    public func configureSession(windowOrientation: UIInterfaceOrientation, sampleBufferDelegate: AVCaptureVideoDataOutputSampleBufferDelegate) {
        self.sessionQueue.async {
            if self.setupResult != .success {
                return
            }
            
            self.captureSession.beginConfiguration()
            self.captureSession.sessionPreset = .photo
            var isFrontCamera: Bool = false
            
            // Add video input
            do {
                var defaultVideoDevice: AVCaptureDevice?
                
                if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                    // Default to the front wide angle camera.
                    defaultVideoDevice = frontCameraDevice
                    isFrontCamera = true
                } else if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                    // If a front wide angle camera is not available, Default to the back dual camera
                    defaultVideoDevice = dualCameraDevice
                } else if let dualWideCameraDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back) {
                    // If a back dual camera is not available, default to the rear dual wide camera.
                    defaultVideoDevice = dualWideCameraDevice
                } else if let backCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                    // If a rear dual camera is not available, default to the rear wide angle camera.
                    defaultVideoDevice = backCameraDevice
                }
                guard let videoDevice = defaultVideoDevice else {
                    print("ERROR: [configureSession] Default video device is unavailable.")
                    self.setupResult = .configurationFailed
                    self.captureSession.commitConfiguration()
                    return
                }
                
                let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                
                if self.captureSession.canAddInput(videoDeviceInput) {
                    self.captureSession.addInput(videoDeviceInput)
                    self.videoDeviceInput = videoDeviceInput
                    
                    var initialVideoOrientation: AVCaptureVideoOrientation = .portrait
                    if windowOrientation != .unknown {
                        if let videoOrientation = AVCaptureVideoOrientation(interfaceOrientation: windowOrientation) {
                            initialVideoOrientation = videoOrientation
                        }
                    }
                    self.videoOrientation = initialVideoOrientation
                } else {
                    print("ERROR: [configureSession] Couldn't add video device input to the session.")
                    self.setupResult = .configurationFailed
                    self.captureSession.commitConfiguration()
                    return
                }
            } catch {
                print("ERROR: [configureSession] Couldn't create video device input: \(error.localizedDescription)")
                self.setupResult = .configurationFailed
                self.captureSession.commitConfiguration()
                return
            }
            
            // Add the photo output.
            self.videoDeviceOutput.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String : kCVPixelFormatType_32BGRA]
            self.videoDeviceOutput.alwaysDiscardsLateVideoFrames = true
            // Sets the receiver's delegate that will accept captured buffers and dispatch queue on which the delegate will be called
            self.videoDeviceOutput.setSampleBufferDelegate(sampleBufferDelegate, queue: .main)
            if self.captureSession.canAddOutput(self.videoDeviceOutput) {
                self.captureSession.addOutput(self.videoDeviceOutput)
                self.captureSession.connections.first?.videoOrientation = .portrait
                if let connection = self.videoDeviceOutput.connection(with: .video) {
                    if connection.isVideoStabilizationSupported {
                        connection.preferredVideoStabilizationMode = .auto
                    }
                    if connection.isVideoMirroringSupported {
                        connection.isVideoMirrored = isFrontCamera
                    }
                }
            } else {
                print("ERROR: [configureSession] Could not add video device output to the session")
                self.setupResult = .configurationFailed
                self.captureSession.commitConfiguration()
                return
            }

            self.captureSession.commitConfiguration()
        }
    }
    
    
    public func switchCamera() {
        self.sessionQueue.async {
            let currentVideoDevice = self.videoDeviceInput.device
            let currentPosition = currentVideoDevice.position

            let backVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera, .builtInDualWideCamera, .builtInWideAngleCamera], mediaType: .video, position: .back)
            let frontVideoDeviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInTrueDepthCamera, .builtInWideAngleCamera], mediaType: .video, position: .front)
            var newVideoDevice: AVCaptureDevice? = nil
            
            switch currentPosition {
            case .unspecified, .front:
                newVideoDevice = backVideoDeviceDiscoverySession.devices.first
                
            case .back:
                newVideoDevice = frontVideoDeviceDiscoverySession.devices.first
                
            @unknown default:
                print("ERROR: [switchCamera] Unknown capture position. Defaulting to back, dual-wide-camera.")
                newVideoDevice = AVCaptureDevice.default(.builtInDualWideCamera, for: .video, position: .back)
            }
            
            if let videoDevice = newVideoDevice {
                do {
                    let videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
                    
                    self.captureSession.beginConfiguration()
                    
                    // Remove the existing device input first, because AVCaptureSession doesn't support simultaneous use of the rear and front cameras.
                    self.captureSession.removeInput(self.videoDeviceInput)
                    
                    if self.captureSession.canAddInput(videoDeviceInput) {
                        NotificationCenter.default.removeObserver(self, name: .AVCaptureDeviceSubjectAreaDidChange, object: currentVideoDevice)
                        NotificationCenter.default.addObserver(self, selector: #selector(self.subjectAreaDidChange), name: .AVCaptureDeviceSubjectAreaDidChange, object: videoDeviceInput.device)
                        
                        self.captureSession.addInput(videoDeviceInput)
                        self.videoDeviceInput = videoDeviceInput
                    } else {
                        self.captureSession.addInput(self.videoDeviceInput)
                    }
                    
                    self.captureSession.sessionPreset = .photo
                    self.captureSession.connections.first?.videoOrientation = .portrait
                    if let connection = self.videoDeviceOutput.connection(with: .video) {
                        if connection.isVideoStabilizationSupported {
                            connection.preferredVideoStabilizationMode = .auto
                        }
                        if connection.isVideoMirroringSupported {
                            connection.isVideoMirrored = currentPosition == .back
                        }
                    }
                    
                    self.captureSession.commitConfiguration()

                } catch {
                    print("ERROR: [switchCamera] occurred while creating video device input: \(error.localizedDescription)")
                }
            }
        }
    }
    
    
    // MARK: - KeyValueObservations and Notifications
    
    public func addObservers() {
        let systemPressureStateObservation = observe(\.videoDeviceInput.device.systemPressureState, options: .new) { _, change in
            guard let systemPressureState = change.newValue else { return }
            self.setRecommendedFrameRateRangeForPressureState(systemPressureState: systemPressureState)
        }
        self.keyValueObservations.append(systemPressureStateObservation)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(subjectAreaDidChange),
                                               name: .AVCaptureDeviceSubjectAreaDidChange,
                                               object: videoDeviceInput.device)

        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionRuntimeError),
                                               name: .AVCaptureSessionRuntimeError,
                                               object: captureSession)

        /*
         A session can only run when the app is full screen. It will be interrupted
         in a multi-app layout, introduced in iOS 9, see also the documentation of
         AVCaptureSessionInterruptionReason. Add observers to handle these session
         interruptions and show a preview is paused message. See the documentation
         of AVCaptureSessionWasInterruptedNotification for other interruption reasons.
         */
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionWasInterrupted),
                                               name: .AVCaptureSessionWasInterrupted,
                                               object: captureSession)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sessionInterruptionEnded),
                                               name: .AVCaptureSessionInterruptionEnded,
                                               object: captureSession)
    }
    
    
    private func removeObservers() {
        NotificationCenter.default.removeObserver(self)
        for keyValueObservation in keyValueObservations {
            keyValueObservation.invalidate()
        }
        keyValueObservations.removeAll()
    }
    
    
    @objc
    func subjectAreaDidChange(notification: NSNotification) {
        let devicePoint = CGPoint(x: 0.5, y: 0.5)
        self.focus(with: .continuousAutoFocus, exposureMode: .continuousAutoExposure, at: devicePoint, monitorSubjectAreaChange: false)
    }
    
    
    @objc
    func sessionRuntimeError(notification: NSNotification) {
        guard let error = notification.userInfo?[AVCaptureSessionErrorKey] as? AVError else { return }
        print("ERROR: [sessionRuntimeError] Capture session runtime error: \(error.localizedDescription)")
        // If media services were reset, and the last start succeeded, restart the session.
        if error.code == .mediaServicesWereReset {
            self.sessionQueue.async {
                if self.isSessionRunning {
                    self.captureSession.startRunning()
                    self.isSessionRunning = self.captureSession.isRunning
                }
            }
        }
    }
    
     /// In some scenarios you want to enable the user to resume the session. For example, if music playback is initiated from Control Center while using AVCam, then the user can let AVCam resume the session running, which will stop music playback. Note that stopping music playback in Control Center will not automatically resume the session. Also note that it's not always possible to resume.
    @objc
    func sessionWasInterrupted(notification: NSNotification) {
        if let userInfoValue = notification.userInfo?[AVCaptureSessionInterruptionReasonKey] as AnyObject?,
           let reasonIntegerValue = userInfoValue.integerValue,
           let reason = AVCaptureSession.InterruptionReason(rawValue: reasonIntegerValue) {
            print("ERROR: [sessionWasInterrupted] Capture session was interrupted with reason \(reason)")
        }
    }
    
    
    @objc
    func sessionInterruptionEnded(notification: NSNotification) {
        print("ALERT: [sessionInterruptionEnded] Capture session interruption ended")
    }

    
    private func setRecommendedFrameRateRangeForPressureState(systemPressureState: AVCaptureDevice.SystemPressureState) {
        /*
         The frame rates used here are only for demonstration purposes.
         Your frame rate throttling may be different depending on your app's camera configuration.
         */
        let pressureLevel = systemPressureState.level
        if pressureLevel == .serious || pressureLevel == .critical {
            do {
                try self.videoDeviceInput.device.lockForConfiguration()
                print("WARNING: [setRecommendedFrameRateRangeForPressureState] Reached elevated system pressure level: \(pressureLevel). Throttling frame rate.")
                self.videoDeviceInput.device.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 20)
                self.videoDeviceInput.device.activeVideoMaxFrameDuration = CMTime(value: 1, timescale: 15)
                self.videoDeviceInput.device.unlockForConfiguration()
            } catch {
                print("ERROR: [setRecommendedFrameRateRangeForPressureState] Could not lock device for configuration: \(error)")
            }
        } else if pressureLevel == .shutdown {
            print("ERROR: [setRecommendedFrameRateRangeForPressureState] Session stopped running due to shutdown system pressure level.")
        }
    }
    
    
    public func focus(with focusMode: AVCaptureDevice.FocusMode,
                       exposureMode: AVCaptureDevice.ExposureMode,
                       at devicePoint: CGPoint,
                       monitorSubjectAreaChange: Bool) {
        self.sessionQueue.async {
            let device = self.videoDeviceInput.device
            do {
                try device.lockForConfiguration()
                
                /*
                 Setting (focus/exposure)PointOfInterest alone does not initiate a (focus/exposure) operation.
                 Call set(Focus/Exposure)Mode() to apply the new point of interest.
                 */
                if device.isFocusPointOfInterestSupported && device.isFocusModeSupported(focusMode) {
                    device.focusPointOfInterest = devicePoint
                    device.focusMode = focusMode
                }
                
                if device.isExposurePointOfInterestSupported && device.isExposureModeSupported(exposureMode) {
                    device.exposurePointOfInterest = devicePoint
                    device.exposureMode = exposureMode
                }
                
                device.isSubjectAreaChangeMonitoringEnabled = monitorSubjectAreaChange
                device.unlockForConfiguration()
            } catch {
                print("ERROR: [focus] Could not lock device for configuration: \(error.localizedDescription)")
            }
        }
    }

}
