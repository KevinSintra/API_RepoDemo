//
//  LogUtils.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

class logUtils {
    
    static func printSomething(_ item: String) {
        
#if DEBUG
        print(item)
#endif
    }
    
}
