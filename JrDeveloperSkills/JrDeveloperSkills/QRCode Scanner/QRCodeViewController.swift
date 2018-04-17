//
//  QRCodeViewController.swift
//  JrDeveloperSkills
//
//  Created by 鍾哲允 on 2018/4/17.
//  Copyright © 2018年 Jimmy. All rights reserved.
//

import UIKit
import AVFoundation

class QRCodeViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {

    //Create AVCaptureSession.
    let avCaptureSession = AVCaptureSession()
    
    var stringURL = String()
    
    enum scanError : Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        do{
            try scanQRCode()
        }catch{
            if let error = error as? scanError{
                switch error{
                case .noCameraAvailable:
                    print("No Camera.")
                case .videoInputInitFail:
                    print("Input init fail.")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avCaptureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard  let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            print("No readable code.")
            return
        }
        if readableCode.type == AVMetadataObject.ObjectType.qr{
            avCaptureSession.stopRunning()
            guard let stringValue = readableCode.stringValue else{
                assertionFailure("Should not fail !")
                return
            }
            //Get QRCode link.
            stringURL = stringValue
            performSegue(withIdentifier: "openLink", sender: self)
        }
    }
    
    func scanQRCode() throws {
        
        //Check input & output.
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            throw scanError.noCameraAvailable
        }
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            throw scanError.videoInputInitFail
        }
        let avCaptureOutput = AVCaptureMetadataOutput()
        avCaptureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //Add input & output into acCaptureSession
        avCaptureSession.addInput(avCaptureInput)
        avCaptureSession.addOutput(avCaptureOutput)
        //Set output metadata object type.
        avCaptureOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        //
        let avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(avCaptureVideoPreviewLayer)
        avCaptureSession.startRunning()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "openLink"{
            guard let webVC = segue.destination as? WebViewController else{
                assertionFailure("Should not fail.")
                return
            }
            webVC.stringURL = self.stringURL
        }
    }

}
