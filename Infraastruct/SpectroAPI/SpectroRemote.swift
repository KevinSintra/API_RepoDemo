//
//  SpectroRemote.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

public class SpectroRemote {
    
    private let _spectroService: P_BaseSpectro
    
    init(spectroTarget: SpectroTarget) {
        
        switch spectroTarget {
        case .SpectroCR30:
            self._spectroService = SpectroCR30()
        }
    }
    
    func setScanDelegate(delegate: ScanSpectroDelegate) -> Void {
        
        self._spectroService.setScanDelegate(delegate)
    }
    
    func startScan() -> Void {
        
        self._spectroService.startScan()
    }
    
    func stopScan() -> Void {
        
        self._spectroService.stopScan()
    }
    
    func connect(device: SpectroDevice, callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        self._spectroService.connect(device) { result in
            callback(result)
        }
    }
    
    func disconnect() -> Void {
        
        self._spectroService.disconnect()
    }
    
    func dispose() -> Void {
        
        self._spectroService.dispose()
    }
    
    func setSpectrometer(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void {
        
        self._spectroService.setSpectrometer { result in
            callback(result)
        }
    }
    
    func whiteCalibrate(callback: @escaping (SpectInteractResult) -> Void) {
        
        self._spectroService.whiteCalibrate { result in
            callback(result)
        }
    }
    
    func blackCalibrate(callback: @escaping (SpectInteractResult) -> Void) {
        
        self._spectroService.blackCalibrate { result in
            callback(result)
        }
    }
    
    func measureColor(callback: @escaping (SpectInteractResult) -> Void) {
        
        self._spectroService.measureColor { result in
            callback(result)
        }
    }
    
    enum SpectroTarget {
        case SpectroCR30
    }
}
