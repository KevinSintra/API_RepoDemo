//
//  GetTokenMdoel.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/8.
//

class mRequest: Codable{
    var deviceID: String?
}

class GetTokenRequest: BaseRequest, Codable{

    typealias dataType = mRequest
    var action: String?
    var deviceSN: String?
    var data: dataType? = mRequest()
}

class mResponse: Codable {
    var token: String?
}

class GetTokenResponse: BaseRespnese, Codable{
    
    var code: String?
    var msg: String?
    var data: mResponse?
}
