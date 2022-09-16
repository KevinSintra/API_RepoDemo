//
//  ContentView.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import SwiftUI


struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    func makeUIView(context: UIViewRepresentableContext<ActivityIndicator>) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

struct LoadingView<Content>: View where Content: View {

    @Binding var isShowing: Bool
    var content: () -> Content

    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .center) {

                self.content()
                    .disabled(self.isShowing)
                    .blur(radius: self.isShowing ? 3 : 0)

                VStack {
                    Text("Loading...")
                    ActivityIndicator(isAnimating: .constant(false), style: .large)
                }
                .frame(width: geometry.size.width / 2,
                       height: geometry.size.height / 5)
                .background(Color.secondary.colorInvert())
                .foregroundColor(Color.primary)
                .cornerRadius(20)
                .opacity(self.isShowing ? 1 : 0)

            }
        }
    }

}

struct ContentView: View, ScanSpectroDelegate {
    
    let remote: SpectroRemote
    
    init() {
        remote = SpectroRemote(spectroTarget: .SpectroCR30)
    }
    
    var body: some View {
        
        VStack {
            Text("Hello, world!")
                .padding()

            Button("scan") {
                DispatchQueue.log(action: "scan start")
                testScna()
                DispatchQueue.log(action: "scan back")
            }.padding(5)
            
            
            Button("connect") {
                let cr30 = DebugDemoAPI.foundDevice.filter { ($0.deviceSN ?? "").contains("CM") }.first
                
                if(cr30 != nil) {
                    DispatchQueue.log(action: "connect start")
                    
                    remote.connect(device: cr30!) { result in
                        
                        DispatchQueue.log(action: "connect back")
                        switch result {
                        case .success:
                            print("connect success")
                            
//                            testSettingSpectro()
                        case .failure(let err):
                            print(err)
                        }
                    }
                }
            }.padding(5)
            
            Button("setSpectro") {
                
                testSettingSpectro()
            }.padding(5)
            
            Button("whiteCalibrate") {
                
                DispatchQueue.log(action: "whiteCalibrate start")
                remote.whiteCalibrate { result in
                    
                    DispatchQueue.log(action: "whiteCalibrate end")
                    switch result {
                    case .success:
                        print("whiteCalibrate success")
                    case .failure(let err):
                        print(err)
                    }
                }
            }.padding(5)

            Button("blackCalibrate") {
                
                DispatchQueue.log(action: "blackCalibrate start")
                remote.blackCalibrate { result in
                    
                    DispatchQueue.log(action: "blackCalibrate end")
                    switch result {
                    case .success:
                        print("blackCalibrate success")
                        
                        testSettingSpectro()
                    case .failure(let err):
                        print(err)
                    }
                }
            }.padding(5)

            Button("Masure"){
                
                DispatchQueue.log(action: "Masure start")
                remote.measureColor { result in
                    
                    DispatchQueue.log(action: "Masure end")
                    switch result {
                    case .success:
                        print("Masure success")
                        
                        testSettingSpectro()
                    case .failure(let err):
                        print(err)
                    }
                }
            }.padding(5)
            
        }
        
    }
}

var foundDevice: [SpectroDevice] = []

extension ContentView {
    
    func foundDevice(_ device: SpectroDevice) {
        
        DebugDemoAPI.foundDevice.append(device)
    }
    
    func testScna() {
        
        remote.setScanDelegate(delegate: self)
        remote.startScan()
    }
    
    func testSettingSpectro() {
        
        DispatchQueue.log(action: "setSpectro start")
        remote.setSpectrometer() { result in
            
            DispatchQueue.log(action: "setSpectro end")
            switch result {
            case .success:
                print("set spectro success")
            case .failure(let err):
                print(err)
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

func testThread() {
    let requestData = GetTokenRequest()
    requestData.action = "get"
    requestData.data!.deviceID = "e3dea0f5-37f2-4d79-ae58-490af3228069"
    
    DispatchQueue.log(action: "start")
    repoAPI.AccountHttpAPI.getUserToken(requestModel: requestData, callback: { (result: httpResult<GetTokenResponse?>) in
        DispatchQueue.log(action: "back")
        switch result {
        case .success(let obj, _):
            DispatchQueue.log(action: "success")
            print(obj)
        case .failure(let errMsg, _):
            DispatchQueue.log(action: "error")
            print(errMsg)
        }
    })
}
