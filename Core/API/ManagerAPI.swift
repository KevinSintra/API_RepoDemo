//
//  ManagerAPI.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import Foundation

import Alamofire 

internal enum Result<T> {
    
    case success(_ obj: T, _ httpStatusCode: Int)
    case failure(_ error: String, _ httpStatusCode: Int)
}

internal protocol P_ManagerAPI {
    
    func getGenericRespnse<T, R>(url: String?, requestContent: T, callback: @escaping ((Result<R?>) -> Void)
    ) -> Void where T: AnyObject, T: Codable, R: AnyObject, R: Codable
    
    func objectToDic<T>(data: T) -> Dictionary<String, Any>? where T: Codable
    
    func jsonToObj<T>(jsonString: Data) -> T? where T: Codable
}

internal class ManagerAPI : P_ManagerAPI {
    
    private let mDomainURL: String
    
    private let mHeaders: HTTPHeaders
    
    init() {
        
        self.mDomainURL = Configuration.EZ_Print_URL.Value()
        self.mHeaders = [HTTPHeader.contentType("application/json")]
    }
    
    func getGenericRespnse<T, R>(url: String? = nil, requestContent: T, callback: @escaping ((Result<R?>) -> Void))
    where T : AnyObject, T : Codable, R : AnyObject, R : Codable {
        
        var lUrl = self.mDomainURL
        if(url != nil) { lUrl += url! }
        let dic = self.objectToDic(data: requestContent)
        
        let afRequest = AF.request(lUrl, method: .post, parameters: dic, encoding: JSONEncoding.default, headers: self.mHeaders)
            .validate() //.validate(statusCode: 200..<300)
            .validate(contentType: ["application/json"])
        
        afRequest.responseData { response in
            switch response.result {
            case .success:
                let resData: R? = self.jsonToObj(jsonString: response.data!)
                callback(Result.success(resData, response.response?.statusCode ?? 0))
            case .failure(let error):
                callback(Result.failure(error.errorDescription ?? "", response.response?.statusCode ?? 0))
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
