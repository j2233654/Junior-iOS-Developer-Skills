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
    var avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer()
    
    var url = URL(string: " ")
    enum scanError : Error {
        case noCameraAvailable
        case videoInputInitFail
    }
    
    @IBOutlet weak var resultLabel : UILabel!
    @IBOutlet weak var connect: UIButton!
    var qrCodeFrameView = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Start to scan.
        do{
            try scanQRCode()
        }catch{
            if let error = error as? scanError{
                switch error{
                case .noCameraAvailable:
                    resultLabel.text = "No camera available."
                case .videoInputInitFail:
                    resultLabel.text = "Input init fail."
                }
            }
        }
        
        setupQRCodeFrameView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        avCaptureSession.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //Connect the URL scanned.
    @IBAction func connectBtnPressed(_ sender: Any) {
        performSegue(withIdentifier: "connect", sender: self)
        avCaptureSession.stopRunning()
        connect.isHidden = true
        qrCodeFrameView.frame = CGRect.zero
        resultLabel.text = "No QR Code is detected"
    }
    
    //Bound the QRCode selected with green rectangle.
    func setupQRCodeFrameView(){
        qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
        qrCodeFrameView.layer.borderWidth = 2
        self.view.addSubview(qrCodeFrameView)
        self.view.bringSubview(toFront: qrCodeFrameView)
        self.view.bringSubview(toFront: resultLabel)
        self.view.bringSubview(toFront: connect)
    }
    
    //MetadataObjectsDelegate
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard  let readableCode = metadataObjects.first as? AVMetadataMachineReadableCodeObject else {
            connect.isHidden = true
            qrCodeFrameView.frame = CGRect.zero
            resultLabel.text = "No QR Code is detected"
            return
        }
        //Checking string readability.
        guard let stringValue = readableCode.stringValue else{
            connect.isHidden = true
            resultLabel.text = "No QR Code is detected"
            return
        }
        if readableCode.type == AVMetadataObject.ObjectType.qr{
            //Change the frame of qrCodeFrameView.
            if let qrCodeObject = avCaptureVideoPreviewLayer.transformedMetadataObject(for: readableCode) as? AVMetadataMachineReadableCodeObject {
                qrCodeFrameView.frame = qrCodeObject.bounds
                //Checking validity for URL.
                guard let url = URL(string: stringValue) else{
                    resultLabel.text = "Invalid URL !"
                    connect.isHidden = true
                    return
                }
                //Show URL on the screen.
                resultLabel.text = stringValue
                connect.isHidden = false
                self.url = url
            }
        }
    }
    
    func scanQRCode() throws {
        //Check & set input & output.
        guard let avCaptureDevice = AVCaptureDevice.default(for: AVMediaType.video) else {
            throw scanError.noCameraAvailable
        }
        guard let avCaptureInput = try? AVCaptureDeviceInput(device: avCaptureDevice) else {
            throw scanError.videoInputInitFail
        }
        let avCaptureOutput = AVCaptureMetadataOutput()
        avCaptureOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
        
        //Add input & output into avCaptureSession
        avCaptureSession.addInput(avCaptureInput)
        avCaptureSession.addOutput(avCaptureOutput)
        //Set output metadata object type.
        avCaptureOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
        
        //Put scanner onto screen
        avCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: avCaptureSession)
        avCaptureVideoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        avCaptureVideoPreviewLayer.frame = self.view.bounds
        self.view.layer.addSublayer(avCaptureVideoPreviewLayer)
        avCaptureSession.startRunning()
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "connect"{
            guard let webVC = segue.destination as? WebViewController else{
                assertionFailure("Should not fail.")
                return
            }
            webVC.url = self.url
        }
    }

}
