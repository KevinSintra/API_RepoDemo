//
//  GetTokenMdoel.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/8.
//

// MARK: GetToken 的 Request Model

class mRequest: Codable{
    var deviceID: String?
}

public class GetTokenRequest: BaseRequest, Codable{
    
    typealias dataType = mRequest
    var action: String?
    var deviceSN: String?
    var data: dataType? = mRequest()
}

// MARK: GetToken 的 Response Model

class mResponse: Codable {
    var token: String?
}

public class GetTokenResponse: BaseRespnese, Codable{
    
    var code: String?
    var msg: String?
    var data: mResponse?
}
