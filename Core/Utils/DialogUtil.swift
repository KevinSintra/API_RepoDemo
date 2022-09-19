//
//  DialogUtil.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/12.
//

import UIKit

class DialogUtils {
    
    enum MyError: Error {
        case runtimeError(String)
    }
    
    private var mIndicatorDic: [UIActivityIndicatorView: UIView] = [:]
    
    
    /// 鎖定畫面的轉圈圈:  需提供當前 controller & UIActivityIndicatorView (只適用於 StoryBorad)
    /// - Parameters:
    ///   - VC: 當前的 UIViewController
    ///   - indicator: 須在 layout 上放一個轉圈圈元件
    func showActivityIndicator(VC: UIViewController, indicator: UIActivityIndicatorView) {
        
        if mIndicatorDic[indicator] == nil {
            self.mIndicatorDic[indicator] = UIView()
        }
        
        // make Background
        self.mIndicatorDic[indicator]!.frame = CGRect(x: 0.0, y: 0.0, width: VC.view.frame.size.width, height: VC.view.frame.size.height)
        self.mIndicatorDic[indicator]!.backgroundColor = UIColor.black
        self.mIndicatorDic[indicator]!.alpha = 0.3
        VC.view.addSubview(self.mIndicatorDic[indicator]!)
        
        // make lable
        let loadingTextLabel = UILabel()
        loadingTextLabel.textColor = UIColor.white
        loadingTextLabel.text = "LOADING"
        loadingTextLabel.sizeToFit()
        indicator.center = CGPoint(x: VC.view.frame.size.width / 2.0, y: VC.view.frame.size.height / 2.0)
        loadingTextLabel.center = CGPoint(x: indicator.center.x, y: indicator.center.y + 30)
        self.mIndicatorDic[indicator]!.addSubview(loadingTextLabel)
        
        // make activityIndicatorView
        indicator.hidesWhenStopped = true
        indicator.style = .medium
        indicator.color = UIColor.white
        indicator.backgroundColor = UIColor.black
        self.mIndicatorDic[indicator]!.addSubview(indicator)
        indicator.startAnimating()
    }
    
    /// 關閉轉圈圈
    /// note: 未啟動轉圈圈時會丟出例外
    /// - Parameter indicator: layout 上轉圈圈元件的參考
    func stopActivityIndicator(indicator: UIActivityIndicatorView) throws {
        if mIndicatorDic[indicator] == nil {
            throw MyError.runtimeError("請先使用 showActivityIndicator")
        }
        
        self.mIndicatorDic[indicator]!.removeFromSuperview()
        indicator.stopAnimating()
        indicator.removeFromSuperview()
    }
}
