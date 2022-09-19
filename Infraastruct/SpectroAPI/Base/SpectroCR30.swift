//
//  SpectroCR30.swift
//  API_RepoDemo
//
//  Created by CymmetrikDev2 on 2022/9/15.
//

import ColorMeterKit
import RxSwift
import CoreBluetooth

/// CR-30 光譜儀
class SpectroCR30: P_BaseSpectro {
    
    /// CR30 SDK
    private let _cm: CMKit
    
    /// observe 藍芽設備搜尋
    private var _bleDeviceScanDisposable: Disposable?
    /// 當搜尋到 CR30 時的 callback
    private var _scanDelegate: ScanSpectroDelegate?
    
    /// 搜尋到的 CR30 集合
    private var _foundDeviceDic: [String: CBPeripheral] = [:]
    /// 當前連接的 CR30
    private var _targetConnectedDevice: SpectroDevice?
    
    /// observe 光譜儀上方那顆按鈕
    private var _observeDeviceBtnDisposable: Disposable?
    /// 當有人按下那顆按鈕時的 callback
    private var _observeDeviceBtnDelegate: ObserveSpectroMeasureDelegate?

    
    init() {
        
        self._cm = CMKit(queue: AppExecutors.default.AppDispatchQueue)
        
        /*
         NOTE: 為什麼要先設定這段呢？
            因為 IOS 官方提供的 Bluetooth Core API, 初始化的方式是透過狀態機, 若未啟動就執行任何方法將會先執行初始化, 需花費一段時間,
         這段期間收到的任何指令將不被執行. 所以才先設定這段.
         */
        self._bleDeviceScanDisposable = self._cm.observeScanned()
            .subscribe(
                onNext: { [weak self] cmState in
                    
                    guard let delegate = self?._scanDelegate,
                          let peripheral = cmState.peripheral,
                          let peripheralName = cmState.peripheral?.name,
                          peripheralName.contains("CM"),
                          let strongSelf = self else {
                        
                        logUtils.printSomething("scan bluetooth device is empty, or it's not CR30 spectro")
                        return
                    }
                    
                    if(!strongSelf._foundDeviceDic.keys.contains(peripheralName)) {
                        
                        strongSelf._foundDeviceDic[peripheralName] = peripheral
                        let device = SpectroDevice(deviceSN: peripheralName)
                        delegate.foundDevice(device)
                    }
                },
                onError: { logUtils.printSomething("scan error: \($0)") },
                onCompleted: { logUtils.printSomething("scan complete") },
                onDisposed: { logUtils.printSomething("scan disposed") }
            )
    }
    
    // MARK: 連接光譜儀需執行的動作
    
    func setScanDelegate(_ delegate: ScanSpectroDelegate) {
        
        self._scanDelegate = delegate
    }
    
    func startScan() {
        
        self.disconnect()
        
        if (!self._cm.isScanning) {
            
            logUtils.printSomething("startScan")
            self._cm.startScan()
        }
        else {
            self.stopScan()
        }
        
    }
    
    func stopScan() {
        
        if self._cm.isScanning {
            
            logUtils.printSomething("stopScan")
            self._cm.stopScan()
        }
        self._bleDeviceScanDisposable?.dispose()
    }
    
    func connect(_ device: SpectroDevice, callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        // NOTE: 剛連接完成時, 不要執行跟光譜儀的任何動作不然會 timeout, 測試需等至少 2 sec.
        
        guard let findDevice: CBPeripheral = self._foundDeviceDic[device.deviceSN ?? ""] else {
            
            callback(.failure("not found device: \(device.deviceSN ?? "")"))
            return
        }
        
        _ = self._cm.connect(findDevice).subscribe(
            onNext: { [weak self] cmState in
                
                guard let strongSelf = self, cmState.state == CMState.State.connected else {
                    
                    callback(.failure("connect state error"))
                    return
                }
                
                strongSelf.stopScan()
                strongSelf._targetConnectedDevice = SpectroDevice(deviceSN: findDevice.name!)
                callback(.success)
            },
            onError: { err in
                
                callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
                logUtils.printSomething("connection error: \(err)")
            },
            onDisposed: { logUtils.printSomething("connector dispose") }
        )
        
    }
    
    // MARK: 連接光譜儀後需執行設定與校正
    
    func setSpectrometer(setCallback: @escaping @convention(swift) (SpectInteractResult) -> Void) -> Void {
        
        // 設定 D50, 2 degree, 色域空間 SCIE
        _ = self._cm.setDisplayParameter(.init(
            firstLightSource: LightSource(angle: .deg2, category: .D50),
            secondLightSource: LightSource(angle: .deg2, category: .D50),
            measureMode: .SCI,
            colorMode: .CIELab,
            differenceFormula: .dE_00
        ))
        .subscribe(onNext: { _ in
            
            logUtils.printSomething("setSpectrometer onNext")
            setCallback(.success)
        }, onError: { err in
            
            logUtils.printSomething("setSpectrometer err: \(err)")
            setCallback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
        }, onCompleted: { logUtils.printSomething("setSpectrometer onCompleted")
        }, onDisposed: { logUtils.printSomething("setSpectrometer onDisposed") })
    }
    
    func whiteCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        _ = self._cm.whiteCalibrate().subscribe(
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
    
    func blackCalibrate(callback: @escaping @convention(swift) (SpectInteractResult) -> Void) {
        
        _ = self._cm.blackCalibrate().subscribe(
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
    
    // MARK: 測量相關的行為

    func measureColor(callback: @escaping @convention(swift) (SpectInteractDataResult<SpectroColorInfo>) -> Void) {
        
        // TODO: 初步測試這個方法同時也會觸發 setMeasureObsevable() 的 observe. 等新的光譜儀來之後再確認
        _ = self._cm.measureWithResponse().subscribe(
            onNext: { data in
                
                //logUtils.printSomething(data?.refs.map{ String($0) }.joined(separator:", ") ?? "")
                DispatchQueue.log(action: "measureColor() success")
                let spectroData = data?.refs ?? [0]
                let colorInfo = SpectroColorInfo(spectroInfo: spectroData) // as! T
                
                callback(.successHasData(colorInfo))
            },
            onError: { err in
                
                DispatchQueue.log(action: "measureColor()  err: \(err)")
                callback(.failure(err.asAFError?.errorDescription ?? err.localizedDescription))
            }
        )
    }
    
    // TODO: setMeasureObsevable 因光譜儀設備按鈕壞掉, 所以這段還未測試
    func setMeasureObsevable(_ delegate: ObserveSpectroMeasureDelegate) -> Void {
        
        self._observeDeviceBtnDelegate = delegate
        
        if(self._observeDeviceBtnDisposable == nil) {
            self._observeDeviceBtnDisposable = self._cm.observeMeasure()
                .concatMap { _ in
                    return self._cm.getMeasureData()
                }
                .subscribe(
                    onNext: { data in
                        
                        DispatchQueue.log(action: "setMeasureObsevable() success")
                        let spectroData = data?.refs ?? [0]
                        let colorInfo = SpectroColorInfo(spectroInfo: spectroData)
                        
                        self._observeDeviceBtnDelegate?.observeDeviceMeasureBtn(colorInfo)
                    },
                    onError:{ error in
                        DispatchQueue.log(action: "setMeasureObsevable() error: \(error)")
                    },
                    onCompleted: { DispatchQueue.log(action: "setMeasureObsevable() onCompleted") })
        }
        
    }
    
    // MARK: 關閉連線與釋放資源
    
    func disconnect() {
        
        _ = self._cm.disconnect().subscribe(onNext: { _ in
            logUtils.printSomething("disconnect")
        })
    }
    
    func dispose() {
        
        self._observeDeviceBtnDisposable?.dispose()
        self.stopScan()
        self.disconnect()
    }
    
}
