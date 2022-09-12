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
