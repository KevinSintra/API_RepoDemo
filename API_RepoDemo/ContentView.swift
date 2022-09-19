//
//  ContentView.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import SwiftUI

// MARK: 測試 => API Repo && 封裝光譜儀 SDK API

struct ContentView: View, ScanSpectroDelegate {
    
    let remote: SpectroRemote
    
    init() {
        
        self.remote = SpectroRemote(spectroTarget: .SpectroCR30) // switch main thread
//        remote = SpectroRemote(spectroTarget: .SpectroCR30, changeThreadToMain: false) // not switch
        self.remote.setScanDelegate(delegate: self)
    }
    
    var body: some View {
        
        VStack {
            Text("Hello, world!")
                .padding()

            Button("scan") {
                DispatchQueue.log(action: "ContentView: scan start")
                
                _ = remote.startScan()
                
                DispatchQueue.log(action: "ContentView: scan back")
            }.padding(5)
            
            
            Button("connect") {
                let cr30 = DebugDemoAPI.foundDevice.filter { ($0.deviceSN ?? "").contains("CM") }.first
                
                if(cr30 != nil) {
                    DispatchQueue.log(action: "ContentView: connect start")
                    
                    self.remote.connect(device: cr30!) { result in
                        
                        DispatchQueue.log(action: "ContentView: connect back")
                        switch result {
                        case .success:
                            print("ContentView: connect success")
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
            }.padding(5)
            
            Button("whiteCalibrate") {
                
                DispatchQueue.log(action: "ContentView: whiteCalibrate start")
                self.remote.whiteCalibrate { result in
                    
                    DispatchQueue.log(action: "ContentView: whiteCalibrate end")
                    switch result {
                    case .success:
                        print("ContentView: whiteCalibrate success")
                    case .failure(let err):
                        print(err)
                    }
                }
            }.padding(5)

            Button("blackCalibrate") {
                
                DispatchQueue.log(action: "ContentView: blackCalibrate start")
                self.remote.blackCalibrate { result in
                    
                    DispatchQueue.log(action: "ContentView: blackCalibrate end")
                    switch result {
                    case .success:
                        print("ContentView: blackCalibrate success")
                    case .failure(let err):
                        print(err)
                    }
                }
            }.padding(5)

            Button("Masure") {
                
                DispatchQueue.log(action: "ContentView: Masure start")
                
                self.remote.measureColor { result in
                    DispatchQueue.log(action: "ContentView: Masure end")
                    
                    switch result {
                    case .successHasData(let data):
                        print("ContentView: Masure success")
                        print(data)
                    case .failure(let err):
                        print(err)
                    }
                }
                
            }.padding(5)
            
            
            Button("Dispose") {
                DispatchQueue.log(action: "ContentView: Dispose")
                
                self.remote.dispose()
            }.padding(5)
        }
        
    }
}

var foundDevice: [SpectroDevice] = [] // 儲存找到的藍芽設備集合

extension ContentView {
    
    /// 當 API 找到藍芽裝置時的 callback
    /// - Parameter device: `SpectroDevice`
    func foundDevice(_ device: SpectroDevice) {
        
        DebugDemoAPI.foundDevice.append(device)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
    
}

/// `ManagerAPI` 測試打 API
func testManagerCoreAPI() {
    let requestData = GetTokenRequest()
    requestData.action = "get"
    requestData.data!.deviceID = "e3dea0f5-37f2-4d79-ae58-490af3228069"
    
    let api: P_ManagerAPI = ManagerAPI()
    
    api.getGenericRespnse(urlPath: "getToken", requestContent: requestData, callback: { (result: ResponseResult<GetTokenResponse?>) in
        print(result)
    })
    
}

let repoAPI: P_PepoAPIs  = RepoAPIs.default

/// `RepoAPIs` 測試打 API
func testRepoAPIs() {
    
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

/// 測試使用 AF 打 API 後, Thread 是否為 Main. (是的, 他會切回 .main thread)
func testThread() {
    let requestData = GetTokenRequest()
    requestData.action = "get"
    requestData.data!.deviceID = "e3dea0f5-37f2-4d79-ae58-490af3228069"
    
    DispatchQueue.log(action: "start")
    repoAPI.AccountHttpAPI.getUserToken(requestModel: requestData, callback: { (result: httpResult<GetTokenResponse?>) in
        DispatchQueue.log(action: "back")
        switch result {
        case .success(let obj, _):
            DispatchQueue.log(action: "ContentView: success")
            print(obj)
        case .failure(let errMsg, _):
            DispatchQueue.log(action: "ContentView: error")
            print(errMsg)
        }
    })
}
