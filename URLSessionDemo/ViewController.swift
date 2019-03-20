//
//  ViewController.swift
//  URLSessionDemo
//
//  Created by 赛峰 施 on 2019/3/15.
//  Copyright © 2019 PETER SHI. All rights reserved.
//

import UIKit
import Alamofire
import SwiftDevUtility

class ViewController: UIViewController {

    let url = "https://trade.laocaibao.com//laocaibaoVesionService/Api/lcbRequest"
    let projectNum = "Lc_WS2015"
    let jkID = "400002"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let  oriDic = [
            "cmCellphone": "13482464176",
            "cmPassword": "lynn532289386".md5String,
            "deviceId":NSUUID().uuidString,
            "clientId":""
            ]
        //1.test custom parameter encoding
//        startRequest(jkid: jkID, dic: oriDic)
        
        let parameters: Parameters = [
            "foo": [1,2,3],
            "bar": [
                "baz": "qux"
            ]
        ]
        //2.test NetworkResource and siwft json map model
        let networkResource = SSFNetworkResource<TestModel>(path: URL(string: "https://httpbin.org/post")!, parameter: parameters) { TestModel.convert(jsonData: $0 as! Data) }
        networkResource.asyncLoad { result in
            switch result {
            case .success(let testModel):
                print(testModel)
            case .failure(let error):
                print(error)
            }
        }
    }
    
    //test custom parameter encoding
    func startRequest(jkid: String, dic: [String: String]) {
        let userAgent = "\(String(describing: AppInfoHelper.appName)) \(String(describing: AppInfoHelper.appVersion))(iOS;\(UIDevice.current.systemVersion);zh_CN)"
        let reqHeadParam = [
            "mechanism":"证大",
            "platform":"App",
            "togatherType":"证大无线",
            "openchannel":"AppStore",
            "token":"",
            "userAgent":userAgent,
            "sessionToken":"",
            "version":AppInfoHelper.appVersion!,
            "deviceID":NSUUID().uuidString
        ]
        
        let dateString = Date().standardTimeString.replacingOccurrences(of: " ", with: "").replacingOccurrences(of: "-", with: "").replacingOccurrences(of: ":", with: "")
        let sn = "\(projectNum)-\(dateString)-78329"
        let secret = "KWOJT23434LT3PAD"
        let sign = "\(projectNum)|\(sn)|\(secret)".md5String
        
        let paramDic = ["projectNo":projectNum,
                        "reqUrl":"",
                        "reqParam":dic,
                        "reqHeadParam":reqHeadParam,
                        "reqTimestamp":"",
                        "sn":sn,
                        "sign":sign
            ] as [String : Any]
        let realParaDic = ["arg0": jkid,
                           "arg1": paramDic] as [String : Any]
        let a = Alamofire.request(url, method: .post, parameters: realParaDic, encoding: LCBEncoding(), headers: nil).responseString { response in
            switch response.result {
            case .success(let value):
                print(value)
            case .failure(let error):
                print(error)
            }
        }
//        print("===" + String(data: (a.request?.httpBody)!, encoding: .utf8)!)
    }
}

//Alamofir 提供的默认参数编码无法满足业务需求，根据Alamofir提供的ParameterEncoding自定义参数编码
struct LCBEncoding: ParameterEncoding {
    public func encode(_ urlRequest: URLRequestConvertible, with parameters: Parameters?) throws -> URLRequest {
        var urlRequest = try urlRequest.asURLRequest()
        
        let paraDic = parameters?["arg1"]
        let paraDicData = try! JSONSerialization.data(withJSONObject: paraDic as Any, options: [])
        let paraString = String(data: paraDicData, encoding: .utf8)
        let paString = "arg0=\(parameters!["arg0"])&arg1=\(paraString!)".addingPercentEncoding(withAllowedCharacters: CharacterSet(charactersIn: "#%<>[\\]^`{|}\"]+").inverted)
        
        
        if urlRequest.value(forHTTPHeaderField: "Content-Type") == nil {
            urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        }
        
        urlRequest.httpBody = paString!.data(using: .utf8)
        
        return urlRequest
    }
}

struct TestModel: Codable {
    static func convert(jsonData: Data) -> TestModel? {
        let jsonDecoder = JSONDecoder()
        let modelObject = try? jsonDecoder.decode(TestModel.self, from: jsonData)
        return modelObject
    }
    
    let userInfos: [UserInfo]
    
    struct UserInfo: Codable {
        
        let userName: String
        let age: Int
        let height: Float?
        let sex: Bool
    }
    
}
