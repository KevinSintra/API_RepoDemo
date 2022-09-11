//
//  ContentView.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Hello, world!")
                .padding()
            
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                test2()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}

func test() {
    let requestData = GetTokenRequest()
    requestData.action = "get"
    requestData.data!.deviceID = "e3dea0f5-37f2-4d79-ae58-490af3228069"
    
    let api: P_ManagerAPI = ManagerAPI()
    
    api.getGenericRespnse(urlPath: "getToken", requestContent: requestData, callback: { (result: ResponseResult<GetTokenResponse?>) in
        print(result)
    })
    
}

let repoAPI: P_PepoAPIs  = RepoAPIs.default

func test2() {
    let requestData = GetTokenRequest()
    requestData.action = "get"
    requestData.data!.deviceID = "e3dea0f5-37f2-4d79-ae58-490af3228069"
    
    repoAPI.AccountHttpAPI.getUserToken(requestModel: requestData, callback: { (result: httpResult<GetTokenResponse?>) in
        switch result {
        case .success(let obj, _):
            print(obj)
        case .failure(let errMsg, _):
            print(errMsg)
        }
    })
}
