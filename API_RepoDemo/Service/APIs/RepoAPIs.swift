//
//  RepoAPIs.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/11.
//

/// All API's Repository.
public protocol P_PepoAPIs {
    
    /// 透過單例模式single instance pattern, 管理 Repo
    static var `default`: P_PepoAPIs { get }
    
    /// 使用者帳號相關的 API
    var AccountHttpAPI: P_AccountHttpAPI { get }
}

/// All API's Repository. note: 如果要導入自動化測試, 將此類的協定寫出來後, 透過 DI/IoC 機制即可.
class RepoAPIs: P_PepoAPIs {
    
    public static let `default`: P_PepoAPIs = RepoAPIs()
    
    public var AccountHttpAPI: P_AccountHttpAPI {
        get {
            if(self._accountAPI == nil) {
                self._accountAPI = AccontHttpAPI(self._managerAPI)
            }
            
            return self._accountAPI!
        }
    }
    private var _accountAPI: P_AccountHttpAPI?
    
    private let _managerAPI: P_ManagerAPI
    private init() {
        self._managerAPI = ManagerAPI()
    }
    
}
