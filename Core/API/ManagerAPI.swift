//
//  ManagerAPI.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import Foundation

import Alamofire 


// MARK: 使用 callback 來達成 ManagerAPI 的非同步溝通機制

/// `ManagerAPI` http request 後使用的 callback.
/// `T` 是 http response 的 json 欲轉換的型別.
public enum ResponseResult<T> {
    
    /// http request 成功時
    case success(_ obj: T, _ httpStatusCode: Int)
    
    /// http reqeust 失敗時
    ///
    /// - Parameters:
    ///    - error: Alamofire API 的錯誤訊息
    case failure(_ error: String, _ httpStatusCode: Int)
}

/// `ManagerAPI` 對外的規範協定.
/// 通用的操作封裝後的 AF API, AF API 執行時會使用多執行緒!! 值得關注的是 response 回來後會切回 main thread !
public protocol P_ManagerAPI {
    
    /// 資料轉換通用型的對於 Http Request & Http Response, Domain & Header 走預設設定,
    ///
    /// - Parameters:
    ///   - urlPath: URL path 的部分
    ///   - requestContent: request content 的 model
    ///   - callback: `ResponseResult<T>`
    /// - Returns: Void
    func getGenericRespnse<T, R>(urlPath: String?, requestContent: T, callback: @escaping ((ResponseResult<R?>) -> Void)
    ) -> Void where T: AnyObject, T: Codable, R: AnyObject, R: Codable
}

/// `ManagerAPI` 對內的規範協定
internal protocol P_internnal_ManagerAPI {
    
    func objectToDic<T>(data: T) -> Dictionary<String, Any>? where T: Codable
    
    func jsonToObj<T>(jsonString: Data) -> T? where T: Codable
}

protocol P_AllManagerAPI: P_ManagerAPI, P_internnal_ManagerAPI {}

internal class ManagerAPI : P_AllManagerAPI {
    
    private let mDomainURL: String
    
    private let mHeaders: HTTPHeaders
    
    init() {
        
        self.mDomainURL = Configuration.EZ_Print_URL.Value()
        self.mHeaders = [HTTPHeader.contentType("application/json")]
    }
    
    func getGenericRespnse<T, R>(urlPath: String? = nil, requestContent: T, callback: @escaping ((ResponseResult<R?>) -> Void))
    where T : AnyObject, T : Codable, R : AnyObject, R : Codable {
        
        var lUrl = self.mDomainURL
        if(urlPath != nil) { lUrl += urlPath! }
        let dic = self.objectToDic(data: requestContent)
        
        let afRequest = AF.request(lUrl, method: .post, parameters: dic, encoding: JSONEncoding.default, headers: self.mHeaders)
            .validate() //.validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
        
        
        // ref: github.com/Alamofire/Alamofire/issues/1111
        afRequest.responseData(queue: .main) { response in
            switch response.result {
            case .success:
                let resData: R? = self.jsonToObj(jsonString: response.data!)
                callback(ResponseResult.success(resData, response.response?.statusCode ?? 0))
            case .failure(let error):
                callback(ResponseResult.failure(error.errorDescription ?? "", response.response?.statusCode ?? 0))
            }
        }
    }
    
    internal func objectToDic<T>(data: T) -> Dictionary<String, Any>? where T : Codable {
        
        let encoder = JSONEncoder()
        let data = try! encoder.encode(data)
        let dict: Dictionary<String, Any>? = try! JSONSerialization.jsonObject(with: data, options: []) as? [String : Any]
        
        return dict
    }
    
    internal func jsonToObj<T>(jsonString: Data) -> T? where T : Codable {
        
        let decoder = JSONDecoder()
        let obj = try! decoder.decode(T.self, from: jsonString)
        let result = obj
        
        return result
    }
    
}
