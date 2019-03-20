//
//  NetworkResource.swift
//  URLSessionDemo
//
//  Created by 赛峰 施 on 2019/3/20.
//  Copyright © 2019 PETER SHI. All rights reserved.
//

import Foundation
import Alamofire

///The struct describe the process of network and the most importnt thing is it decouple the net work ,parser and completion handler.
struct SSFNetworkResource<T> {
    let path: URL//The url of net work
    let parameter: Parameters//The parameters post to http
    let parser: (Any) -> T?//The method of translating the json object to the data modle
}

///Notice the Parameter Encoding,usually http's content-type support application/Json and application/x-www-form-urlencoding, but sometimes we should custom parameter encoding to satisfy work.
extension SSFNetworkResource {
    func asyncLoad(completionHandler: @escaping (Result<T>) -> Void) {
        Alamofire.request(path, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: nil)
            .validate()
            .responseJSON { dataResponse in
                switch dataResponse.result {
                case .success(let value):
                //模拟返回数据
                let va = [
                    "userInfos": [[
                    "userName": "小名",
                    "age": 18,
                    "sex": true
                    ],
                    [
                    "userName": "小方",
                    "age": 18,
                    "height": 162.56,
                    "sex": false
                    ]
                    ]
                ]
                let data = try! JSONSerialization.data(withJSONObject: va, options: [])
                    completionHandler(Result.success(self.parser(data)!))
                case .failure(let error):
                    completionHandler(Result.failure(error))
                }
        }
    }
}
