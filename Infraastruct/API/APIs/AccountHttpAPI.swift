//
//  AccountHttpAPI.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/11.
//

/// 使用者相關的 API 接口
public protocol P_AccountHttpAPI : P_BaseHttp {
    
    /// 依據 Device SN 取得使用者的 Token 為後續 API 提供驗證
    ///
    /// - Parameters:
    ///   - requestModel: ``GetTokenRequest``
    ///   - callback: ``getUserToken(requestModel:callback:)``
    func getUserToken(requestModel: GetTokenRequest, callback: @escaping ((httpResult<GetTokenResponse?>) -> Void))
}

internal class AccontHttpAPI : P_AccountHttpAPI {
    
    lazy var _getUserTokenRoothPath: String = rootPathURL + "getToken"
    
    func getUserToken(requestModel: GetTokenRequest, callback: @escaping ((httpResult<GetTokenResponse?>) -> Void)) {
        
        let urlPath = self._getUserTokenRoothPath
        
        self._managerAPI.getGenericRespnse(urlPath: urlPath, requestContent: requestModel,
                                           callback: { (result: ResponseResult<GetTokenResponse?>) in
            switch result {
            case .success(let obj, _):
                callback(httpResult.success(obj, 200))
            case .failure(let errMsg, let statusCode):
                callback(httpResult.failure(errMsg, statusCode))
            }
        })
    }
    
    let _rootPathUrl: String
    var rootPathURL: String {
        get { return self._rootPathUrl }
    }
    
    var _managerAPI: P_ManagerAPI
    
    required init(_ managerAPI: P_ManagerAPI? = nil) {
        
        self._rootPathUrl = ""
        
        if(managerAPI != nil) {
            _managerAPI = managerAPI!
        }
        else {
            _managerAPI = ManagerAPI()
        }
        
    }
    
}
