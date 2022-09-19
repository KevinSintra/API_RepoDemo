//
//  BaseSpectro.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

/// 封裝光譜儀 SDK. 主要將資料的部分抽換成一般類別, 觀察者模式改為 delegate 不直接依賴 rxSwift obsvable. 也方便未來擴充.
protocol P_BaseSpectro {
    
//    typealias aliasVoidCallback = (SpectInteractResult) -> Void
    
    /// 設定搜尋設備的 delagate
    /// - Parameter delegate: ``ScanSpectroDelegate``
    /// - Returns: Void
    func setScanDelegate(_ delegate: ScanSpectroDelegate) -> Void
    
    /// 尋找設備, 需先執行 ``setScanDelegate(_:)``
    /// - Returns: Void
    func startScan() -> Void
    
    /// 停止搜尋
    /// - Returns: Void
    func stopScan() -> Void
    
    /// 連接光譜儀
    /// - Parameters:
    ///   - device: ``SpectroDevice``
    ///   - callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func connect(_ device: SpectroDevice, callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void
    
    /// 設定 D50, 2 degree, 色域空間 SCIE
    /// - Parameter callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func setSpectrometer(setCallback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void
    
    /// 白校準
    /// - Parameter callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func whiteCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void

    /// 黑校準
    /// - Parameter callback: `(SpectInteractResult) -> Void`
    /// - Returns: Void
    func blackCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void
    
    /// 設定觀察光譜儀按鈕的 observe
    /// - Parameter delegate: ``ObserveSpectroMeasureDelegate``
    /// - Returns: Void
    func setMeasureObsevable(_ delegate: ObserveSpectroMeasureDelegate) -> Void
    
    /// 量測顏色的光譜
    /// - Parameter callback: `(SpectInteractDataResult<SpectroColorInfo>) -> Void`
    /// - Returns: Void
    func measureColor(callback: @escaping @convention(swift) (SpectInteractDataResult<SpectroColorInfo>) -> Void) -> Void
    
    /// 關閉光譜儀連線
    /// - Returns: Void
    func disconnect() -> Void
    
    /// 釋放光譜儀 SDK instance
    /// - Returns: Void
    func dispose() -> Void
}

/// 與光譜儀互動的結果, 不含資料的
public enum SpectInteractResult{
    
    case success

    case failure(_ error: String)
}

/// 與光譜儀互動的結果, 包含資料的
public enum SpectInteractDataResult<T> {
    
    case successHasData(_ obj: T)
    
    case failure(_ error: String)
}

/// 委派: 搜尋藍芽設備
public protocol ScanSpectroDelegate {
    
    /// 找到設備時會回調該方法
    /// - Parameter device: ``SpectroDevice``
    func foundDevice(_ device: SpectroDevice)
}
/// 光譜儀
public class SpectroDevice {
    
    /// 設備的唯一值
    var deviceSN: String?
    
    init(deviceSN: String) {
        
        self.deviceSN = deviceSN
    }
}

/// 委派: 觀察光僕儀測量的按鈕
public protocol ObserveSpectroMeasureDelegate {
    
    func observeDeviceMeasureBtn(_ colorIfo: SpectroColorInfo)
}
/// 顏色的光譜資訊 (光譜不會有 D50 or D65)
public class SpectroColorInfo {
    
    /// 光譜波長從 400 ~ 700 共 31 個數值
    var spectroInfo: [Float32]?
    
    init(spectroInfo: [Float32]) {
        
        self.spectroInfo = spectroInfo
    }
}
