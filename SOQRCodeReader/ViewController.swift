//
//  ViewController.swift
//  SOQRCodeReader
//
//  Created by Hitesh on 10/14/16.
//  Copyright © 2016 myCompany. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    @IBOutlet weak var viewReader: UIView!
    @IBOutlet weak var btnStartStop: UIButton!
    
    // Create a session object.
    var captureSession = AVCaptureSession()
    
     // Create output object.
    var metaDataOutput = AVCaptureMetadataOutput()
    
    var previewLayer = AVCaptureVideoPreviewLayer()
    var captureDevice : AVCaptureDevice?
    
    var isSessionStart = false

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    
    @IBAction func startStopReading(sender: AnyObject) {
        if isSessionStart == false {
            
            captureSession.sessionPreset = AVCaptureSessionPresetHigh
            
            let devices = AVCaptureDevice.devices()
            
            // Set the captureDevice.
            for device in devices {
                // Make sure this particular device supports video
                if (device.hasMediaType(AVMediaTypeVideo)) {
                    // Finally check the position and confirm we've got the back camera
                    if(device.position == AVCaptureDevicePosition.Back) {
                        captureDevice = device as? AVCaptureDevice
                    }
                }
            }
            
            if captureDevice != nil {
                
                // Create input object.
                let input : AVCaptureDeviceInput = try! AVCaptureDeviceInput(device: captureDevice)
                
                //Session
                if captureSession.canAddOutput(metaDataOutput) && captureSession.canAddInput(input)
                {
                    print("adding out put to session ")
                    // Add input to the session.
                    captureSession.addInput(input)
                    
                    // Add output to the session.
                    captureSession.addOutput(metaDataOutput);
                }
                
                //output
                let metadataQueue = dispatch_queue_create("com.mainqueue.reder", nil);
                
                // Send captured data to the delegate object via a serial queue.
                metaDataOutput.setMetadataObjectsDelegate( self, queue: metadataQueue)
                
                // Set barcode type for which to scan: EAN-13.
                metaDataOutput.metadataObjectTypes = [AVMetadataObjectTypeQRCode,AVMetadataObjectTypeEAN13Code]
                
                
                //// Add previewLayer and have it show the video data.
                previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
                
                let bounds:CGRect = self.viewReader.layer.bounds
                previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
                previewLayer.bounds = bounds
                previewLayer.position = CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds))
                viewReader.layer.addSublayer(previewLayer)
                
                viewReader.hidden = false
                captureSession.startRunning()
                btnStartStop.setTitle("Stop", forState: .Normal)
                print("array \(metaDataOutput.metadataObjectTypes)")
            }
            else{
                btnStartStop.setTitle("Start", forState: .Normal)
                print("no device found")
                self.alert("no device found")
            }
        } else {
            btnStartStop.setTitle("Start", forState: .Normal)
            self.captureSession.stopRunning()
            previewLayer.removeFromSuperlayer()
            
        }
        
        isSessionStart = !isSessionStart
    }
    
    
    //MARK:- AVCaptureMetadataOutputObjectsDelegate
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]?, fromConnection connection: AVCaptureConnection!) {
        print("processing output")
        
        var barCodeObject : AVMetadataObject!
        var strDetected : String!
        
        //All the bar code types defined here
        let barCodeTypes = [AVMetadataObjectTypeFace,
                            AVMetadataObjectTypeQRCode,
                            AVMetadataObjectTypeEAN8Code,
                            AVMetadataObjectTypeUPCECode,
                            AVMetadataObjectTypeAztecCode,
                            AVMetadataObjectTypeEAN13Code,
                            AVMetadataObjectTypeITF14Code,
                            AVMetadataObjectTypeCode39Code,
                            AVMetadataObjectTypeCode93Code,
                            AVMetadataObjectTypePDF417Code,
                            AVMetadataObjectTypeCode128Code,
                            AVMetadataObjectTypeDataMatrixCode,
                            AVMetadataObjectTypeCode39Mod43Code,
                            AVMetadataObjectTypeInterleaved2of5Code]
        
        // The scanner is capable of capturing multiple 2-dimensional barcodes in one scan.
        // Get the object from the metadataObjects array.
        for metadata in metadataObjects! {
            
            for barcodeType in barCodeTypes {
                
                if metadata.type == barcodeType {
                    barCodeObject = self.previewLayer.transformedMetadataObjectForMetadataObject(metadata as! AVMetadataMachineReadableCodeObject)
                    strDetected = (metadata as! AVMetadataMachineReadableCodeObject).stringValue
                    self.captureSession.stopRunning()
                    self.alert(strDetected)
                    break
                }
                
            }
        }
        print(strDetected)
    }
    
    func alert(setMessage: String){
        let alert : UIAlertController = UIAlertController(title: "BarCode", message: "\(setMessage)", preferredStyle: .Alert)
        let actionOK:UIAlertAction = UIAlertAction(title: "OK", style: .Default) { (action) in
            self.captureSession.startRunning()
        }
        alert.addAction(actionOK)
        self.presentViewController(alert, animated: true, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

