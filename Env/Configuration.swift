//
//  Configuration.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import Foundation

/// 從 info.plist 讀取對應的 value
enum Configuration {
    
    /// KEY - EZ Print Server URL
    case EZ_Print_URL
    
    /// 對應 Key 讀出的 Value
    /// - Returns: key => value
    func Value() -> String {
        switch self {
        case .EZ_Print_URL:
            return string(for: "EZ_Print_URL").replacingOccurrences(of: "\\", with: "")
        }
    }

    // MARK: - Helper Methods

    private func string(for key: String) -> String {
        Bundle.main.infoDictionary?[key] as! String
    }

}
