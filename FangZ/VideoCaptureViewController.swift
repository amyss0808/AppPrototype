//
//  VideoCaptureViewController.swift
//  AppPrototype
//
//  Created by 林晏竹 on 2017/3/23.
//  Copyright © 2017年 soslab. All rights reserved.
//

import UIKit
import AVFoundation
import os.log

class VideoCaptureViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // MARK: - Task Properties
    var taskId: String?
    
    
    
    // MARK: - Camera Properties
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var recordStopButton: UIButton!
    
    let captureSession = AVCaptureSession()
    var previewLayer: AVCaptureVideoPreviewLayer?
    var videoCaptureDevice: AVCaptureDevice?
    var movieFileOutput = AVCaptureMovieFileOutput()
    var outputFileLocation: URL?
    
    
    
    // MARK: - Timer Properties
    @IBOutlet weak var timerLabel: UILabel!
    var timer = Timer()
    var seconds: Int = 0
    var minutes: Int = 0
    var hours: Int = 0
    
    
    
    // MARK: - Device Orientation Properties
    var currentDevice = UIDevice.current
    let wrongOrientationAlert = UIAlertController(title: "裝置方向錯誤", message: "請解除螢幕旋轉鎖定，並向左旋轉您的裝置。", preferredStyle: .alert)
    
    
    
    // MARK: - Hint Properties
    @IBOutlet weak var hintLabel: UILabel!
    
    
    
    // MARK: - View Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.prepareCamera()
        self.prepareWrongOrientationAlert()
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        UIApplication.shared.isStatusBarHidden = true
        
        self.prepareTimer()
        self.prepareHint()
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoCaptureViewController.getDeviceOrientation), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
        self.currentDevice.beginGeneratingDeviceOrientationNotifications()
    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.getDeviceOrientation()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        UIApplication.shared.isStatusBarHidden = false
        
        self.currentDevice.endGeneratingDeviceOrientationNotifications()
        NotificationCenter.default.removeObserver(self)
        self.dismissWrongOrientationAlert()
    }


    
    
    
    
    // MARK: - Camera Functions
    private func prepareCamera() {
        self.captureSession.sessionPreset = AVCaptureSessionPresetHigh
        
        if let availableDevice = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .back).devices {
            
            self.videoCaptureDevice = availableDevice.first
            
            beginSession()
            
        } else {
            // alert
            print("There is no back camera")
        }
    }
    
    
    private func beginSession() {
        // add inputs
        do {
            // request user's permission of camera
            let captureDeviceInput = try AVCaptureDeviceInput(device: self.videoCaptureDevice)
            
            if self.captureSession.canAddInput(captureDeviceInput) {
                self.captureSession.addInput(captureDeviceInput)
            } else {
                print("captureSession cannot add captureDeviceInput")
            }
            
            
            if let audioInput = AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeAudio) {
                try self.captureSession.addInput(AVCaptureDeviceInput(device: audioInput))
            }
            
        } catch {
            print("\(error.localizedDescription)")
        }
        
        
        // display live stream from the camera device
        self.previewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        
        
        self.previewView.frame = self.view.frame
        self.previewView.layer.insertSublayer(self.previewLayer!, above: self.previewView.layer)
        self.previewLayer?.frame = self.previewView.frame
        
        
        // add output
        if captureSession.canAddOutput(self.movieFileOutput) {
            self.captureSession.addOutput(self.movieFileOutput)
        } else {
            print("captureSession cannot add movieFileOutput")
        }
        
        
        // tells the receiver(captureSession) to start getting inputs from the camera
        captureSession.startRunning()
    }
    

    
    
    
    
    
    // MARK: - Button Actions
    @IBAction func recordStoppedButtonTapped(_ sender: UIButton) {
        
        if self.movieFileOutput.isRecording {
            
            // stop recording
            self.movieFileOutput.stopRecording()
            self.stopTiming()
            self.recordStopButton.setImage(UIImage(named: "start record"), for: .normal)
            
        } else {
            
            // start recording
            self.movieFileOutput.connection(withMediaType: AVMediaTypeVideo).videoOrientation = .landscapeRight
            self.movieFileOutput.startRecording(toOutputFileURL: URL(fileURLWithPath: self.videoFileLocation()), recordingDelegate: self)
            self.recordStopButton.setImage(UIImage(named: "stop record"), for: .normal)
            self.startTiming()
        }
    }
    
    
    @IBAction func cancelRecording(_ sender: UIButton) {
        self.dismiss(animated: true, completion: {
            self.stopTiming()
        })
    }

    
    private func videoFileLocation() -> String {
        return NSTemporaryDirectory().appending("videoFile.mov")
    }
    
    
    
    
    
    
    // MARK: - Timer Functions
    private func prepareTimer() {
        self.timerLabel.text = "00:00:00"
        self.timerLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        self.seconds = 0
        self.minutes = 0
        self.hours = 0
    }
    
    
    private func startTiming() {
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.countVideoDuration), userInfo: nil, repeats: true)
    }
    
    
    private func stopTiming() {
        self.timer.invalidate()
    }
    
    
    @objc private func countVideoDuration() {
        
        self.seconds += 1
        if self.seconds == 60 {
            self.seconds = 0
            self.minutes += 1
        }
        
        if self.minutes == 60 {
            self.minutes = 0
            self.hours += 1
        }
        
        // ":" stands for otherwise
        let secondsString = self.seconds > 9 ? "\(self.seconds)" : "0\(self.seconds)"
        let minutesString = self.minutes > 9 ? "\(self.minutes)" : "0\(self.minutes)"
        let hoursString = self.hours > 9 ? "\(self.hours)" : "0\(self.hours)"
        
        timerLabel.text = hoursString + ":" + minutesString + ":" + secondsString
    }
    
    
    
    
    
    // MARK: - Device Orientation Functions
    @objc private func getDeviceOrientation() {
        switch self.currentDevice.orientation {
            
        case .landscapeLeft:
            recordStopButton.isEnabled = true
            
        default:
            self.presentWrongOrientationAlert()
            recordStopButton.isEnabled = false
        }
    }
    
    
    private func prepareWrongOrientationAlert() {
        self.wrongOrientationAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
    }
    
    
    private func presentWrongOrientationAlert() {
        if self.wrongOrientationAlert.presentingViewController == nil {
            self.present(wrongOrientationAlert, animated: true, completion: {
                print("presented alert because: wrong orientation")
            })
        }
    }
    
    
    private func dismissWrongOrientationAlert() {
        if self.wrongOrientationAlert.presentingViewController != nil {
            self.dismiss(animated: true, completion: {
                print("dismissed alert")
            })
        }
    }
    
    
    
    
    // MARK: - Hint Functions
    private func prepareHint() {
        self.hintLabel.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
        self.hintLabel.text = "請說明：天氣狀況 安靜程度 乾淨程度 車流量狀況 沿路特別的店家、事物"
    }
    
    
    
    
    // MARK: - AVCaptureFileOutputRecordingDelegate
    // called when stop recording
    func capture(_ captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAt outputFileURL: URL!, fromConnections connections: [Any]!, error: Error!) {
        
        self.outputFileLocation = outputFileURL
        self.performSegue(withIdentifier: "videoPlayback", sender: nil)
    }

    
    
    
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "videoPlayback":
            guard let videoPlaybackVC = segue.destination as? VideoPlaybackViewController else {
                fatalError("The destination view controller: \(segue.destination) of this segue is not VideoPlaybackViewController")
            }
            videoPlaybackVC.fileLocation = self.outputFileLocation
            videoPlaybackVC.taskId = self.taskId
            
        default:
            fatalError("Unexpected Segue Identifier: \(segue.identifier)")
        }
    }
}
