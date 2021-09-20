//
//  CameraView.swift
//  Barcode Scanner
//
//  Created by Jimmy on 20/9/2021.
//

import Foundation
import UIKit
import AVFoundation
import SwiftUI

struct CameraView: View{
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @Binding var barcode: String
    var body: some View{
        CameraViewControllerRepresentable { string in
            barcode = string
            presentationMode.wrappedValue.dismiss()
        }.edgesIgnoringSafeArea(.top)
    }
}


struct CameraViewControllerRepresentable: UIViewControllerRepresentable{
    
    var completion: (String) -> Void
    
    func makeUIViewController(context: Context) -> CameraViewController {
        let cameraViewController = CameraViewController()
        cameraViewController.metadataOutputDelegate = context.coordinator
        return cameraViewController
    }
    
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, AVCaptureMetadataOutputObjectsDelegate{
        var parent: CameraViewControllerRepresentable
        init(_ parent: CameraViewControllerRepresentable){
            self.parent = parent
        }
        
        func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
            if let metadataObject = metadataObjects.first {
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))

                print("[Coordinator] String Value: \(stringValue), Type: \(metadataObject.type.rawValue)")
                parent.completion(stringValue)
            }
        }
    }
}


class CameraViewController : UIViewController{
    var previewView: UIView!
    let captureSession = AVCaptureSession()
    var device : AVCaptureDevice?
    var metadataOutputDelegate: AVCaptureMetadataOutputObjectsDelegate?
    var cameraPreviewLayer: AVCaptureVideoPreviewLayer?
    
    override func viewDidLoad() {
        previewView = UIView(frame: CGRect(x:0, y:0, width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height))
        previewView.contentMode = .scaleAspectFit
        self.view.addSubview(previewView)
        
        setup()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if (captureSession.isRunning){
            captureSession.stopRunning()
        }
    }
    
    func setup(){
        setupDevice()
        setupInputOutput()
        setupPreviewLayer()
        setupRunSession()
    }
    
    func setupDevice(){
        device = AVCaptureDevice.default(for: .video)
        
        try? device?.lockForConfiguration()
        device?.unlockForConfiguration()
    }
    
    func setupInputOutput(){
        do{
            let input = try AVCaptureDeviceInput(device: device!)
            captureSession.addInput(input)
            let output = AVCaptureMetadataOutput()
            captureSession.addOutput(output)
            output.setMetadataObjectsDelegate(metadataOutputDelegate, queue: .main)
            output.metadataObjectTypes = [.qr, .code128, .code93, .code39]   // Change support object type as you want
        }catch{
            print(error)
        }
    }
    
    func setupPreviewLayer(){
        cameraPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        cameraPreviewLayer?.videoGravity = .resizeAspectFill
        cameraPreviewLayer?.connection?.videoOrientation = .portrait
        cameraPreviewLayer?.frame = self.view.frame
        
        // Add center red line
        let redLayer = CALayer()
        redLayer.frame = CGRect.init(x: 0, y: Int(view.frame.height / 2), width: Int(view.frame.width), height: 4)
        redLayer.backgroundColor = UIColor.red.cgColor
        cameraPreviewLayer?.addSublayer(redLayer)
        
        self.view.layer.insertSublayer(cameraPreviewLayer!, at: 0)
    }
    
    func setupRunSession(){
        captureSession.startRunning()
    }
}
