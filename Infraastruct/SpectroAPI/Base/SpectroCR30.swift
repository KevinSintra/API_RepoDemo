//
//  SpectroCR30.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

import ColorMeterKit
import RxSwift
import CoreBluetooth

class SpectroCR30: P_BaseSpectro {
//    AppExecutors.default.
    private let cm = CMKit(queue: AppExecutors.default.AppDispatchQueue)
    private var disposable: Disposable?
    private var deviceDic: [String: CBPeripheral] = [:]
    private var targetDevice: SpectroDevice?
    private var scanDelegate: ScanSpectroDelegate?
    
    init() {
        
        self.disposable = self.cm.observeScanned()
            .subscribe(
                onNext: { [weak self] cmState in
                    
                    guard let delegate = self?.scanDelegate,
                          let peripheral = cmState.peripheral,
                          let peripheralName = cmState.peripheral?.name,
                          let strongSelf = self else {
                        
                        logUtils.printSomething("scan bluetooth device is empty")
                        return
                    }
                    
                    strongSelf.deviceDic[peripheralName] = peripheral
                    let device = SpectroDevice(deviceSN: peripheralName)
                    delegate.foundDevice(device)
                },
                onError: { logUtils.printSomething("scan error: \($0)") },
                onCompleted: { logUtils.printSomething("scan complete") },
                onDisposed: { logUtils.printSomething("scan disposed") }
            )
    }
    
    func setScanDelegate(_ delegate: ScanSpectroDelegate) {
        
        self.scanDelegate = delegate
    }
    
    func startScan() {
        
        self.disconnect()
        
        if (!self.cm.isScanning) {
            
            logUtils.printSomething("startScan")
            self.cm.startScan()
        }
        else {
            self.stopScan()
        }
        
    }
    
    
    func stopScan() {
        
        if self.cm.isScanning {
            
            logUtils.printSomething("stopScan")
            self.cm.stopScan()
        }
        self.disposable?.dispose()
    }
    
    func connect(_ device: SpectroDevice, callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        guard let findDevice: CBPeripheral = self.deviceDic[device.deviceSN ?? ""] else {
            
            callback(.failure("not found device: \(device.deviceSN ?? "")"))
            return
        }
        
        _ = self.cm.connect(findDevice).subscribe(
            onNext: { [weak self] cmState in
                
                guard let strongSelf = self, cmState.state == CMState.State.connected else {
                    
                    callback(.failure("connect state error"))
                    return
                }
                
                self?.stopScan()
                strongSelf.targetDevice = SpectroDevice(deviceSN: findDevice.name!)
                callback(.success)
            },
            onError: { err in
                
                callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
                logUtils.printSomething("connection error: \(err)")
            },
            onDisposed: { logUtils.printSomething("connector dispose") }
        )
        
    }
    
    func setSpectrometer(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void {
        
        _ = self.cm.setDisplayParameter(.init(
            firstLightSource: LightSource(angle: .deg2, category: .D50),
            secondLightSource: LightSource(angle: .deg2, category: .D50),
            measureMode: .SCI,
            colorMode: .CIELab,
            differenceFormula: .dE_00
        ))
        .subscribe(onNext: { _ in
            
            logUtils.printSomething("setSpectrometer onNext")
            callback(.success)
        }, onError: { err in
            
            logUtils.printSomething("setSpectrometer err: \(err)")
            callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
        }, onCompleted: { logUtils.printSomething("setSpectrometer onCompleted")
        }, onDisposed: { logUtils.printSomething("setSpectrometer onDisposed") })
    }
    
    func whiteCalibrate(callback: @escaping (SpectInteractResult) -> Void) {
        
        _ = self.cm.whiteCalibrate().subscribe(
            onNext: { _ in
                
                logUtils.printSomething("whiteCalibrate success")
                callback(.success)
            },
            onError: { err in
                logUtils.printSomething("whiteCalibrate  err: \(err)")
                
                callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
            }
        )
    }
    
    func blackCalibrate(callback: @escaping (SpectInteractResult) -> Void) {
        
        _ = self.cm.blackCalibrate().subscribe(
            onNext: { _ in
                
                logUtils.printSomething("blackCalibrate success")
                callback(.success)
            },
            onError: { err in
                logUtils.printSomething("blackCalibrate  err: \(err)")
                
                callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
            }
        )
    }
    
    func measureColor(callback: @escaping (SpectInteractResult) -> Void) {
        
        _ = self.cm.measureWithResponse().subscribe(
            onNext: { data in
                
                logUtils.printSomething(data?.refs.map{ String($0) }.joined(separator:", ") ?? "")
                logUtils.printSomething("measureColor success")
                callback(.success)
            },
            onError: { err in
                
                logUtils.printSomething("measureColor  err: \(err)")
                callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
            }
        )
    }
    
    func disconnect() {
        
        _ = self.cm.disconnect().subscribe(onNext: { _ in
            logUtils.printSomething("disconnect")
        })
    }
    
    func dispose() {
        
        self.stopScan()
        self.disconnect()
    }
    
}
