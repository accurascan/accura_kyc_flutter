//
//  FaceMatchResultClass.swift
//  accura_kyc_flutter
//
//  Created by Amit on 20/08/21.
//

import Foundation
import AccuraOCR

class FaceMatchResultClass {
    var  call = FlutterMethodCall()
    var  result : FlutterResult?
    var faceRegion: NSFaceRegion?
    
    func  FaceMatchResultClass( call: FlutterMethodCall, result: @escaping FlutterResult){
        self.call=call;
        self.result=result;
        
        getResult();
    }
    func getResult(){
        let args = call.arguments as? [String:AnyObject]
       
        var documentImage = args!["documentImage"]
        var LiveImage = args!["liveImage"]
        let photoImage : UIImage? = Base64ToImage(strBase64: documentImage as! String)
        let FaceImage : UIImage? = Base64ToImage(strBase64: LiveImage as! String)
        let fmInit = EngineWrapper.isEngineInit()
          if !fmInit{
              /*
               * FaceMatch SDK method initiate SDK engine
               */
              EngineWrapper.faceEngineInit()
          }
        let fmValue = EngineWrapper.getEngineInitValue() //get engineWrapper load status
           if fmValue == -20{
               // key not found
           }else if fmValue == -15{
               // License Invalid
           }
        
        self.faceRegion = nil;
        if (photoImage != nil){
            self.faceRegion = EngineWrapper.detectSourceFaces(photoImage) //Identify face in Document scanning image
        }
      
        if (faceRegion != nil)
        {
            /*
             FaceMatch SDK method call to detect Face in back image
             @Params: BackImage, Front Face Image faceRegion
             @Return: Face Image Frame
             */
            
            let face2 = EngineWrapper.detectTargetFaces(FaceImage, feature1: faceRegion?.feature)
            let face11 = faceRegion?.image
            /*
             FaceMatch SDK method call to get FaceMatch Score
             @Params: FrontImage Face, BackImage Face
             @Return: Match Score
             
             */
            
            let fm_Score = EngineWrapper.identify(faceRegion?.feature, featurebuff2: face2?.feature)
            if(fm_Score != 0.0){
            let data = face2?.bound
//                let image = self.resizeImage(image: FaceImage!, targetSize: data!)
            let twoDecimalPlaces = String(format: "%.2f", fm_Score*100)
                //Face Match score convert to float value
                
                self.result!(String(twoDecimalPlaces))
                
                EngineWrapper.faceEngineClose()
            }
        }
    }

    func Base64ToImage(strBase64:String)->UIImage{
        let dataDecoded:NSData = NSData(base64Encoded: strBase64, options: NSData.Base64DecodingOptions(rawValue: 0))!
        let decodedimage:UIImage = UIImage(data: dataDecoded as Data)!
        return decodedimage
        
    }

}
