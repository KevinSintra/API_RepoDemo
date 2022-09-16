//
//  BaseSpectro.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

public class SpectroDevice {
    
    var deviceSN: String?
    
    init(deviceSN: String) {
        
        self.deviceSN = deviceSN
    }
}

public protocol ScanSpectroDelegate {
    func foundDevice(_ device: SpectroDevice)
}

public enum SpectInteractResult{
    
    case success

    case failure(_ error: String)
}

protocol P_BaseSpectro {

    func setScanDelegate(_ delegate: ScanSpectroDelegate) -> Void
    
    func startScan() -> Void
    
    func stopScan() -> Void
    
    func connect(_ device: SpectroDevice, callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void
    
    func setSpectrometer(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void
    
    func whiteCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void

    func blackCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void
    
    func measureColor(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void

    func disconnect() -> Void
    
    func dispose() -> Void
}
