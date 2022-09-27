//
//  BaseModel.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/8.
//

/// Request Model 預設的屬性
protocol BaseRequest: BaseModel {
    
    /// Reequst 的動作行為: 取資料 get, 刪除 delete, 建立/新增 add, 修改 update
    var action: String? {get set}
    /// 光譜儀的 SN
    var deviceSN: String? {get set}
}

/// Response Model 預設的屬性
protocol BaseRespnese: BaseModel {
    
    /// Server 收到請求後處理的結果代號: 成功 ok, 失敗 error
    var code: String? {get set}
    /// 成功/失敗 的訊息 ex: 成功 -> 量測成功, 失敗 -> 量測失敗
    var msg: String? {get set}
}

/// 共通的預設屬性
protocol BaseModel {
    associatedtype dataType: AnyObject where dataType: Codable
    /// request/response 此次的主要訊息內容所對應的 model, `dataType?` 是指 model 對應的型別
    var data: dataType? {get set}
}
