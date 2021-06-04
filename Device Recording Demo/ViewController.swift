//
//  ViewController.swift
//  Device Recording Demo
//
//  Created by Morten Just on 6/4/21.
//

import Cocoa
import AVFoundation
import CoreMediaIO

class ViewController: NSViewController {
    
    var session = AVCaptureSession()
    var input : AVCaptureInput?
    var output = AVCaptureMovieFileOutput()
    
    var captureDevice : AVCaptureDevice {
        AVCaptureDevice.devices(for: .muxed).first!
    }
    
    @IBOutlet weak var previewView: NSView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForDeviceMonitoring()
        previewView.wantsLayer = true
        
        session.addOutput(output)
    }
    
    
    func addInputDevice() {
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(input!) {
                session.addInput(input!)
            }
        } catch {
            print("add input: ", error.localizedDescription)
        }
    }
    
    func startPreview() {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        previewView.wantsLayer = true
        previewView.layer = layer
    }
    

    // MARK: UI
    @IBAction func printDevicesClicked(_ sender: Any) {
        print(AVCaptureDevice.devices(for: .muxed))
    }
    
    @IBAction func connectToFirstClicked(_ sender: Any) {
        addInputDevice()
        session.startRunning()
        startPreview()
    }
    
    @IBAction func startRecordingClicked(_ sender: Any) {
        let file = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0].appendingPathComponent("Device Recorder Repro.mov")
        try? FileManager.default.removeItem(at: file) // remove if already there
        output.startRecording(to: URL(fileURLWithPath: "~/Downloads/"), recordingDelegate: self)
    }
    
    @IBAction func stopRecordingClicked(_ sender: Any) {
        output.stopRecording()
    }
    
    deinit {
        print("bye")
        session.stopRunning()
    }
    
    
    func prepareForDeviceMonitoring(){
        print("dr: prepare")
                 var prop = CMIOObjectPropertyAddress(
                     mSelector: CMIOObjectPropertySelector(kCMIOHardwarePropertyAllowScreenCaptureDevices),
                     mScope: CMIOObjectPropertyScope(kCMIOObjectPropertyScopeGlobal),
                     mElement: CMIOObjectPropertyElement(kCMIOObjectPropertyElementMaster))
                 var allow: UInt32 = 1;
                 CMIOObjectSetPropertyData(CMIOObjectID(kCMIOObjectSystemObject), &prop,
                                           0, nil,
                                           UInt32(MemoryLayout.size(ofValue: allow)), &allow)
        
    }
    
}

extension ViewController : AVCaptureFileOutputRecordingDelegate {
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        print("finished recording to", outputFileURL.path)
    }
    
    
}
