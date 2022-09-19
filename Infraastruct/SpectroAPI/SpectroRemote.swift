//
//  SpectroRemote.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

import Darwin

/// 光譜儀的控制器, 主要方便未來擴充光譜儀設備 (Adapter pattern)
public class SpectroRemote {
    
    private let _spectroService: P_BaseSpectro
    private let _appExceutors: P_AppExecutors
    /// 是否需要切換回 Main Thread
    private let _changeThreadToMain: Bool
    
    /// 讓外部註冊掃描藍芽裝置的 callback, 但不實際注入 ``P_BaseSpectro`` (簡易型的 decorator pattern)
    private var _scanDelegate: ScanSpectroDelegate?
    /// 讓外部註冊光譜儀按鈕的 callback, 但不實際注入 ``P_BaseSpectro`` (簡易型的 decorator pattern)
    private var _observeDeviceBtnDelegate: ObserveSpectroMeasureDelegate?
    
    
    /// 選擇光譜儀種類
    enum SpectroTarget {
        case SpectroCR30
    }
    
    /// 初始化設定
    /// - Parameters:
    ///   - spectroTarget: 選擇光譜儀種類 ``SpectroTarget``
    ///   - changeThreadToMain: 是否切換回 Main Thread, 預設為 `true`
    init(spectroTarget: SpectroTarget, changeThreadToMain: Bool = true) {
        
        self._changeThreadToMain = changeThreadToMain
        self._appExceutors = AppExecutors.default
        
        switch spectroTarget {
        case .SpectroCR30:
            self._spectroService = SpectroCR30()
        }
        
        self._spectroService.setScanDelegate(self)
        self._spectroService.setMeasureObsevable(self)
    }
    
    /// 依據設定執行最後的回調方法
    /// - Parameter execute: `() -> Void`
    /// - Returns: Void
    private func _howToRun(execute: @escaping @convention(swift) () -> Void) -> Void {
        
        if(self._changeThreadToMain) {
            
            self._appExceutors.changeMainQueue {
                execute()
            }
        }
        else {
            
            execute()
        }
    }
    
    /// 設定搜尋設備的 delagate
    /// - Parameter delegate: ``ScanSpectroDelegate``
    /// - Returns: Void
    func setScanDelegate(delegate: ScanSpectroDelegate) -> Void {
        
        self._scanDelegate = delegate
    }
    
    /// 尋找設備, 需先執行 ``setScanDelegate(delegate:)``
    /// - Returns: 成功 `true`, 失敗 `false`
    func startScan() -> Bool {
        
        guard self._scanDelegate != nil else {
            
            logUtils.printSomething("need to setScanDelegate before start scan.")
            return false
        }
        
        self._spectroService.startScan()
        return true
    }
    
    /// 停止搜尋
    /// - Returns: Void
    func stopScan() -> Void {
        
        self._spectroService.stopScan()
    }
    
    /// 連接光譜儀
    /// - Parameters:
    ///   - device: ``SpectroDevice``
    ///   - callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func connect(device: SpectroDevice, callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        self._spectroService.connect(device) { result in
            
            self._howToRun {
                callback(result)
            }
        }
    }
    
    /// 白校準
    /// - Parameter callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func whiteCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        self._spectroService.whiteCalibrate { result in
            
            self._howToRun {
                callback(result)
            }
        }
    }
    
    /// 黑校準
    /// - Parameter callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func blackCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        self._spectroService.blackCalibrate { result in
            
            switch result {
            case .success:  // 黑校準成功後設定光譜儀
                self._spectroService.setSpectrometer { result in
                    
                    self._howToRun {
                        callback(result)
                    }
                }
            case .failure(_):
                self._howToRun {
                    callback(result)
                }
            }
            
        }
    }
    
    /// 量測顏色的光譜
    /// - Parameter callback: `(SpectInteractDataResult<SpectroColorInfo>) -> Void`
    /// - Returns: Void
    func measureColor(remoteCallback: @escaping @convention(swift) (SpectInteractDataResult<SpectroColorInfo>) -> Void) {
        
        self._spectroService.measureColor { result in
            
            self._howToRun {
                remoteCallback(result)
            }
        }
    }
    
    /// 設定觀察光譜儀按鈕的 observe
    /// - Parameter delegate: ``ObserveSpectroMeasureDelegate``
    /// - Returns: Void
    func setMeasureObsevable(_ delegate: ObserveSpectroMeasureDelegate) {
        
        self._observeDeviceBtnDelegate = delegate
    }
    
    func dispose() {
        self._spectroService.dispose()
    }
    
    deinit {
        
        self._spectroService.dispose()
    }
}

// MARK: 注入掃描光譜儀設備 & 觀察光譜儀按鈕的 callback
// simple decorator pattern
extension SpectroRemote: ScanSpectroDelegate, ObserveSpectroMeasureDelegate {
    
    public func foundDevice(_ device: SpectroDevice) {
        
        if(self._scanDelegate != nil) {
            
            self._howToRun {
                
                self._scanDelegate!.foundDevice(device)
            }
        }
        
    }
    
    public func observeDeviceMeasureBtn(_ colorIfo: SpectroColorInfo) {
        
        if(self._observeDeviceBtnDelegate != nil) {
            
            self._howToRun {
                
                self._observeDeviceBtnDelegate!.observeDeviceMeasureBtn(colorIfo)
            }
        }
        
    }
}
