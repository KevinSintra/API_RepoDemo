//
//  BaseModel.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/8.
//

protocol BaseRequest: BaseModel {
    var action: String? {get set}
    var deviceSN: String? {get set}
}

protocol BaseRespnese: BaseModel {
    var code: String? {get set}
    var msg: String? {get set}
}

protocol BaseModel {
    associatedtype dataType: AnyObject where dataType: Codable
    var data: dataType? {get set}
}
