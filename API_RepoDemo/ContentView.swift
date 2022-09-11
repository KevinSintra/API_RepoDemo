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
                test()
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
    
    api.getGenericRespnse(url: "getToken", requestContent: requestData, callback: { (result: Result<GetTokenResponse?>) in
        print(result)
    })
    
}
