//
//  AppExecutors.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/13.
//

import Foundation

/// 管理建立多執行序
protocol P_AppExecutors {
    
    /// 要執行很久的任務, 或要馬上還 mainthread 時. 才會呼叫此方法, 否則不建議呼叫
    /// - Parameter execute: <#execute description#>
    func longtimeTask(execute: @escaping @convention(block) () -> Void)
}

extension DispatchQueue {
    
    /// 取得當前 thread label 名稱
    /// - Parameter action: 會接著名稱後面印出
    static func log(action: String) {

#if DEBUG
        print("(\(String(validatingUTF8: __dispatch_queue_get_label(nil))!)) \(action)")
#endif
        
    }
}

class AppExecutors: P_AppExecutors{
    
    func longtimeTask(execute: @escaping @convention(block) () -> Void) {
        
        DispatchQueue.log(action: "AppExecutors.longtimeTask() before async thread run")
        
        AppExecutors._concurrentThreads.async {
            
            DispatchQueue.log(action: "AppExecutors.longtimeTask() before execute()")
            
            execute()
            
            DispatchQueue.log(action: "AppExecutors.longtimeTask() after execute()")
        }
        
        DispatchQueue.log(action: "AppExecutors.longtimeTask() after async thread run")
    }
    
    public static let `default`: P_AppExecutors = AppExecutors()
    
    private static let _concurrentThreads = DispatchQueue(label: "cymmetrik.GoldxTree.tw", attributes: .concurrent)
    private init() {}
    
}
