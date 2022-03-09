//
//  FlutterUnityViewFactory.swift
//  accura_kyc_flutter
//
//  Created by Amit on 12/08/21.
//

import Foundation
import AccuraOCR
import Flutter

public class FlutterUnityViewFactory: NSObject, FlutterPlatformViewFactory{
    var binaryMessenger: FlutterBinaryMessenger!
    
    @objc public init(binaryMessenger: FlutterBinaryMessenger) {
        self.binaryMessenger = binaryMessenger
        super.init()
    }
    
    
    
    public func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        return SwiftScanPreivew(frame:frame, binaryMessenger: binaryMessenger,args: args);
    }
    
}

public class SwiftScanPreivew:NSObject, FlutterPlatformView {
    var cameraViewController: CameraViewController;
    public init(frame: CGRect,binaryMessenger: FlutterBinaryMessenger,args:Any?) {
        cameraViewController = CameraViewController(frame: frame, binaryMessenger:binaryMessenger, args: args)
    }

    public func view() -> UIView {
        return cameraViewController.imageView;
    }
}

class CameraViewController: UIViewController{
    
    //MARK:- Variable
    var _channel: FlutterMethodChannel!;
    var _messagingChannel: FlutterBasicMessageChannel!;
    var _layout_size_channel: FlutterBasicMessageChannel!;
    var scansound_channel: FlutterBasicMessageChannel!;
    var faceImage: UIImage?
    var camaraImage: UIImage?
    var faceRegion: NSFaceRegion?
    var imageView: UIImageView!
    
    var videoCameraWrapper: AccuraCameraWrapper? = nil
    
    var shareScanningListing: NSMutableDictionary = [:]
    
    var dictResult : [String : String] = [String : String]()
    var imgViewCard : UIImage?
    var isCheckCard : Bool = false
    
    var isCheckcardBack : Bool = false
    var isCheckCardBackFrint : Bool = false
    
//    var isBack : Bool?
    var isFront : Bool?
    
    var imgViewCardFront : UIImage?
    
    var dictFrontResult : [String : String] = [String : String]()
    var dictBackResult : [String : String] = [String : String]()
    
    var dictBackResult11 : [[String : String]] = [[String : String]]()
    
    var isflipanimation : Bool?
    
    var imgPhoto : UIImage?
    var isCheckFirstTime : Bool = false
    var setImage : Bool?
    var _imageView1: UIImageView?
    var dictScanningData: [String : String] = [String : String]()
    
    var face2 : NSFaceRegion?
    var imageFace: UIImage?
    var card_type:String=""
    var recogType:String=""
    var isBothSideAvailable:Bool=false
    let mutableArray: NSMutableArray = []
    let keyArr: NSMutableArray = []
    let valueArr: NSMutableArray = []
    var scanSound:Bool=false
    var cardSide:String=""
    var isBack:Bool=false
    init(frame: CGRect, binaryMessenger: FlutterBinaryMessenger,args:Any?) {
        _channel = FlutterMethodChannel(name: "scan_preview", binaryMessenger: binaryMessenger);
        _messagingChannel = FlutterBasicMessageChannel(name: "scan_preview_message", binaryMessenger: binaryMessenger);
        _layout_size_channel = FlutterBasicMessageChannel(name: "layout_width_hight", binaryMessenger: binaryMessenger);

        scansound_channel = FlutterBasicMessageChannel(name: "playScanSound", binaryMessenger: binaryMessenger);
        //        super.init(nibName: nil, bundle: nil);
        super.init(nibName: nil, bundle: nil)
        
        methodCall(binaryMessenger: binaryMessenger)
        
        imageView = UIImageView(frame: frame)
        imageView.contentMode = .scaleAspectFill
        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: view.frame.size.height)
        self.imageView.translatesAutoresizingMaskIntoConstraints = true
        let constrsintHeightWidth = NSLayoutConstraint(item: self.imageView!,
                                            attribute: .height,
                                     relatedBy: .equal,
                                     toItem: self.imageView!,
                                     attribute: .width,
                                     multiplier: 720/1280,
                                     constant: 0)
        constrsintHeightWidth.priority = UILayoutPriority(rawValue: 750)
        constrsintHeightWidth.isActive = true
        self.imageView.addConstraint(constrsintHeightWidth)
//        let topConstrsint = NSLayoutConstraint(item: self.imageView!, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1, constant: 0)
//        topConstrsint.isActive = true
//        let bottomConstraint = NSLayoutConstraint(item: self.imageView!, attribute: .bottom, relatedBy: .equal, toItem: self.view, attribute: .bottom, multiplier: 1, constant: 0)
//        bottomConstraint.isActive = true
//        let leading = NSLayoutConstraint(item: self.imageView!, attribute: .leading, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .leading, multiplier: 1, constant: 0)
//        leading.isActive = true
//        let trailing = NSLayoutConstraint(item: self.imageView!, attribute: .trailing, relatedBy: .lessThanOrEqual, toItem: self.view, attribute: .trailing, multiplier: 1, constant: 0)
//        trailing.isActive =  true
//        self.imageView.addConstraints([constrsintHeightWidth, topConstrsint, bottomConstraint, leading, trailing])
        isCheckFirstTime = false
        setImage = true
        
        isFront = true
    }
    func methodCall(binaryMessenger: FlutterBinaryMessenger){
        
        _channel.setMethodCallHandler { [self] (call: FlutterMethodCall, result: @escaping FlutterResult) in
            
            switch call.method{
            case "scan#startCamera":
                // if self.isCheckFirstTime{
                self.startCamera(binaryMessenger: binaryMessenger, call: call)
                //}
                break;
            case "scan#stopCamera":
                self.stopCamera()
                break;
                
            case "FlipCamera":
                self.videoCameraWrapper!.switchCamera()
                
                break;
                
            case "printLogFile":
                let args = call.arguments as? [String:AnyObject]
                var value = args!["value"] as! String
                var isShowLogs:Bool=true
                
                videoCameraWrapper!.showLogFile(true)
                break;
            case "setcamerafacing":
                let args = call.arguments as? [String:AnyObject]
                var value = args!["facing"] as! String
                if(value == "1"){
                    videoCameraWrapper!.setCameraFacing(.CAMERA_FACING_FRONT)
                }
                else{
                    videoCameraWrapper!.setCameraFacing(.CAMERA_FACING_BACK)
                }
                break;
            case "setCardSide":
                let args = call.arguments as? [String:AnyObject]
                cardSide = args!["cardside"] as! String
                break;
                
                
            case "scan#restartCamera":
          
                self.startCamera(binaryMessenger: binaryMessenger, call: call)
                break;
                
            case "scan#restartCameraPreview":
                videoCameraWrapper?.startCameraPreview()
                break;
                
            case "scan#stopCameraPreview":
                videoCameraWrapper?.stopCameraPreview()
                break;
                
            case "setBarcodeType":
            let args = call.arguments as? [String:AnyObject]
                let barcodeType:String = args!["barcode"] as! String
                switch (barcodeType) {
                case "0":
                    videoCameraWrapper?.change(.all)
                    break;
                case "1":
                    videoCameraWrapper?.change(.aztec)
                    break;
                case "2":
                    videoCameraWrapper?.change(.codabar)
                    break;
                case "3":
                    videoCameraWrapper?.change(.code39)
                    break;
                case "4":
                    videoCameraWrapper?.change(.code93)
                    break;
                case "5":
                    videoCameraWrapper?.change(.code128)
                    break;
                case "6":
                    videoCameraWrapper?.change(.dataMatrix)
                    break;
                case "7":
                    videoCameraWrapper?.change(.ean8)
                    break;
                case "8":
                    videoCameraWrapper?.change(.ean13)
                    break;
                case "9":
                    videoCameraWrapper?.change(.itf)
                    break;
                case "10":
                    videoCameraWrapper?.change(.pdf417)
                    break;
                case "11":
                    videoCameraWrapper?.change(.qrcode)
                    break;
                case "12":
                    videoCameraWrapper?.change(.upca)
                    break;
                case "13":
                    videoCameraWrapper?.change(.upce)
                    break;
                default:
                    videoCameraWrapper?.change(.all)
                    break;
                }
                
                break;
            default:
                break;
            }
            videoCameraWrapper?.startCameraPreview()
            
        };
    }
    
    func clearTempFolder(filename: String?) {
        let fileManager = FileManager.default
        let tempFolderPath = NSTemporaryDirectory()
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: tempFolderPath)
            for filePath in filePaths {
                print(filePath)
                let fileName = String(format: "%@", (filePath.components(separatedBy: "/").last!))
                if fileName != filename{
                    try fileManager.removeItem(atPath: tempFolderPath + filePath)
                }
            }
        } catch {
            print("Could not clear temp folder: \(error)")
        }
    }
    
    
    func compressimage(with image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    
    
    required init(coder: NSCoder) {
        super.init(coder: coder)!
    }
    
    
    
    func managePermission(call: FlutterMethodCall){
        AVCaptureDevice.requestAccess(for: .video) { granted in
            if granted {
                self.isCheckFirstTime = true
                DispatchQueue.main.async {
                    self.imageView.setNeedsLayout()
                    self.imageView.layoutSubviews()
                }
                self.isFront = true
                
                self.setOCRData(call: call)
                
                self.ChangedOrientation()
                
                self.videoCameraWrapper?.startCamera()
                
                let shortTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapToFocus(_:)))
                shortTap.numberOfTapsRequired = 1
                shortTap.numberOfTouchesRequired = 1
                
                
                //   self.startCamera();
            } else {
                print("Not granted access")
            }
        }
    }
    
    func startCamera(binaryMessenger: FlutterBinaryMessenger,call: FlutterMethodCall){
        
        // self.isCheckFirstTime = false
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        if status == .authorized {
            self.isCheckFirstTime = true
            DispatchQueue.main.async {
                self.imageView.setNeedsLayout()
                self.imageView.layoutSubviews()
            }
            isFront = true
            
            setOCRData(call: call)
            
            ChangedOrientation()
            
            videoCameraWrapper?.startCamera()
            
            let shortTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapToFocus(_:)))
            shortTap.numberOfTapsRequired = 1
            shortTap.numberOfTouchesRequired = 1
        } else if status == .notDetermined  {
            managePermission(call: call);
        }
    }
    
    func stopCamera(){
        videoCameraWrapper?.stopCamera()
        videoCameraWrapper = nil
//        imageView.image = nil
    }
    
    
    func setOCRData(call: FlutterMethodCall){
        let args = call.arguments as? [String:AnyObject]
        
        recogType = args!["recogType"] as! String
        var card_id = args!["card_id"] as! String
        var country_id = args!["country_id"] as! String
        var mrzDocumentType = args!["mrzDocumentType"] as! String
        
        if(recogType=="BARCODE"||recogType=="1"){
            var isBarcodeEnable:Bool=true
            if(recogType=="1"){
                isBarcodeEnable=false
            }
            else{
                isBarcodeEnable=true
            }
            
            videoCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: imageView, andLabelMsg: nil, andurl: 0, isBarcodeEnable: isBarcodeEnable, countryID:0, setBarcodeType: .all)
        } else if(recogType=="BANKCARD"){
            let isScanOcr:Bool=false

            videoCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ imageView, andLabelMsg:  nil, andurl:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId : Int32(card_id)!, countryID: Int32(country_id)!, isScanOCR:isScanOcr,  andcardName:"0", andcardType: 3, andMRZDocType:Int32(mrzDocumentType)!)
        } else if(recogType=="2"){
            let isScanOcr:Bool=false

            videoCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ imageView, andLabelMsg:  nil, andurl:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId : Int32(card_id)!, countryID: Int32(country_id)!, isScanOCR:isScanOcr,  andcardName:"0", andcardType: 2, andMRZDocType:Int32(mrzDocumentType)!)
        } else{
            var isScanOcr:Bool=false
            
            if(recogType=="0"){
                isScanOcr=true
                
            }
            else{
                isScanOcr=false
            }
            
            
            videoCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ imageView, andLabelMsg:  nil, andurl:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId : Int32(card_id)!, countryID: Int32(country_id)!, isScanOCR:isScanOcr,  andcardName:"0", andcardType: 0, andMRZDocType:Int32(mrzDocumentType)!)
        }
        
        
        dictBackResult.removeAll()
        dictFrontResult.removeAll()
        dictResult.removeAll()
        
        isCheckCard = false
        isCheckcardBack = false
        isCheckCardBackFrint = false
        isflipanimation = false
        
        let filepathAlt = Bundle.main.path(forResource: "haarcascade_frontalface_alt", ofType: "xml")
        
        
        imageView.setImageToCenter()
    }
    
    
    
    @objc private func ChangedOrientation() {
        //        var width: CGFloat = 0.0
        //        var height: CGFloat = 0.0
        //
        //        width = UIScreen.main.bounds.size.width
        //        height = UIScreen.main.bounds.size.height * 0.30
        //
        //
        ////        videoCameraWrapper?.changedOrintation(width, height: height)
        //
        //        DispatchQueue.main.async {
        //            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
        //                self.view.layoutIfNeeded()
        //            }) { _ in
        //            }
        //        }
        let data = NSMutableDictionary()
        if(recogType == "1" || recogType == "BARCODE"){
            let statusBarRect = UIApplication.shared.statusBarFrame
            let window = UIApplication.shared.windows.first
            let bottomPadding = window!.safeAreaInsets.bottom
            let  topPadding = window!.safeAreaInsets.top
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            let orientastion = UIApplication.shared.statusBarOrientation
            if(orientastion ==  UIInterfaceOrientation.portrait) {
                width = UIScreen.main.bounds.size.width * 0.95
                
                height  = (UIScreen.main.bounds.size.height - (bottomPadding + topPadding + statusBarRect.height)) * 0.35
                
            } else {
                
                
                height = UIScreen.main.bounds.size.height * 0.62
                width = UIScreen.main.bounds.size.width * 0.51
            }
            
            
            if(card_type == "2") {
                data["Height"] = "\(height/2)"
            } else {
                data["Height"] = "\(height)"
            }
            
            data["Width"] = "\(width)"
            var dataArray = [NSMutableDictionary]()
            dataArray.append(data)
            _layout_size_channel.sendMessage(dataArray);
        }
    }
    
    @objc func handleTapToFocus(_ tapGesture: UITapGestureRecognizer?) {
        let acd = AVCaptureDevice.default(for: .video)
        if tapGesture!.state == .ended {
            let thisFocusPoint = tapGesture!.location(in: imageView)
            let focus_x = Double(thisFocusPoint.x / imageView.frame.size.width)
            let focus_y = Double(thisFocusPoint.y / imageView.frame.size.height)
            if acd?.isFocusModeSupported(.autoFocus) ?? false && acd?.isFocusPointOfInterestSupported != nil {
                do {
                    try acd?.lockForConfiguration()
                    
                    if try acd?.lockForConfiguration() != nil {
                        acd?.focusMode = .autoFocus
                        acd?.focusPointOfInterest = CGPoint(x: CGFloat(focus_x), y: CGFloat(focus_y))
                        acd?.unlockForConfiguration()
                    }
                } catch {
                }
            }
        }
        
    }
    
    
}

extension CameraViewController: VideoCameraWrapperDelegate {
    //MARK:- VideoCameraWepper Delegate
    func onUpdateLayout(_ frameSize: CGSize, _ borderRatio: Float) {
        let data = NSMutableDictionary()
        if(recogType != "0"){
            let statusBarRect = UIApplication.shared.statusBarFrame
            let window = UIApplication.shared.windows.first
            let bottomPadding = window!.safeAreaInsets.bottom
            let  topPadding = window!.safeAreaInsets.top
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            let orientastion = UIApplication.shared.statusBarOrientation
            if(orientastion ==  UIInterfaceOrientation.portrait) {
                width = UIScreen.main.bounds.size.width * 0.95
                
                height  = (UIScreen.main.bounds.size.height - (bottomPadding + topPadding + statusBarRect.height)) * 0.35
                
            } else {
                
                
                height = UIScreen.main.bounds.size.height * 0.62
                width = UIScreen.main.bounds.size.width * 0.51
            }
            
            
            if(card_type == "2") {
                data["Height"] = "\(height/2)"
            } else {
                data["Height"] = "\(height)"
            }
            
            data["Width"] = "\(width)"
        }
        else{
            
            
            //            if(card_type=="2"){
            //                data["Height"] = "\(frameSize.height/2)"
            //            }
            //            else{
            //                data["Height"] = "\(frameSize.height)"
            //            }
            //            data["Width"] = "\(frameSize.width)"
            //                  print("\(frameSize.height)")
            
            var width: CGFloat = 0.0
            var height: CGFloat = 0.0
            
            if(card_type != "2" && card_type != "3") {
                let orientastion = UIApplication.shared.statusBarOrientation
                if(orientastion ==  UIInterfaceOrientation.portrait) {
                    width = frameSize.width
                    height  = frameSize.height
                    
                } else {
                    
                    
                    height = (((UIScreen.main.bounds.size.height - 100) * 5) / 5.6)
                    width = (height / CGFloat(borderRatio))
                    print("boreder ratio :- ", borderRatio)
                }
                print("layer", width)
                //                            DispatchQueue.main.async {
                
                data["Height"] = "\(height)"
                data["Width"] = "\(width)"
                //                            }
                
            }
            
            
        }
        var dataArray = [NSMutableDictionary]()
        dataArray.append(data)
        _layout_size_channel.sendMessage(dataArray);
        
        
    }
    
    
    func processedImage(_ image: UIImage!) {
        imageView.image = image
    }
 
    func recognizeFailed(_ message: String!) {
        
    }
    
    func screenSound() {
//        if(scanSound){
//        AudioServicesPlaySystemSound(SystemSoundID(1315))
//        }
        self.scansound_channel.sendMessage("Play");
    }
    func recognizeSucceed(_ scanedInfo: NSMutableDictionary!, recType: RecType, bRecDone: Bool, bFaceReplace: Bool, bMrzFirst: Bool, photoImage: UIImage!, docFrontImage: UIImage!, docbackImage: UIImage!) {
        if(bMrzFirst){
            
           
            var mainObject = [String:AnyObject]()
            mainObject["MRZ_Data"] = setMrzData(scanedInfo:scanedInfo) as AnyObject
            if(docFrontImage != nil){
                mainObject["front_Image"] = convertImageToBase64String(img: docFrontImage) as AnyObject
            }
            if(docbackImage != nil){
                mainObject["back_Image"] = convertImageToBase64String(img: docbackImage) as AnyObject
            }
            if(photoImage != nil){
                mainObject["Face_Image"] = convertImageToBase64String(img: photoImage) as AnyObject
            }
            
            var main_OCR_Array = [[String:AnyObject]]()
            main_OCR_Array.append(mainObject)
            var object = [String:AnyObject]()
            object["ocr_data"] = main_OCR_Array as AnyObject
            var list = [[String:String]]()
            var prodHashMap = [String:String]()
            prodHashMap["ocr_data"] =  arrayToString(from: object)! as String
            list.append(prodHashMap)
            
            _messagingChannel.sendMessage(list);
            
        }
        
    }
    
    func setMrzData(scanedInfo:NSMutableDictionary)->[[String:AnyObject]]{
        var mrzArray = [[String:AnyObject]]()
      

  
        if let strline: String =  scanedInfo["lines"] as? String {
            
            if(strline != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "MRZ" as AnyObject
                mrzObject["MRZ_data"] = strline as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strpassportType: String =  scanedInfo["passportType"] as? String  {
            if(strpassportType != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Document Type" as AnyObject
                mrzObject["MRZ_data"] = strpassportType as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strgivenNames: String =  scanedInfo["givenNames"] as? String  {
            if(strgivenNames != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "First Name" as AnyObject
                mrzObject["MRZ_data"] = strgivenNames as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strsurName: String = scanedInfo["surName"] as? String {
            if(strsurName != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Last Name" as AnyObject
                mrzObject["MRZ_data"] = strsurName as AnyObject
                
                mrzArray.append(mrzObject);
            }
            
        }
        if let strpassportNumber: String = scanedInfo["passportNumber"] as? String   {
            if(strpassportNumber != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Document No." as AnyObject
                mrzObject["MRZ_data"] = strpassportNumber as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let strpassportNumberChecksum: String = scanedInfo["passportNumberChecksum"] as? String {
            if(strpassportNumberChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Document check No." as AnyObject
                mrzObject["MRZ_data"] = strpassportNumberChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let stcorrectPassportChecksum: String = scanedInfo["correctPassportChecksum"] as? String{
            if(stcorrectPassportChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Correct Document check No." as AnyObject
                mrzObject["MRZ_data"] = stcorrectPassportChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strcountry: String =  scanedInfo["country"] as? String {
            if(strcountry != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Country" as AnyObject
                mrzObject["MRZ_data"] = strcountry as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        
        
        if let strnationality: String =  scanedInfo["nationality"] as? String  {
            if(strnationality != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Nationality" as AnyObject
                mrzObject["MRZ_data"] = strnationality as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strsex: String =  scanedInfo["sex"] as? String {
            if(strsex != ""){
                var stSex:String=""
                if strsex == "F" {
                    stSex = "FEMALE";
                }else if strsex == "M" {
                    stSex = "MALE";
                }
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Sex" as AnyObject
                mrzObject["MRZ_data"] = stSex as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let strbirth: String = scanedInfo["birth"] as? String  {
            if(strbirth != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Date of Birth" as AnyObject
                mrzObject["MRZ_data"] = strbirth as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strbirthChecksum: String = scanedInfo["BirthChecksum"] as? String{
            if(strbirthChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Birth Check No." as AnyObject
                mrzObject["MRZ_data"] = strbirthChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let stcorrectBirthChecksum: String = scanedInfo["correctBirthChecksum"] as? String{
            if(stcorrectBirthChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Correct Birth Check No." as AnyObject
                mrzObject["MRZ_data"] = stcorrectBirthChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let strexpirationDate: String = scanedInfo["expirationDate"] as? String {
            if(strexpirationDate != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Date of Expiry" as AnyObject
                mrzObject["MRZ_data"] = strexpirationDate as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let strexpirationDateChecksum: String = scanedInfo["expirationDateChecksum"] as? String  {
            if(strexpirationDateChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Expiration Check No." as AnyObject
                mrzObject["MRZ_data"] = strexpirationDateChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let stcorrectExpirationChecksum: String = scanedInfo["correctExpirationChecksum"] as? String{
            if(stcorrectExpirationChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Correct Expiration Check No." as AnyObject
                mrzObject["MRZ_data"] = stcorrectExpirationChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strpersonalNumber: String = scanedInfo["personalNumber"] as? String{
            if(strpersonalNumber != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Other ID" as AnyObject
                mrzObject["MRZ_data"] = strpersonalNumber as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strpersonalNumberChecksum: String = scanedInfo["personalNumberChecksum"] as? String {
            if(strpersonalNumberChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Other ID Check" as AnyObject
                mrzObject["MRZ_data"] = strpersonalNumberChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        if let strpersonalNumber2: String = scanedInfo["personalNumber2"] as? String{
            if(strpersonalNumber2 != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Other ID2" as AnyObject
                mrzObject["MRZ_data"] = strpersonalNumber2 as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        
        if let strsecondRowChecksum: String = scanedInfo["secondRowChecksum"] as? String {
            if(strsecondRowChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Second Row Check No." as AnyObject
                mrzObject["MRZ_data"] = strsecondRowChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let stcorrectSecondrowChecksum: String = scanedInfo["correctSecondrowChecksum"] as? String{
            if(stcorrectSecondrowChecksum != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Correct Second Row Check No." as AnyObject
                mrzObject["MRZ_data"] = stcorrectSecondrowChecksum as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        
        
        if let strissuedate: String = scanedInfo["issuedate"] as? String {
            if(strissuedate != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Date Of Issue" as AnyObject
                mrzObject["MRZ_data"] = strissuedate as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        
        if let strdepartmentNumber: String = scanedInfo["departmentNumber"] as? String {
            if(strdepartmentNumber != ""){
                var mrzObject = [String:AnyObject]()
                mrzObject["MRZ_key"] = "Department No." as AnyObject
                mrzObject["MRZ_data"] = strdepartmentNumber as AnyObject
                
                mrzArray.append(mrzObject);
            }
        }
        return mrzArray;
        
    }
    
    func isBothSideAvailable(_ isBothAvailable: Bool) {
        isBack = false;
        isBothSideAvailable=isBothAvailable
        //CARDSIDE==0==>BACKSIDE
        //CARDSIDE==1==>FRONTSIDE
        //CARDSIDE==2==>FIRST_FRONT_AFTER_BACK
        //CARDSIDE==3==>FIRST_BACK_AFTER_FRONT
        if(cardSide == "0" || cardSide == "3"){
            if(isBothAvailable){
                videoCameraWrapper?.cardSide(.BACK_CARD_SCAN)
            }
        }
        else if(cardSide == "1" || cardSide == "2"){
            videoCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
        }
    }
    func passOcrDataToFlutter(resultmodel : ResultModel){
        var results:[String: AnyObject] = [:]
        var frontData:[String: AnyObject] = [:]
        var backData:[String: AnyObject] = [:]
        var mrzData:[String: AnyObject] = [:]
        var mrzArray = [[String:AnyObject]]()
        var frontArray = [[String:AnyObject]]()
        var backArray = [[String:AnyObject]]()
       if (resultmodel.faceImage.size.width) > 0 && (resultmodel.faceImage.size.height) > 0{
            results["Face_Image"] = self.convertImageToBase64String(img: resultmodel.faceImage) as AnyObject
        }
        if (resultmodel.frontSideImage.size.width) > 0 && (resultmodel.frontSideImage.size.height) > 0{

        results["front_Image"] = convertImageToBase64String(img: resultmodel.frontSideImage) as AnyObject
        }
        
        if (resultmodel.backSideImage.size.width) > 0 && (resultmodel.backSideImage.size.height) > 0{
        results["back_Image"] = convertImageToBase64String(img: resultmodel.backSideImage) as AnyObject
        }
        
        let dictFaceDataFront = resultmodel.ocrFaceFrontData
        for data in dictFaceDataFront {
            if let k = data.key as? String {
                var front_Data:[String: AnyObject] = [:]
                if k == "Signature" {
                    
                    front_Data["scanned_type"] = 2 as AnyObject
                    front_Data["front_key"] = "signature" as AnyObject
                    front_Data["front_keydata"] = data.value as AnyObject
                    frontArray.append(front_Data)
                    
                } else {
                    front_Data["scanned_type"] = 1 as AnyObject
                    front_Data["front_key"] = k as AnyObject
                    front_Data["front_keydata"] = data.value as AnyObject
                    frontArray.append(front_Data)
                }
            }
            
        }
        
        let dictFaceDataBack = resultmodel.ocrFaceBackData
        for data in dictFaceDataBack {
            if let k = data.key as? String {
                var back_Data:[String: AnyObject] = [:]
                if k == "Signature" {
                    back_Data["scanned_type"]=2 as AnyObject
                    back_Data["back_key"] = "signature" as AnyObject
                    back_Data["back_keydata"] = data.value as AnyObject
                    backArray.append(back_Data)
                    
                    
                } else {
                    back_Data["scanned_type"] = 1 as AnyObject
                    back_Data["back_key"] = k as AnyObject
                    back_Data["back_keydata"] = data.value as AnyObject
                    backArray.append(back_Data)
                }
            }
            
        }
        
        let dictSecuretyData = resultmodel.ocrSecurityData
        for data in dictSecuretyData {
            frontData[data.key as! String] = data.value as AnyObject
        }
        
        //        self.dictOCRTypeData = resultmodel.ocrTypeData
        //        for data in dictOCRTypeData {
        //            frontData[data.key as! String] = data.value as? String ?? data.value as? Int ?? ""
        //        }
        let arrFrontResultKey = resultmodel.arrayocrFrontSideDataKey as! [String]
        let arrFrontResultValue = resultmodel.arrayocrFrontSideDataValue as! [String]
        for i in arrFrontResultKey.indices {
            if arrFrontResultKey[i] != "MRZ" {
                var front_Data:[String: AnyObject] = [:]
                
                front_Data["scanned_type"] = 1 as AnyObject
                front_Data["front_key"] = arrFrontResultKey[i] as AnyObject
                front_Data["front_keydata"] = arrFrontResultValue[i] as AnyObject
                frontArray.append(front_Data)
            } else {
                let dictScanningMRZData: NSMutableDictionary = resultmodel.shareScanningMRZListing
                for data in dictScanningMRZData {
                    if let key = data.key as? String {
                        var mrz = [String:AnyObject]()
                        if key != "lines" {
                            mrz["MRZ_key"] = data.key as! String as AnyObject
                            mrz["MRZ_data"] = data.value as AnyObject
                            mrzArray.append(mrz)
                        } else {
                            mrz["MRZ_key"] = "MRZ" as AnyObject
                            mrz["MRZ_data"] = data.value as AnyObject
                            mrzArray.append(mrz)
                        }
                    }
                }
                mrzData["personalNumber2"] = dictScanningMRZData["personalNumber2"] as AnyObject
            }
        }
        
        let arrBackResultKey = resultmodel.arrayocrBackSideDataKey as! [String]
        let arrBackResultValue = resultmodel.arrayocrBackSideDataValue as! [String]
        for i in arrBackResultKey.indices {
            if arrBackResultKey[i] != "MRZ" {
                var back_Data:[String: AnyObject] = [:]
                
                back_Data["scanned_type"] = 1 as AnyObject
                back_Data["back_key"] = arrBackResultKey[i] as AnyObject
                back_Data["back_keydata"] = arrBackResultValue[i] as AnyObject
                backArray.append(back_Data)
            } else {
                let dictScanningMRZData = resultmodel.shareScanningMRZListing
                for data in dictScanningMRZData {
                    if let key = data.key as? String {
                        var mrz = [String:AnyObject]()
                        if key != "lines" {
                            if(data.value as! String != ""){
                                
                                mrz["MRZ_key"] = data.key as! String as AnyObject
                                mrz["MRZ_data"] = data.value as AnyObject
                                mrzArray.append(mrz)
                            }
                            
                            
                        } else {
                            mrz["MRZ_key"] = "MRZ" as AnyObject
                            mrz["MRZ_data"] = data.value as AnyObject
                            mrzArray.append(mrz)
                        }
                    }
                }
                mrzData["personalNumber2"] = dictScanningMRZData["personalNumber2"] as AnyObject
            }
        }
        results["front_data"] = frontArray as AnyObject
        results["back_data"] = backArray as AnyObject
        results["MRZ_Data"] = setMrzData(scanedInfo : resultmodel.shareScanningMRZListing) as AnyObject
        var main_OCR_Array = [[String:AnyObject]]()
        main_OCR_Array.append(results)
        var object = [String:AnyObject]()
        object["ocr_data"] = main_OCR_Array as AnyObject
        var list = [[String:String]]()
        var prodHashMap = [String:String]()
        prodHashMap["ocr_data"] = arrayToString(from: object)
        list.append(prodHashMap)
            _messagingChannel.sendMessage(list);
        
        
    }
    
    func resultData(_ resultmodel: ResultModel!) {
        print(resultmodel)
        
        if (cardSide != "") {
            if (cardSide == "0" || cardSide == "1") {
                passOcrDataToFlutter(resultmodel: resultmodel)
                
            } else {
                if (isBack || !isBothSideAvailable) { // To check card has back side or not
                    passOcrDataToFlutter(resultmodel: resultmodel)
                } else {
                    if (cardSide == "2") {
                        isBack = true;
                        videoCameraWrapper?.cardSide(.BACK_CARD_SCAN)
                    } else if (cardSide == "3") {
                        isBack = true;
                        videoCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
                    }
                }
            }
        } else {
            if (isBack || !isBothSideAvailable) { // To check card has back side or not
                passOcrDataToFlutter(resultmodel: resultmodel)
            } else {
                isBack = true;
                videoCameraWrapper?.cardSide(.BACK_CARD_SCAN)
            }
        }
        
    }
    func dlPlateNumber(_ plateNumber: String!, andImageNumberPlate imageNumberPlate: UIImage!) {
        var Scanned_Front_data_Array = [[String: AnyObject]]()
        var mainObject = [String: AnyObject]()
        var front_Object = [String:AnyObject]();
        front_Object["scanned_type"] = 1 as AnyObject;
        front_Object["front_key"] = "Number" as AnyObject;
        front_Object["front_keydata"] = plateNumber as AnyObject;
        Scanned_Front_data_Array.append(front_Object);
        mainObject["front_data"] = Scanned_Front_data_Array as AnyObject
        mainObject["front_Image"] = convertImageToBase64String(img: imageNumberPlate) as AnyObject;
        var main_OCR_Array = [[String:AnyObject]]()
        main_OCR_Array.append(mainObject)
        var object = [String:AnyObject]()
        object["ocr_data"] = main_OCR_Array as AnyObject
        var list = [[String:String]]()
        var prodHashMap = [String:String]()
        prodHashMap["ocr_data"] = arrayToString(from: object)
        list.append(prodHashMap)
        _messagingChannel.sendMessage(list);
    }
    func recognizeSucceedBarcode(_ message: String!, back BackSideImage: UIImage!, frontImage FrontImage: UIImage!, face FaceImage: UIImage!) {
        if(recogType=="1"){
            
            if (cardSide != "") {
                if (cardSide == "0" || cardSide == "1") {
                    setPdf417data(message: message,FrontImage: FrontImage,BackSideImage: BackSideImage,FaceImage: FaceImage);
                    
                } else {
                    if (isBack || !isBothSideAvailable) { // To check card has back side or not
                        setPdf417data(message: message,FrontImage: FrontImage,BackSideImage: BackSideImage,FaceImage: FaceImage);
                    } else {
                        if (cardSide == "2") {
                            isBack = true;
                            videoCameraWrapper?.cardSide(.BACK_CARD_SCAN)
                        } else if (cardSide == "3") {
                            isBack = true;
                            videoCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
                        }
                    }
                }
            } else {
                if (isBack || !isBothSideAvailable) { // To check card has back side or not
                    setPdf417data(message: message,FrontImage: FrontImage,BackSideImage: BackSideImage,FaceImage: FaceImage);
                } else {
                    isBack = true;
                    videoCameraWrapper?.cardSide(.BACK_CARD_SCAN)
                }
            }
            
        }
        else{
            setPdf417data(message: message,FrontImage: FrontImage,BackSideImage: BackSideImage,FaceImage: FaceImage);
        }
        
      
        
        
    }
    
    func setPdf417data(message:String,FrontImage:UIImage?,BackSideImage:UIImage?,FaceImage:UIImage?){
        var Scanned_Front_data_Array = [[String: AnyObject]]()
        var mainObject = [String: AnyObject]()
        var isPDF417: Bool = false
        if(decodework(type: message)) {
            isPDF417 = true
            for index in 0..<keyArr.count{
                var front_Object = [String:AnyObject]();
                front_Object["PDF417_key"] = keyArr[index] as AnyObject;
                front_Object["PDF417_keydata"] = valueArr[index] as AnyObject;
                Scanned_Front_data_Array.append(front_Object);
                
            }
            mainObject["pdf417_data"] = Scanned_Front_data_Array as AnyObject
        }
        
        if (FrontImage != nil) {
            mainObject["front_Image"] = convertImageToBase64String(img: FrontImage!) as AnyObject;
        }
        if (BackSideImage != nil) {
            mainObject["back_Image"] = convertImageToBase64String(img: BackSideImage!) as AnyObject;
        }
        if (FaceImage != nil) {
            mainObject["Face_Image"] = convertImageToBase64String(img: FaceImage!) as AnyObject;
        }
        if(recogType == "1"){
            
            if(BackSideImage != nil){
                //PDF147 Driving License
                var main_OCR_Array = [[String:AnyObject]]()
                main_OCR_Array.append(mainObject)
                var object = [String:AnyObject]()
                object["ocr_data"] = main_OCR_Array as AnyObject
                var list = [[String:String]]()
                var prodHashMap = [String:String]()
                prodHashMap["ocr_data"] = arrayToString(from: object)
                list.append(prodHashMap)
                _messagingChannel.sendMessage(list);
                
            }
        }
        else{
            
            if(isPDF417) {
                //PDF147
                var main_OCR_Array = [[String:AnyObject]]()
                main_OCR_Array.append(mainObject)
                var object = [String:AnyObject]()
                object["ocr_data"] = main_OCR_Array as AnyObject
                var list = [[String:String]]()
                var prodHashMap = [String:String]()
                prodHashMap["ocr_data"] = arrayToString(from: object)
                list.append(prodHashMap)
                
                
                _messagingChannel.sendMessage(list);
            }
            else{
                //barcode
                var front_Object = [String:AnyObject]();
                front_Object["scanned_type"] = 1 as AnyObject;
                front_Object["front_key"] = "Barcode" as AnyObject;
                front_Object["front_keydata"] = message as AnyObject;
                Scanned_Front_data_Array.append(front_Object);
                mainObject["front_data"] = Scanned_Front_data_Array as AnyObject
                
                var main_OCR_Array = [[String:AnyObject]]()
                main_OCR_Array.append(mainObject)
                var object = [String:AnyObject]()
                object["ocr_data"] = main_OCR_Array as AnyObject
                var list = [[String:String]]()
                var prodHashMap = [String:String]()
                prodHashMap["ocr_data"] = arrayToString(from: object)
                list.append(prodHashMap)
                _messagingChannel.sendMessage(list);
            }
            
        }
    }
    
    func recognizSuccessBankCard(_ cardDetail: NSMutableDictionary!, andBankCardImage bankCardImage: UIImage!) {
        
        
        var mrzArray = [[String:AnyObject]]()
        
        
        if(cardDetail["card_type"] != nil) {
            var mrzObject = [String:AnyObject]()
            mrzObject["Bank_key"] = "Card Type" as AnyObject
            mrzObject["Bank_data"] = cardDetail["card_type"] as AnyObject
            
            mrzArray.append(mrzObject);
        }
        
        if(cardDetail["card_number"] != nil) {
            var mrzObject = [String:AnyObject]()
            mrzObject["Bank_key"] = "Number" as AnyObject
            mrzObject["Bank_data"] = cardDetail["card_number"] as AnyObject
            
            mrzArray.append(mrzObject);
        }
        if(cardDetail["expiration_month"] != nil) {
            var mrzObject = [String:AnyObject]()
            mrzObject["Bank_key"] = "Expiration Month" as AnyObject
            mrzObject["Bank_data"] = cardDetail["expiration_month"] as AnyObject
            
            mrzArray.append(mrzObject);
        }
        if(cardDetail["expiration_year"] != nil) {
            var mrzObject = [String:AnyObject]()
            mrzObject["Bank_key"] = "Expiration Year" as AnyObject
            mrzObject["Bank_data"] = cardDetail["expiration_year"] as AnyObject
            
            mrzArray.append(mrzObject);
        }
        
        var mainObject = [String:AnyObject]()
        mainObject["bank_Data"] = mrzArray as AnyObject
        
        mainObject["front_Image"] = convertImageToBase64String(img: bankCardImage) as AnyObject//bankCardImage.convertImageToBase64() as AnyObject
        
        var main_OCR_Array = [[String:AnyObject]]()
        main_OCR_Array.append(mainObject)
        var object = [String:AnyObject]()
        object["ocr_data"] = main_OCR_Array as AnyObject
        var list = [[String:String]]()
        var prodHashMap = [String:String]()
        
        prodHashMap["ocr_data"] = arrayToString(from: object)
        list.append(prodHashMap)
        
        
        _messagingChannel.sendMessage(list);
        
    }
    
    func reco_msg(_ message: String!) {
        let data = NSMutableDictionary()
        data["errorMessage"] = message
        
        var dataArray = [NSMutableDictionary]()
        dataArray.append(data)
        _messagingChannel.sendMessage(dataArray)
    }
    func reco_titleMessage(_ messageCode: Int32) {
        print("msgcode:- ",messageCode)
        
        var titleCode:String = ""
        switch messageCode {
        case SCAN_TITLE_OCR_FRONT:
            //            var frontMsg = "Scan Front side of ";
            //            frontMsg = frontMsg.appending(docName)
            //            _lblTitle.text = frontMsg
            
            titleCode="1"
            break
        case SCAN_TITLE_OCR_BACK:
            //            var backMsg = "Scan Back side of ";
            //            backMsg = backMsg.appending(docName)
            //            _lblTitle.text = backMsg
            titleCode="2"
            break
        case SCAN_TITLE_OCR:
            //            var backMsg = "Scan ";
            //            backMsg = backMsg.appending(docName)
            //            _lblTitle.text = backMsg
            titleCode="3"
            break
        case SCAN_TITLE_MRZ_PDF417_FRONT:
            //            _lblTitle.text = "Scan Front Side of Document"
            titleCode="4"
            break
        case SCAN_TITLE_MRZ_PDF417_BACK:
            //            _lblTitle.text = "Scan Back Side of Document"
            titleCode="5"
            break
        case SCAN_TITLE_DLPLATE:
            //            _lblTitle.text = "Scan Number plate"
            titleCode="6"
            break
        case SCAN_TITLE_BARCODE:
            //            _lblTitle.text = "Scan Barcode"
            titleCode="4"
            break
        case SCAN_TITLE_BANKCARD:
            //            _lblTitle.text = "Scan BankCard"
            titleCode="4"
            break
        default:
            break
            
        }
        let data = NSMutableDictionary()
        data["titleMessage"] = titleCode
        var dataArray = [NSMutableDictionary]()
        dataArray.append(data)
        _messagingChannel.sendMessage(dataArray)
    }
    
    func resizeImage(image: UIImage, targetSize: CGRect) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        var newX = targetSize.origin.x - (targetSize.size.width * 0.4)
        var newY = targetSize.origin.y - (targetSize.size.height * 0.4)
        var newWidth = targetSize.size.width * 1.8
        var newHeight = targetSize.size.height * 1.8
        var image1 :UIImage=UIImage()
        if newX < 0 {
            newX = 0
        }
        if newY < 0 {
            newY = 0
        }
        if newX + newWidth > image.size.width{
            newWidth = image.size.width - newX
        }
        if newY + newHeight > image.size.height{
            newHeight = image.size.height - newY
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        if rect.width > 0 && rect.height > 0 {
            let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
            image1 = UIImage(cgImage: imageRef)
        }
        return image1
    }
    
    
    
    func convertImageToBase64String (img: UIImage) -> String {
        let imageData:NSData = img.jpegData(compressionQuality: 0.50)! as NSData //UIImagePNGRepresentation(img)
        let imgString = imageData.base64EncodedString(options: .init(rawValue: 0))
        return imgString
    }
    
    func arrayToString(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
    
    
    func decodework (type: String) -> Bool {
        
        keyArr.removeAllObjects()
        valueArr.removeAllObjects()
        let Customer_Family_Name = "DCS"
        let Family_Name = "DAB"
        
        let Customer_Given_Name =  "DCT"
        let Name_Suffix = "DCU"
        let Street_Address_1 = "DAG"
        let City = "DAI"
        let Jurisdction_Code = "DAJ"
        let ResidenceJurisdictionCode = "DAO"
        let MedicalIndicatorCodes = "DBG"
        let NonResidentIndicator = "DBI"
        let  SocialSecurityNumber = "DBK"
        let  DateOfBirth = "DBL"
        
        let Postal_Code = "DAK"
        let Customer_Id_Number = "DAQ"
        let Expiration_Date = "DBA"
        let Sex = "DBC"
        let Customer_Full_Name = "DAA"
        let Customer_First_Name = "DAC"
        let Customer_Middle_Name = "DAD"
        let Street_Address_2 = "DAH"
        let Street_Address_1_optional = "DAL"
        let Street_Address_2_optional = "DAM"
        let Date_Of_Birth = "DBB"
        let  NameSuff = "DAE"
        let  NamePref = "DAF"
        let LicenseClassification = "DAR"
        let  LicenseRestriction = "DAS"
        let LicenseEndorsement = "DAT"
        let  IssueDate = "DBD"
        let OrganDonor = "DBH"
        let HeightFT = "DAU"
        let  FullName = "DAA"
        let  GivenName = "DAC"
        let HeightCM = "DAV"
        let WeightLBS = "DAW"
        let WeightKG = "DAX"
        let EyeColor = "DAY"
        let HairColor = "DAZ"
        let IssueTimeStemp = "DBE"
        let NumberDuplicate = "DBF"
        let UniqueCustomerId = "DBJ"
        let SocialSecurityNo = "DBM"
        let Under18 = "DDH"
        let Under19 = "DDI"
        let Under21 = "DDJ"
        let PermitClassification = "PAA"
        let VeteranIndicator = "DDL"
        let  PermitIssue = "PAD"
        let PermitExpire = "PAB"
        let PermitRestriction = "PAE"
        let PermitEndorsement = "PAF"
        let CourtRestriction = "ZVA"
        let InventoryControlNo = "DCK"
        let  RaceEthnicity = "DCL"
        let StandardVehicleClass = "DCM"
        let DocumentDiscriminator = "DCF"
        let VirginiaSpecificClass = "DCA"
        let VirginiaSpecificRestrictions = "DCB"
        let PhysicalDescriptionWeight =  "DCD"
        let CountryTerritoryOfIssuance = "DCG"
        let FederalCommercialVehicleCodes = "DCH"
        let  PlaceOfBirth =  "DCI"
        let AuditInformation = "DCJ"
        let StandardEndorsementCode = "DCN"
        let StandardRestrictionCode = "DCO"
        let JurisdictionSpecificVehicleClassificationDescription = "DCP"
        let  JurisdictionSpecific = "DCQ"
        let JurisdictionSpecificRestrictionCodeDescription = "DCR"
        let  ComplianceType = "DDA"
        let CardRevisionDate = "DDB"
        let  HazMatEndorsementExpiryDate = "DDC"
        let  LimitedDurationDocumentIndicator = "DDD"
        let FamilyNameTruncation = "DDE"
        let   FirstNamesTruncation = "DDF"
        let MiddleNamesTruncation = "DDG"
        let OrganDonorIndicator =  "DDK"
        let  PermitIdentifier = "PAC"
        
        
        mutableArray.add(Customer_Full_Name)
        mutableArray.add(Customer_Family_Name)
        mutableArray.add(Family_Name)
        
        mutableArray.add(Customer_Given_Name)
        mutableArray.add(Name_Suffix)
        mutableArray.add(Street_Address_1)
        mutableArray.add(City)
        mutableArray.add(Jurisdction_Code)
        mutableArray.add(ResidenceJurisdictionCode)
        mutableArray.add(MedicalIndicatorCodes)
        mutableArray.add(NonResidentIndicator)
        mutableArray.add(SocialSecurityNumber)
        mutableArray.add(DateOfBirth)
        mutableArray.add(VirginiaSpecificClass)
        mutableArray.add(VirginiaSpecificRestrictions)
        mutableArray.add(PhysicalDescriptionWeight)
        mutableArray.add(CountryTerritoryOfIssuance)
        mutableArray.add(FederalCommercialVehicleCodes)
        mutableArray.add(PlaceOfBirth)
        mutableArray.add(AuditInformation)
        mutableArray.add(StandardEndorsementCode)
        mutableArray.add(JurisdictionSpecificVehicleClassificationDescription)
        mutableArray.add(JurisdictionSpecific)
        mutableArray.add(PermitIdentifier)
        mutableArray.add(OrganDonorIndicator)
        mutableArray.add(MiddleNamesTruncation)
        mutableArray.add(FirstNamesTruncation)
        mutableArray.add(FamilyNameTruncation)
        mutableArray.add(HazMatEndorsementExpiryDate)
        mutableArray.add(LimitedDurationDocumentIndicator)
        mutableArray.add(CardRevisionDate)
        mutableArray.add(ComplianceType)
        mutableArray.add(JurisdictionSpecificRestrictionCodeDescription)
        mutableArray.add(StandardRestrictionCode)
        
        mutableArray.add(Postal_Code)
        mutableArray.add(Customer_Id_Number)
        mutableArray.add(Expiration_Date)
        mutableArray.add(Sex)
        mutableArray.add(Customer_First_Name)
        mutableArray.add(Customer_Middle_Name)
        mutableArray.add(Street_Address_2)
        mutableArray.add(Street_Address_1_optional)
        mutableArray.add(Street_Address_2_optional)
        mutableArray.add(Date_Of_Birth)
        mutableArray.add(NameSuff)
        mutableArray.add(NamePref)
        mutableArray.add(LicenseClassification)
        mutableArray.add(LicenseRestriction)
        mutableArray.add(LicenseEndorsement)
        mutableArray.add(IssueDate)
        mutableArray.add(OrganDonor)
        mutableArray.add(HeightFT)
        mutableArray.add(FullName)
        mutableArray.add(GivenName)
        mutableArray.add(HeightCM)
        mutableArray.add(WeightLBS)
        mutableArray.add(WeightKG)
        mutableArray.add(EyeColor)
        mutableArray.add(HairColor)
        mutableArray.add(IssueTimeStemp)
        mutableArray.add(NumberDuplicate)
        mutableArray.add(UniqueCustomerId)
        mutableArray.add(SocialSecurityNo)
        mutableArray.add(Under18)
        mutableArray.add(Under19)
        mutableArray.add(Under21)
        mutableArray.add(PermitClassification)
        mutableArray.add(VeteranIndicator)
        mutableArray.add(PermitIssue)
        mutableArray.add(PermitExpire)
        mutableArray.add(PermitRestriction)
        mutableArray.add(PermitEndorsement)
        mutableArray.add(CourtRestriction)
        mutableArray.add(InventoryControlNo)
        mutableArray.add(RaceEthnicity)
        mutableArray.add(StandardVehicleClass)
        mutableArray.add(DocumentDiscriminator)
        
        var emptyDictionary = [String: String]()
        var passDict = [String: String]()
        
        let fullstrArr = type.components(separatedBy: "\n")
        for object in fullstrArr {
            var str = object as String
            if str.contains("ANSI")  {
                let parts = str.components(separatedBy: "DL")
                if parts.count > 1 {
                    str = parts[parts.count-1]
                }
                
                
            }
            let count = str.count
            
            if count > 3 {
                (str as NSString).substring(with: NSRange(location: 0, length: 3))
                let key  = str.index(str.startIndex, offsetBy:3)
                let key1 = String(str[..<key])
                
                let indexsd = str.index(str.startIndex, offsetBy: 3)
                let tempstr = str[indexsd...]  // "Hello>>>"
                if (tempstr != "NONE") {
                    emptyDictionary.updateValue(String(tempstr), forKey: key1)
                    
                }
                
            }
        }
        if((emptyDictionary["DAA"]) != nil) {
            passDict.updateValue(emptyDictionary["DAA"]!, forKey: "FULL NAME: ")
            if(keyArr .contains("FULL NAME: ")) {
            }
            else {
                valueArr.add(emptyDictionary["DAA"]!)
                keyArr.add("FULL NAME: ")
            }
        }
        
        if((emptyDictionary["DAB"]) != nil) {
            passDict.updateValue(emptyDictionary["DAB"]!, forKey: "LAST NAME:")
            if(keyArr .contains("LAST NAME:")) {
            }
            else {
                valueArr.add(emptyDictionary["DAB"]!)
                keyArr.add("LAST NAME:")
            }
            
            
        }
        
        if((emptyDictionary["DAC"]) != nil) {
            passDict.updateValue(emptyDictionary["DAC"]!, forKey: "FIRST NAME:")
            if(keyArr .contains("FIRST NAME: ") ) {
                
            }
            else {
                valueArr.add(emptyDictionary["DAC"]!)
                keyArr.add("FIRST NAME: ")
            }
            
            
        }
        
        
        if((emptyDictionary["DAD"]) != nil) {
            passDict.updateValue(emptyDictionary["DAD"]!, forKey: "MIDDLE NAME:")
            if(keyArr .contains("MIDDLE NAME:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAD"]!)
                keyArr.add("MIDDLE NAME:")
            }
            
            
        }
        
        if((emptyDictionary["DAE"]) != nil) {
            passDict.updateValue(emptyDictionary["DAE"]!, forKey: "NAME SUFFIX: ")
            if(keyArr .contains("NAME SUFFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAE"]!)
                keyArr.add("NAME SUFFIX: ")
            }
        }
        
        if((emptyDictionary["DAF"]) != nil) {
            passDict.updateValue(emptyDictionary["DAF"]!, forKey: "NAME PREFIX: ")
            if(keyArr .contains("NAME PREFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAF"]!)
                keyArr.add("NAME PREFIX: ")
            }
        }
        
        if((emptyDictionary["DAG"]) != nil) {
            passDict.updateValue(emptyDictionary["DAG"]!, forKey: "MAILING STREET ADDRESS1: ")
            if(keyArr .contains("MAILING STREET ADDRESS1: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAG"]!)
                keyArr.add("MAILING STREET ADDRESS1: ")
            }
            
        }
        
        if((emptyDictionary["DAH"]) != nil) {
            passDict.updateValue(emptyDictionary["DAH"]!, forKey: "MAILING STREET ADDRESS2: ")
            if(keyArr .contains("MAILING STREET ADDRESS2: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAH"]!)
                keyArr.add("MAILING STREET ADDRESS2: ")
            }
        }
        
        if((emptyDictionary["DAI"]) != nil) {
            passDict.updateValue(emptyDictionary["DAI"]!, forKey: "MAILING CITY:")
            if(keyArr .contains("MAILING CITY:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAI"]!)
                keyArr.add("MAILING CITY:")
            }
            
        }
        
        
        if((emptyDictionary["DAJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DAJ"]!, forKey: "MAILING JURISDICTION CODE: ")
            if(keyArr .contains("MAILING JURISDICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAJ"]!)
                keyArr.add("MAILING JURISDICTION CODE: ")
            }
            
        }
        
        if((emptyDictionary["DAK"]) != nil) {
            passDict.updateValue(emptyDictionary["DAK"]!, forKey: "MAILING POSTAL CODE:")
            if(keyArr .contains("MAILING POSTAL CODE:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAK"]!)
                keyArr.add("MAILING POSTAL CODE: ")
            }
            
            
        }
        
        if((emptyDictionary["DAL"]) != nil) {
            passDict.updateValue(emptyDictionary["DAL"]!, forKey: "RESIDENCE STREET ADDRESS1: ")
            if(keyArr .contains("RESIDENCE STREET ADDRESS1: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAL"]!)
                keyArr.add("RESIDENCE STREET ADDRESS1: ")
            }
        }
        
        if((emptyDictionary["DAM"]) != nil) {
            passDict.updateValue(emptyDictionary["DAM"]!, forKey: "RESIDENCE STREET ADDRESS2: ")
            if(keyArr .contains("RESIDENCE STREET ADDRESS2: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAM"]!)
                keyArr.add("RESIDENCE STREET ADDRESS2: ")
            }
        }
        
        if((emptyDictionary["DAN"]) != nil) {
            passDict.updateValue(emptyDictionary["DAN"]!, forKey: "RESIDENCE CITY: ")
            if(keyArr .contains("RESIDENCE CITY: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAN"]!)
                keyArr.add("RESIDENCE CITY: ")
            }
        }
        
        if((emptyDictionary["DAO"]) != nil) {
            passDict.updateValue(emptyDictionary["DAO"]!, forKey: "RESIDENCE JURISDICTION CODE: ")
            if(keyArr .contains("RESIDENCE JURISDICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAO"]!)
                keyArr.add("RESIDENCE JURISDICTION CODE: ")
            }
            
        }
        
        if((emptyDictionary["DAP"]) != nil) {
            passDict.updateValue(emptyDictionary["DAP"]!, forKey: "RESIDENCE POSTAL CODE: ")
            if(keyArr .contains("RESIDENCE POSTAL CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAP"]!)
                keyArr.add("RESIDENCE POSTAL CODE: ")
            }
            
        }
        
        if((emptyDictionary["DAQ"]) != nil) {
            passDict.updateValue(emptyDictionary["DAQ"]!, forKey: "LICENCE OR ID NUMBER: ")
            if(keyArr .contains("LICENCE OR ID NUMBER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAQ"]!)
                keyArr.add("LICENCE OR ID NUMBER: ")
            }
        }
        
        if((emptyDictionary["DAR"]) != nil) {
            passDict.updateValue(emptyDictionary["DAR"]!, forKey: "LICENCE CLASSIFICATION CODE: ")
            if(keyArr .contains("LICENCE CLASSIFICATION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAR"]!)
                keyArr.add("LICENCE CLASSIFICATION CODE: ")
            }
        }
        
        if((emptyDictionary["DAS"]) != nil) {
            passDict.updateValue(emptyDictionary["DAS"]!, forKey: "LICENCE RESTRICTION CODE: ")
            if(keyArr .contains("LICENCE RESTRICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAS"]!)
                keyArr.add("LICENCE RESTRICTION CODE: ")
            }
        }
        
        if((emptyDictionary["DAT"]) != nil) {
            passDict.updateValue(emptyDictionary["DAT"]!, forKey: "LICENCE ENDORSEMENT CODE: ")
            if(keyArr .contains("LICENCE ENDORSEMENT CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAT"]!)
                keyArr.add("LICENCE ENDORSEMENT CODE: ")
            }
        }
        
        if((emptyDictionary["DAU"]) != nil) {
            passDict.updateValue(emptyDictionary["DAU"]!, forKey: "HEIGHT IN FT_IN: ")
            if(keyArr .contains("HEIGHT IN FT_IN: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAU"]!)
                keyArr.add("HEIGHT IN FT_IN:")
            }
        }
        
        if((emptyDictionary["DAV"]) != nil) {
            passDict.updateValue(emptyDictionary["DAV"]!, forKey: "HEIGHT IN CM: ")
            if(keyArr .contains("HEIGHT IN CM: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAV"]!)
                keyArr.add("HEIGHT IN CM: ")
            }
        }
        
        if((emptyDictionary["DAW"]) != nil) {
            passDict.updateValue(emptyDictionary["DAW"]!, forKey: "WEIGHT IN LBS: ")
            if(keyArr .contains("WEIGHT IN LBS: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAW"]!)
                keyArr.add("WEIGHT IN LBS: ")
            }
            
            
        }
        
        if((emptyDictionary["DAX"]) != nil) {
            passDict.updateValue(emptyDictionary["DAX"]!, forKey: "WEIGHT IN KG:")
            if(keyArr .contains("WEIGHT IN KG:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAX"]!)
                keyArr.add("WEIGHT IN KG:")
            }
        }
        
        if((emptyDictionary["DAY"]) != nil) {
            passDict.updateValue(emptyDictionary["DAY"]!, forKey: "EYE COLOR: ")
            if(keyArr .contains("EYE COLOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAY"]!)
                keyArr.add("EYE COLOR:")
            }
            
        }
        
        if((emptyDictionary["DAZ"]) != nil) {
            passDict.updateValue(emptyDictionary["DAZ"]!, forKey: "HAIR COLOR: ")
            if(keyArr .contains("HAIR COLOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAZ"]!)
                keyArr.add("HAIR COLOR:")
            }
            
            
            
        }
        
        if((emptyDictionary["DBA"]) != nil) {
            passDict.updateValue(emptyDictionary["DBA"]!, forKey: "LICENSE EXPIRATION DATE: ")
            if(keyArr .contains("LICENSE EXPIRATION DATE: ")) {
            }
            else {
                
                var  str = emptyDictionary["DBA"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("LICENSE EXPIRATION DATE: ")
            }
        }
        if((emptyDictionary["DBB"]) != nil) {
            passDict.updateValue(emptyDictionary["DBB"]!, forKey:  "DATE OF BIRTH: ")
            if(keyArr .contains("DATE OF BIRTH: ")) {
            }
            else {
                var  str = emptyDictionary["DBB"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("DATE OF BIRTH:")
            }
            
            
            
        }
        
        if((emptyDictionary["DBC"]) != nil) {
            passDict.updateValue(emptyDictionary["DBC"]!, forKey: "SEX: ")
            if(keyArr .contains("SEX: ")) {
            }
            else {
                if(emptyDictionary["DBC"] == "1") {
                    
                    valueArr.add("MALE")
                }
                else  {
                    valueArr.add("FEMALE")
                }
                
                keyArr.add("SEX: ")
            }
            
            
            
        }
        
        if((emptyDictionary["DBD"]) != nil) {
            passDict.updateValue(emptyDictionary["DBD"]!, forKey: "LICENSE OR ID DOCUMENT ISSUE DATE: ")
            if(keyArr .contains("LICENSE OR ID DOCUMENT ISSUE DATE: ")) {
            }
            else {
                
                var  str = emptyDictionary["DBD"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("LICENSE OR ID DOCUMENT ISSUE DATE: ")
            }
        }
        
        if((emptyDictionary["DBE"]) != nil) {
            passDict.updateValue(emptyDictionary["DBE"]!, forKey:  "ISSUE TIMESTAMP: ")
            if(keyArr .contains("ISSUE TIMESTAMP: ")) {
            }
            else {
                valueArr.add(emptyDictionary["DBE"]!)
                keyArr.add("ISSUE TIMESTAMP:")
            }
        }
        
        if((emptyDictionary["DBF"]) != nil) {
            passDict.updateValue(emptyDictionary["DBF"]!, forKey: "NUMBER OF DUPLICATES: ")
            if(keyArr .contains("NUMBER OF DUPLICATES: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBF"]!)
                keyArr.add("NUMBER OF DUPLICATES: ")
            }
            
        }
        
        if((emptyDictionary["DBG"]) != nil) {
            passDict.updateValue(emptyDictionary["DBG"]!, forKey: "RMEDICAL INDICATOR CODES: ")
            if(keyArr .contains("MEDICAL INDICATOR CODES: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBG"]!)
                keyArr.add("MEDICAL INDICATOR CODES: ")
            }
            
        }
        
        if((emptyDictionary["DBH"]) != nil) {
            passDict.updateValue(emptyDictionary["DBH"]!, forKey: "ORGAN DONOR: ")
            if(keyArr .contains("ORGAN DONOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBH"]!)
                keyArr.add("ORGAN DONOR: ")
            }
        }
        
        if((emptyDictionary["DBI"]) != nil) {
            passDict.updateValue(emptyDictionary["DBI"]!, forKey: "NON-RESIDENT INDICATOR: ")
            if(keyArr .contains("NON-RESIDENT INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBI"]!)
                keyArr.add("NON-RESIDENT INDICATOR: ")
            }
            
        }
        
        if((emptyDictionary["DBJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DBJ"]!, forKey: "UNIQUE CUSTOMER IDENTIFIER: ")
            if(keyArr .contains("UNIQUE CUSTOMER IDENTIFIER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBJ"]!)
                keyArr.add("UNIQUE CUSTOMER IDENTIFIER: ")
            }
        }
        
        if((emptyDictionary["DBK"]) != nil) {
            passDict.updateValue(emptyDictionary["DBK"]!, forKey: "SOCIAL SECURITY NUMBER: ")
            if(keyArr .contains("SOCIAL SECURITY NUMBER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBK"]!)
                keyArr.add("SOCIAL SECURITY NUMBER: ")
            }
            
        }
        if((emptyDictionary["DBL"]) != nil) {
            passDict.updateValue(emptyDictionary["DBL"]!, forKey: "DATE OF BIRTH: ")
            if(keyArr .contains("DATE OF BIRTH: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBL"]!)
                keyArr.add("DATE OF BIRTH: ")
            }
        }
        
        if((emptyDictionary["DBM"]) != nil) {
            passDict.updateValue(emptyDictionary["DBM"]!, forKey: "SOCIAL SECURITY NUMBER: ")
            if(keyArr .contains("SOCIAL SECURITY NUMBER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBM"]!)
                keyArr.add("SOCIAL SECURITY NUMBER: ")
            }
        }
        
        if((emptyDictionary["DBN"]) != nil) {
            passDict.updateValue(emptyDictionary["DBN"]!, forKey: "FULL NAME: ")
            if(keyArr .contains("FULL NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBN"]!)
                keyArr.add("FULL NAME: ")
            }
        }
        
        if((emptyDictionary["DBO"]) != nil) {
            passDict.updateValue(emptyDictionary["DBO"]!, forKey: "LAST NAME: ")
            if(keyArr .contains("LAST NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBO"]!)
                keyArr.add("LAST NAME: ")
            }
        }
        
        if((emptyDictionary["DBP"]) != nil) {
            passDict.updateValue(emptyDictionary["DBP"]!, forKey: "FIRST NAME: ")
            if(keyArr .contains("FIRST NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBP"]!)
                keyArr.add("FIRST NAME: ")
            }
        }
        
        if((emptyDictionary["DBQ"]) != nil) {
            passDict.updateValue(emptyDictionary["DBQ"]!, forKey: "MIDDLE NAME: ")
            if(keyArr .contains("MIDDLE NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBQ"]!)
                keyArr.add("MIDDLE NAME: ")
            }
            
        }
        
        if((emptyDictionary["DBR"]) != nil) {
            passDict.updateValue(emptyDictionary["DBR"]!, forKey: "SUFFIX: ")
            if(keyArr .contains("SUFFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBR"]!)
                keyArr.add("SUFFIX: ")
            }
            
        }
        
        if((emptyDictionary["DBS"]) != nil) {
            passDict.updateValue(emptyDictionary["DBS"]!, forKey: "PREFIX: ")
            if(keyArr .contains("PREFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBS"]!)
                keyArr.add("PREFIX: ")
            }
            
        }
        
        if((emptyDictionary["DCA"]) != nil) {
            passDict.updateValue(emptyDictionary["DCA"]!, forKey: "VIRGINIA SPECIFIC CLASS: ")
            if(keyArr .contains("VIRGINIA SPECIFIC CLASS: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCA"]!)
                keyArr.add("VIRGINIA SPECIFIC CLASS: ")
            }
        }
        
        if((emptyDictionary["DCB"]) != nil) {
            passDict.updateValue(emptyDictionary["DCB"]!, forKey: "VIRGINIA SPECIFIC RESTRICTIONS: ")
            if(keyArr .contains("VIRGINIA SPECIFIC RESTRICTIONS: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCB"]!)
                keyArr.add("VIRGINIA SPECIFIC RESTRICTIONS: ")
            }
        }
        
        if((emptyDictionary["DCD"]) != nil) {
            passDict.updateValue(emptyDictionary["DCD"]!, forKey: "VIRGINIA SPECIFIC ENDORSEMENTS: ")
            if(keyArr .contains("VIRGINIA SPECIFIC ENDORSEMENTS: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCD"]!)
                keyArr.add("VIRGINIA SPECIFIC ENDORSEMENTS: ")
            }
        }
        
        if((emptyDictionary["DCE"]) != nil) {
            passDict.updateValue(emptyDictionary["DCE"]!, forKey: "PHYSICAL DESCRIPTION WEIGHT RANGE: ")
            if(keyArr .contains("PHYSICAL DESCRIPTION WEIGHT RANGE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCE"]!)
                keyArr.add("PHYSICAL DESCRIPTION WEIGHT RANGE: ")
            }
        }
        
        if((emptyDictionary["DCF"]) != nil) {
            passDict.updateValue(emptyDictionary["DCF"]!, forKey: "DOCUMENT DISCRIMINATOR: ")
            if(keyArr .contains("DOCUMENT DISCRIMINATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCF"]!)
                keyArr.add("DOCUMENT DISCRIMINATOR: ")
            }
            
            
        }
        
        if((emptyDictionary["DCG"]) != nil) {
            passDict.updateValue(emptyDictionary["DCG"]!, forKey: "COUNTRY TERRITORY OF ISSUANCE: ")
            if(keyArr .contains("COUNTRY TERRITORY OF ISSUANCE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCG"]!)
                keyArr.add("COUNTRY TERRITORY OF ISSUANCE: ")
            }
        }
        
        if((emptyDictionary["DCH"]) != nil) {
            passDict.updateValue(emptyDictionary["DCH"]!, forKey: "FEDERAL COMMERCIAL VEHICLE CODES: ")
            if(keyArr .contains("FEDERAL COMMERCIAL VEHICLE CODES: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCH"]!)
                keyArr.add("FEDERAL COMMERCIAL VEHICLE CODES: ")
            }
        }
        
        if((emptyDictionary["DCI"]) != nil) {
            passDict.updateValue(emptyDictionary["DCI"]!, forKey: "PLACE OF BIRTH: ")
            if(keyArr .contains("PLACE OF BIRTH: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCI"]!)
                keyArr.add("PLACE OF BIRTH: ")
            }
        }
        
        if((emptyDictionary["DCJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DCJ"]!, forKey: "AUDIT INFORMATION: ")
            if(keyArr .contains("AUDIT INFORMATION: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCJ"]!)
                keyArr.add("AUDIT INFORMATION: ")
            }
        }
        
        if((emptyDictionary["DCK"]) != nil) {
            passDict.updateValue(emptyDictionary["DCK"]!, forKey: "INVENTORY CONTROL NUMBER: ")
            if(keyArr .contains("INVENTORY CONTROL NUMBER: ")) {
            }
            else {
                valueArr.add(emptyDictionary["DCK"]!)
                keyArr.add("INVENTORY CONTROL NUMBER: ")
            }
            
            
        }
        
        if((emptyDictionary["DCL"]) != nil) {
            passDict.updateValue(emptyDictionary["DCL"]!, forKey: "RACE ETHNICITY: ")
            if(keyArr .contains("RACE ETHNICITY: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCL"]!)
                keyArr.add("RACE ETHNICITY: ")
            }
            
            
        }
        
        if((emptyDictionary["DCM"]) != nil) {
            passDict.updateValue(emptyDictionary["DCM"]!, forKey: "STANDARD VEHICLE CLASSIFICATION: ")
            if(keyArr .contains("STANDARD VEHICLE CLASSIFICATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCM"]!)
                keyArr.add("STANDARD VEHICLE CLASSIFICATION: ")
            }
            
            
        }
        
        if((emptyDictionary["DCN"]) != nil) {
            passDict.updateValue(emptyDictionary["DCN"]!, forKey: "STANDARD ENDORSEMENT CODE: ")
            if(keyArr .contains("STANDARD ENDORSEMENT CODE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCN"]!)
                keyArr.add("STANDARD ENDORSEMENT CODE: ")
            }
        }
        
        if((emptyDictionary["DCO"]) != nil) {
            passDict.updateValue(emptyDictionary["DCO"]!, forKey: "STANDARD RESTRICTION CODE: ")
            if(keyArr .contains("STANDARD RESTRICTION CODE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCO"]!)
                keyArr.add("STANDARD RESTRICTION CODE: ")
            }
        }
        
        if((emptyDictionary["DCP"]) != nil) {
            passDict.updateValue(emptyDictionary["DCP"]!, forKey: "JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION:  ")
            if(keyArr .contains("JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCP"]!)
                keyArr.add("JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION: ")
            }
        }
        
        if((emptyDictionary["DCQ"]) != nil) {
            passDict.updateValue(emptyDictionary["DCQ"]!, forKey: "JURISDICTION-SPECIFIC: ")
            if(keyArr .contains("JURISDICTION-SPECIFIC: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCQ"]!)
                keyArr.add("JURISDICTION-SPECIFIC: ")
            }
        }
        
        if((emptyDictionary["DCR"]) != nil) {
            passDict.updateValue(emptyDictionary["DCR"]!, forKey: "JURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION: ")
            if(keyArr .contains("JURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCR"]!)
                keyArr.add("JURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION: ")
            }
        }
        
        if((emptyDictionary["DCS"]) != nil) {
            passDict.updateValue(emptyDictionary["DCS"]!, forKey: "FAMILY NAME:")
            if(keyArr .contains("FAMILY NAME:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCS"]!)
                keyArr.add("FAMILY NAME:")
            }
            
            
        }
        
        if((emptyDictionary["DCT"]) != nil) {
            passDict.updateValue(emptyDictionary["DCT"]!, forKey: "GIVEN NAME:")
            if(keyArr .contains("GIVEN NAME:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCT"]!)
                keyArr.add("GIVEN NAME:")
            }
            
            
        }
        
        if((emptyDictionary["DCU"]) != nil) {
            passDict.updateValue(emptyDictionary["DCU"]!, forKey: "SUFFIX:")
            if(keyArr .contains("SUFFIX:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCU"]!)
                keyArr.add("SUFFIX:")
            }
            
            
        }
        
        if((emptyDictionary["DDA"]) != nil) {
            passDict.updateValue(emptyDictionary["DDA"]!, forKey: "COMPLIANCE TYPE: ")
            if(keyArr .contains("COMPLIANCE TYPE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DDA"]!)
                keyArr.add("COMPLIANCE TYPE: ")
            }
        }
        
        if((emptyDictionary["DDB"]) != nil) {
            passDict.updateValue(emptyDictionary["DDB"]!, forKey: "CARD REVISION DATE: ")
            if(keyArr .contains("CARD REVISION DATE: ")) {
            }
            else {
                
                
                var  str = emptyDictionary["DDB"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                
                keyArr.add("CARD REVISION DATE: ")
            }
        }
        
        if((emptyDictionary["DDC"]) != nil) {
            passDict.updateValue(emptyDictionary["DDC"]!, forKey: "HAZMAT ENDORSEMENT EXPIRY DATE: ")
            if(keyArr .contains("HAZMAT ENDORSEMENT EXPIRY DATE: ")) {
            }
            else {
                
                var  str = emptyDictionary["DDC"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                
                keyArr.add("HAZMAT ENDORSEMENT EXPIRY DATE: ")
            }
        }
        
        if((emptyDictionary["DDD"]) != nil) {
            passDict.updateValue(emptyDictionary["DDD"]!, forKey: "LIMITED DURATION DOCUMENT INDICATOR: ")
            if(keyArr .contains("LIMITED DURATION DOCUMENT INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDD"]!)
                keyArr.add("LIMITED DURATION DOCUMENT INDICATOR: ")
            }
        }
        
        if((emptyDictionary["DDE"]) != nil) {
            passDict.updateValue(emptyDictionary["DDE"]!, forKey: "FAMILY NAMES TRUNCATION: ")
            if(keyArr .contains("FAMILY NAMES TRUNCATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDE"]!)
                keyArr.add("FAMILY NAMES TRUNCATION: ")
            }
        }
        
        if((emptyDictionary["DDF"]) != nil) {
            passDict.updateValue(emptyDictionary["DDF"]!, forKey: "FIRST NAMES TRUNCATION: ")
            if(keyArr .contains("FIRST NAMES TRUNCATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDF"]!)
                keyArr.add("FIRST NAMES TRUNCATION: ")
            }
        }
        
        if((emptyDictionary["DDG"]) != nil) {
            passDict.updateValue(emptyDictionary["DDG"]!, forKey: "MIDDLE NAMES TRUNCATION: ")
            if(keyArr .contains("MIDDLE NAMES TRUNCATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDG"]!)
                keyArr.add("MIDDLE NAMES TRUNCATION: ")
            }
        }
        
        if((emptyDictionary["DDH"]) != nil) {
            passDict.updateValue(emptyDictionary["DDH"]!, forKey: "UNDER 18 UNTIL: ")
            if(keyArr .contains("UNDER 18 UNTIL: ")) {
            }
            else {
                var  dstr = emptyDictionary["DDH"]
                let index = dstr?.index((dstr?.startIndex)!, offsetBy: 2, limitedBy: (dstr?.endIndex)!)
                
                dstr?.insert("/", at: index!)
                let index1 = dstr?.index((dstr?.startIndex)!, offsetBy: 5, limitedBy: (dstr?.endIndex)!)
                dstr?.insert("/", at: index1!)
                valueArr.add(dstr as Any)
                keyArr.add("UNDER 18 UNTIL:")
                
            }
        }
        
        if((emptyDictionary["DDI"]) != nil) {
            passDict.updateValue(emptyDictionary["DDI"]!, forKey: "UNDER 19 UNTIL: ")
            if(keyArr .contains("UNDER 19 UNTIL: ")) {
            }
            else {
                var  str = emptyDictionary["DDI"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("UNDER 19 UNTIL:")
            }
        }
        
        if((emptyDictionary["DDJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DDJ"]!, forKey: "UNDER 21 UNTIL: ")
            if(keyArr .contains("UNDER 21 UNTIL: ")) {
            }
            else {
                var  str = emptyDictionary["DDJ"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("UNDER 21 UNTIL: ")
            }
        }
        
        if((emptyDictionary["DDK"]) != nil) {
            passDict.updateValue(emptyDictionary["DDK"]!, forKey: "ORGAN DONOR INDICATOR: ")
            if(keyArr .contains("ORGAN DONOR INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDK"]!)
                keyArr.add("ORGAN DONOR INDICATOR: ")
            }
        }
        
        if((emptyDictionary["DDL"]) != nil) {
            passDict.updateValue(emptyDictionary["DDL"]!, forKey: "VETERAN INDICATOR: ")
            if(keyArr .contains("VETERAN INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDL"]!)
                keyArr.add("VETERAN INDICATOR: ")
            }
            
            
        }
        
        if((emptyDictionary["PAA"]) != nil) {
            passDict.updateValue(emptyDictionary["PAA"]!, forKey: "PERMIT CLASSIFICATION CODE: ")
            if(keyArr .contains("PERMIT CLASSIFICATION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAA"]!)
                keyArr.add("PERMIT CLASSIFICATION CODE: ")
            }
            
            
        }
        
        if((emptyDictionary["PAB"]) != nil) {
            passDict.updateValue(emptyDictionary["PAB"]!, forKey: "PERMIT EXPIRATION DATE: ")
            if(keyArr .contains("PERMIT EXPIRATION DATE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAB"]!)
                keyArr.add("PERMIT EXPIRATION DATE: ")
            }
            
            
        }
        
        if((emptyDictionary["PAC"]) != nil) {
            passDict.updateValue(emptyDictionary["PAC"]!, forKey: "PERMIT IDENTIFIER: ")
            if(keyArr .contains("PERMIT IDENTIFIER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAC"]!)
                keyArr.add("PERMIT IDENTIFIER: ")
            }
        }
        
        if((emptyDictionary["PAD"]) != nil) {
            passDict.updateValue(emptyDictionary["PAD"]!, forKey: "PERMIT ISSUE DATE: ")
            if(keyArr .contains("PERMIT ISSUE DATE: ")) {
            }
            else {
                var  str = emptyDictionary["PAD"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                
                keyArr.add("PERMIT ISSUE DATE: ")
            }
        }
        
        if((emptyDictionary["PAE"]) != nil) {
            passDict.updateValue(emptyDictionary["PAE"]!, forKey: "PERMIT RESTRICTION CODE: ")
            if(keyArr .contains("PERMIT RESTRICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAE"]!)
                keyArr.add("PERMIT RESTRICTION CODE: ")
            }
            
            
        }
        
        if((emptyDictionary["PAF"]) != nil) {
            passDict.updateValue(emptyDictionary["PAF"]!, forKey: "PERMIT ENDORSEMENT CODE: ")
            if(keyArr .contains("PERMIT ENDORSEMENT CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAF"]!)
                keyArr.add("PERMIT ENDORSEMENT CODE: ")
            }
            
            
        }
        
        if((emptyDictionary["ZVA"]) != nil) {
            passDict.updateValue(emptyDictionary["ZVA"]!, forKey: "COURT RESTRICTION CODE: ")
            if(keyArr .contains("COURT RESTRICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["ZVA"]!)
                keyArr.add("COURT RESTRICTION CODE: ")
            }
        }
        
        if(emptyDictionary["DAC"] != nil || emptyDictionary["DAD"] != nil || emptyDictionary["DCS"] != nil || emptyDictionary["DAG"] != nil ||  emptyDictionary["DAI"] != nil || emptyDictionary["DAJ"] != nil || emptyDictionary["DAK"] != nil || emptyDictionary["DBA"] != nil) {
            return true
        }
        else {
            return false
        }
        
    }
    
}

extension UIImageView {
    func setImageToCenter() {
        let imageSize = self.image?.size
        self.sizeThatFits(imageSize ?? CGSize.zero)
        var imageViewCenter = self.center
        imageViewCenter.x = self.frame.midX
        self.center = imageViewCenter
    }
}

//extension UIImage{
//    func convertImageToBase64() ->String{
//        let data=self.pngData()
//        let strBase64 = data!.base64EncodedString(options: .lineLength64Characters)
//        return strBase64
//    }
//}
