//
//  MrzListClass.swift
//  accura_kyc_flutter
//
//  Created by Amit on 10/08/21.
//

import Foundation
import AccuraOCR


class MrzListClass: NSObject {
  
    var  call = FlutterMethodCall()
    var  result : FlutterResult?
    var arrCountryList = NSMutableArray()
    var accuraCameraWrapper: AccuraCameraWrapper? = nil
  
  func  MrzListClass( call: FlutterMethodCall, result: @escaping FlutterResult){
    self.call=call;
    self.result=result;
    
    getResult();
    }
    func getResult(){
        self.accuraCameraWrapper = AccuraCameraWrapper.init()
        self.accuraCameraWrapper?.showLogFile(true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            let sdkModel = self.accuraCameraWrapper?.loadEngine(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
            if (sdkModel!.i > 0) {
                if(sdkModel!.isMRZEnable) {
                    
                    let dict = ["Mrz" :Int(1)]
                    self.arrCountryList.add(dict)
                    // ID MRZ
                    // Visa MRZ
                    // Passport MRZ
                    // All MRZ
                }
                else{
                    let dict = ["Mrz" : Int(0)]
                    self.arrCountryList.add(dict)
                }
                    if(sdkModel!.isBankCardEnable) {
                        let dict = ["Bank_Card" : Int(1)]
                        self.arrCountryList.add(dict)
                    } else {
                        let dict = ["Bank_Card" : Int(0)]
                        self.arrCountryList.add(dict)
                    }
                 
                if(sdkModel!.isBarcodeEnable) {
                    
                    let dict = ["Barcode" : Int(1)]
                    self.arrCountryList.add(dict)
                }
                else{
                    let dict = ["Barcode" : Int(0)]
                    self.arrCountryList.add(dict)
                }

                    // if sdkModel.isOCREnable then get card data

                if (((sdkModel?.isOCREnable)) != nil){
                        let countryListStr = self.accuraCameraWrapper?.getOCRList();
                        if (countryListStr != nil) {
                            for i in countryListStr!{
                                self.arrCountryList.add(i)
                            }
                        }
                    }
                var dictAllData :[String:AnyObject] = ["All_Data": self.arrCountryList]
                dictAllData["sdk_rate_value"] = sdkModel!.i as AnyObject
                let jsonString=self.json(from:dictAllData)
                self.result!(jsonString);
                }
            else{
                let dictAllData = ["sdk_rate_value": sdkModel!.i]
                let jsonString=self.json(from:dictAllData)
                self.result!(jsonString);
            }
            
    

    //            arrCountryList to get value(forKey: "card_name") //get card Name
    //            arrCountryList to get value(forKey: "country_id") //get country id
    //            arrCountryList to get value(forKey: "card_id") //get card id
        }
                }
    func json(from object:Any) -> String? {
        guard let data = try? JSONSerialization.data(withJSONObject: object, options: []) else {
            return nil
        }
        return String(data: data, encoding: String.Encoding.utf8)
    }
       

}
