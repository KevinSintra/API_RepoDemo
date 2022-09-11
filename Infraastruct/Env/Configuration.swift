//
//  Configuration.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/7.
//

import Foundation

enum Configuration {
    
    case EZ_Print_URL
    
    func Value() -> String {
        switch self {
        case .EZ_Print_URL:
            return string(for: "EZ_Print_URL").replacingOccurrences(of: "\\", with: "")
        }
    }

    // MARK: - Helper Methods

    private func string(for key: String) -> String {
        Bundle.main.infoDictionary?[key] as! String
//        Bundle.main.dictionaryWithValues(keys: ["EZ_Print_URL"])
    }

}
