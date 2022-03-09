//
//  LIvenessViewController.swift
//  accura_kyc_flutter
//
//  Created by Amit on 19/08/21.
//

import UIKit
import Foundation
import AccuraOCR
import Flutter

class LIvenessViewController: UIViewController, LivenessData, FacematchData {
  
    
    var  call:FlutterMethodCall?
    var isCheckLiveness : Bool?
    var  result : FlutterResult?
    var win:UIWindow?
    var VC: UIViewController?
    override func viewDidLoad() {
        super.viewDidLoad()

        DispatchQueue.main.asyncAfter(deadline: .now()) {
            if(self.isCheckLiveness!){
            self.StartLiveness();
            }
            else{
                self.startFaceMatch();
            }
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    func StartLiveness(){
        
        var liveness = Liveness()

        let args = call?.arguments as? [String:AnyObject]
        var LivenessUrl = args!["LivenessUrl"]
        var backGroundColor = args!["backGroundColor"]
        var closeIconColor = args!["closeIconColor"]
        var feedbackBackGroundColor = args!["feedbackBackGroundColor"]
        var feedbackTextColor = args!["feedbackTextColor"]
        var feedbackTextSize = args!["feedbackTextSize"]
        var feedBackframeMessage = args!["feedBackframeMessage"]
        var feedBackAwayMessage = args!["feedBackAwayMessage"]
        var feedBackOpenEyesMessage = args!["feedBackOpenEyesMessage"]
        var feedBackCloserMessage = args!["feedBackCloserMessage"]
        var feedBackCenterMessage = args!["feedBackCenterMessage"]
        var feedBackMultipleFaceMessage = args!["feedBackMultipleFaceMessage"]
         var feedBackHeadStraightMessage = args!["feedBackHeadStraightMessage"]
        var feedBackBlurFaceMessage = args!["feedBackBlurFaceMessage"]
        var feedBackGlareFaceMessage = args!["feedBackGlareFaceMessage"]
       
        var setBlurPercentage = args!["setBlurPercentage"]
        var setminGlarePercentage = args!["setminGlarePercentage"]
        var maxGlarePercentage = args!["maxGlarePercentage"]
        var ServerTrustWIthSSLPinning = args!["ServerTrustWIthSSLPinning"]

        if let data = LivenessUrl as? String{
            liveness.setLivenessURL(data )
            print("LivenessUrl:- ", data)
            
        }
        if let data = backGroundColor as? String{
            liveness.setBackGroundColor(data )
        }
        if let data = closeIconColor as? String{
            liveness.setCloseIconColor(data )
        }
        if let data = feedbackBackGroundColor as? String{
            liveness.setFeedbackBackGroundColor(data )
        }
        if let data = feedbackTextColor as? String{
            liveness.setFeedbackTextColor(data )
        }

        if let data = feedbackTextSize as? String{
            liveness.setFeedbackTextSize(Float(data) ?? 21)
        }

        if let data = feedBackframeMessage as? String{
            liveness.setFeedBackframeMessage(data )
        }
        if let data = feedBackAwayMessage as? String{
            liveness.setFeedBackAwayMessage(data )
        }
        if let data = feedBackOpenEyesMessage as? String{
            liveness.setFeedBackOpenEyesMessage(data )
        }
        if let data = feedBackCloserMessage as? String{
            liveness.setFeedBackCloserMessage(data)
        }
        if let data = feedBackCenterMessage as? String{
            liveness.setFeedBackCenterMessage(data )
        }
        if let data = feedBackMultipleFaceMessage as? String{
            liveness.setFeedbackMultipleFaceMessage(data )
        }
        if let data = feedBackHeadStraightMessage as? String{
            liveness.setFeedBackFaceSteadymessage(data )
        }
        if let data = feedBackBlurFaceMessage as? String{
            liveness.setFeedBackBlurFaceMessage(data )
        }
        if let data = feedBackGlareFaceMessage as? String{
            liveness.setFeedBackGlareFaceMessage(data )
        }
        if let data = setBlurPercentage as? String{
            liveness.setBlurPercentage(Int32(data) ?? 80)
        }
        if let data = setminGlarePercentage as? String ,let data2 = maxGlarePercentage as? String{
            liveness.setGlarePercentage(Int32(data) ?? -1,Int32(data2) ?? -1)
        }
        if let data = ServerTrustWIthSSLPinning as? String{
            if(data=="1"){
                liveness.evaluateServerTrustWIthSSLPinning(true)
            }
            else{
                liveness.evaluateServerTrustWIthSSLPinning(false)
            }
        }
        liveness.setLiveness(self)
        
    }
    func startFaceMatch(){
        
        var facematch = Facematch()

        let args = call?.arguments as? [String:AnyObject]
       
        var backGroundColor = args!["backGroundColor"]
        var closeIconColor = args!["closeIconColor"]
        var feedbackBackGroundColor = args!["feedbackBackGroundColor"]
        var feedbackTextColor = args!["feedbackTextColor"]
        var feedbackTextSize = args!["feedbackTextSize"]
        var feedBackframeMessage = args!["feedBackframeMessage"]
        var feedBackAwayMessage = args!["feedBackAwayMessage"]
        var feedBackOpenEyesMessage = args!["feedBackOpenEyesMessage"]
        var feedBackCloserMessage = args!["feedBackCloserMessage"]
        var feedBackCenterMessage = args!["feedBackCenterMessage"]
        var feedBackMultipleFaceMessage = args!["feedBackMultipleFaceMessage"]
         var feedBackHeadStraightMessage = args!["feedBackHeadStraightMessage"]
        var feedBackBlurFaceMessage = args!["feedBackBlurFaceMessage"]
        var feedBackGlareFaceMessage = args!["feedBackGlareFaceMessage"]
       
        var setBlurPercentage = args!["setBlurPercentage"]
        var setminGlarePercentage = args!["setminGlarePercentage"]
        var maxGlarePercentage = args!["maxGlarePercentage"]
       


      
        if let data = backGroundColor as? String{
            facematch.setBackGroundColor(data )
        }
        if let data = closeIconColor as? String{
            facematch.setCloseIconColor(data )
        }
        if let data = feedbackBackGroundColor as? String{
            facematch.setFeedbackBackGroundColor(data )
        }
        if let data = feedbackTextColor as? String{
            facematch.setFeedbackTextColor(data )
        }

        if let data = feedbackTextSize as? String{
            facematch.setFeedbackTextSize(Float(data) ?? 21)
        }

        if let data = feedBackframeMessage as? String{
            facematch.setFeedBackframeMessage(data )
        }
        if let data = feedBackAwayMessage as? String{
            facematch.setFeedBackAwayMessage(data )
        }
        if let data = feedBackOpenEyesMessage as? String{
            facematch.setFeedBackOpenEyesMessage(data )
        }
        if let data = feedBackCloserMessage as? String{
            facematch.setFeedBackCloserMessage(data)
        }
        if let data = feedBackCenterMessage as? String{
            facematch.setFeedBackCenterMessage(data )
        }
        if let data = feedBackMultipleFaceMessage as? String{
            facematch.setFeedbackMultipleFaceMessage(data )
        }
        if let data = feedBackHeadStraightMessage as? String{
            facematch.setFeedBackFaceSteadymessage(data )
        }
        if let data = feedBackBlurFaceMessage as? String{
            facematch.setFeedBackBlurFaceMessage(data )
        }
        if let data = feedBackGlareFaceMessage as? String{
            facematch.setFeedBackGlareFaceMessage(data )
        }
        if let data = setBlurPercentage as? String{
            facematch.setBlurPercentage(Int32(data) ?? 80)
        }
        if let data = setminGlarePercentage as? String ,let data2 = maxGlarePercentage as? String{
            facematch.setGlarePercentage(Int32(data) ?? -1,Int32(data2) ?? -1)
        }
       
        facematch.setFacematch(self)
        
    }
    func facematchData(_ FaceImage: UIImage!) {
        var mainObject = [String:AnyObject]()
        if(FaceImage != nil){
            mainObject["imagePath"] = convertImageToBase64String(img: FaceImage) as AnyObject
        }
        mainObject["ErrorMessage"] = "" as AnyObject
        self.result!(json(from:mainObject));
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
    }
    
    func facematchViewDisappear() {
       // close()
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
        var mainObject = [String:AnyObject]()
        mainObject["close"] = "1" as AnyObject
            self.result!(self.json(from:mainObject));
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
        }
        
    }
    func close() {
        self.win?.rootViewController = self.VC
    }
    
    func livenessViewDisappear() {
        //close()
    
        DispatchQueue.main.asyncAfter(deadline: .now()+0.2) {
                var mainObject = [String:AnyObject]()
            mainObject["close"] = "1" as AnyObject
            self.result!(self.json(from:mainObject));
            UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
        }
    
    }
//    func livenessData(_ stLivenessValue: String!, livenessImage: UIImage!, status: Bool) {
//
//        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
//    }
    func livenessData(_ stLivenessValue: String!, livenessImage: UIImage!, status: Bool) {
        var mainObject = [String:AnyObject]()
        if(status){
            mainObject["Status"] = "1" as AnyObject
            mainObject["livenessStatus"] = true as AnyObject
        }
        else{
            mainObject["Status"] = "0" as AnyObject
            mainObject["livenessStatus"] = false as AnyObject
        }
        if(livenessImage != nil){
            mainObject["imagePath"] = convertImageToBase64String(img: livenessImage) as AnyObject
        }
        mainObject["livenessScore"] = stLivenessValue as AnyObject
      
        mainObject["ErrorMessage"] = "" as AnyObject
        self.result!(json(from:mainObject));
        UIApplication.shared.keyWindow?.rootViewController?.dismiss(animated: true)
    }
    
    func convertImageToBase64String (img: UIImage) -> String {
        let imageData:NSData = img.jpegData(compressionQuality: 0.50)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        return imgString
    }

    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }

}
