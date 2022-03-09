//
//  updateFilterClass.swift
//  accura_kyc_flutter
//
//  Created by Amit on 12/08/21.
//

import Foundation
import AccuraOCR
class UpdateFilterClass:NSObject {
    
    var  call = FlutterMethodCall()
    var  result : FlutterResult?
    var accuraCameraWrapper=AccuraCameraWrapper()
    
    
    func  UpdateFilterClass( call: FlutterMethodCall, result: @escaping FlutterResult){
      self.call=call;
      self.result=result;
        let args = call.arguments as? [String:AnyObject]
        var blurPercentage = args!["blurPercentage"] as! String
        var faceBlurPercentage = args!["faceBlurPercentage"] as! String
        var minGlarePercentage = args!["minGlarePercentage"] as! String
        var maxGlarePercentage = args!["maxGlarePercentage"] as! String
        var isCheckPhotoCopy = args!["isCheckPhotoCopy"] as! String
        var isDetectHologram = args!["isDetectHologram"] as! String
        var lightTolerance = args!["lightTolerance"] as! String
        var motionThreshold = args!["motionThreshold"] as! String
        var check_Photo_Copy:Bool;
        var hologram_detection:Bool;

        if(blurPercentage=="null"){
            blurPercentage="60"
        }
        if(faceBlurPercentage=="null"){
            faceBlurPercentage="80"
        }
        if(minGlarePercentage=="null"){
            minGlarePercentage="6"
        }
        if(maxGlarePercentage=="null"){
            maxGlarePercentage="98"
        }
        if(isCheckPhotoCopy=="1"){
            check_Photo_Copy=true
        }
        else{
            check_Photo_Copy=false
        }
        if(isDetectHologram=="0"){
            hologram_detection=false
        }
        else{
            hologram_detection=true
        }
        if(lightTolerance=="null"){
            lightTolerance="10"
        }
        if(motionThreshold=="null"){
            motionThreshold="25"
        }
        
        self.accuraCameraWrapper.setBlurPercentage(Int32(blurPercentage)!)
        self.accuraCameraWrapper.setFaceBlurPercentage(Int32(faceBlurPercentage)!)
        self.accuraCameraWrapper.setGlarePercentage(Int32(minGlarePercentage)!, intMax: Int32(maxGlarePercentage)!)
        self.accuraCameraWrapper.setCheckPhotoCopy(check_Photo_Copy)
        self.accuraCameraWrapper.setHologramDetection(hologram_detection)
        self.accuraCameraWrapper.setLowLightTolerance(Int32(lightTolerance)!)
        self.accuraCameraWrapper.setMotionThreshold(Int32(motionThreshold)!)
       
      }
}
