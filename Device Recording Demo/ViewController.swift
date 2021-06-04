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
    @IBOutlet weak var statusLabel: NSTextField!
    
    
    @IBOutlet weak var previewView: NSView!

    override func viewDidLoad() {
        super.viewDidLoad()
        prepareForDeviceMonitoring()
        previewView.wantsLayer = true
        
        session.addOutput(output)
        
        status("Ready to connect")
    }
    
    
    func addInputDevice() {
        do {
            input = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(input!) {
                session.addInput(input!)
                status("Input added")
            }
        } catch {
            print("add input: ", error.localizedDescription)
            status("Can't add input")
        }
    }
    
    func startPreview() {
        let layer = AVCaptureVideoPreviewLayer(session: session)
        previewView.wantsLayer = true
        previewView.layer = layer
        
        status("Previewing")
    }
    
    func status(_ s : String) {
        DispatchQueue.main.async {
            self.statusLabel.stringValue = s
            print("log: ", s)
        }
        
    }
    

    // MARK: UI
    @IBAction func printDevicesClicked(_ sender: Any) {
        print(AVCaptureDevice.devices(for: .muxed))
    }
    
    @IBAction func connectToFirstClicked(_ sender: Any) {
        status("Connecting...")
        addInputDevice()
        session.startRunning()
        startPreview()
    }
    
    @IBAction func startRecordingClicked(_ sender: Any) {
        status("Preparing to record...")
        let file = FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("TesterMovie.mov")
        try? FileManager.default.removeItem(at: file) // remove if already there
        output.startRecording(to: file, recordingDelegate: self)
        
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
        status("Finished recording")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didStartRecordingTo fileURL: URL, from connections: [AVCaptureConnection]) {
        status("Now recording")
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, willFinishRecordingTo fileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        status("Will finish")
    }
    
    
    
    
}
