//
//  BaseHttpAPI.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/11.
//

/// 與所有 Http API 互動時所使用的 callback, `T` 是 response model 對應的型別
public enum httpResult<T> where T : Codable {
    
    /// Http API 互動成功時
    case success(_ obj: T, _ httpStatusCode: Int)
    /// Http API 互動失敗時
    ///
    /// - Parameters:
    ///    - error: Alamofire API 的錯誤訊息
    case failure(_ error: String, _ httpStatusCode: Int)
}


/// 所有 Http API 需要遵守的規範協定
public protocol P_BaseHttp {
    
    /// 此分類下的 API 接口是否有 root path
    var rootPathURL: String { get }
    
    
    /// 讓外部可注入 ManagerAPI 方便未來切換測試
    /// - Parameter managerAPI: ``init(_:)
    init(_ managerAPI: P_ManagerAPI?)
}
