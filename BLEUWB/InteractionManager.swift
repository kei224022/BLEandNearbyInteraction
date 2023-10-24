//
//  InteractionManager.swift
//  BLEUWB
//
//  Created by member on 2023/10/24.
//

import Foundation
import CoreBluetooth
import NearbyInteraction

// Define your custom service and characteristic UUIDs
let serviceUUID = CBUUID(string: "YOUR-SERVICE-UUID")
let characteristicUUID = CBUUID(string: "YOUR-CHARACTERISTIC-UUID")

class InteractionManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, NISessionDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var niSession: NISession!
    var discoveredPeripheral: CBPeripheral?
    var writableCharacteristic: CBCharacteristic?
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        niSession = NISession()
        niSession.delegate = self
    }
    
    // ... (rest of the CoreBluetooth and NearbyInteraction methods as shown in the previous example)
    // MARK: - CoreBluetooth Methods

       func centralManagerDidUpdateState(_ central: CBCentralManager) {
           if central.state == .poweredOn {
               centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
           }
       }

       func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
           discoveredPeripheral = peripheral
           centralManager.connect(peripheral, options: nil)
       }

       func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
           peripheral.delegate = self
           peripheral.discoverServices([serviceUUID])
       }

    // CBPeripheralDelegate methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
            for service in peripheral.services! {
                if service.uuid == serviceUUID {
                    peripheral.discoverCharacteristics([characteristicUUID], for: service)
                }
            }
        }

       func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
           for characteristic in service.characteristics! {
               if characteristic.uuid == characteristicUUID {
                   writableCharacteristic = characteristic
                   // Now you can use the characteristic to write data (your token)
               }
           }
       }

       func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
           if peripheral.state == .poweredOn {
               let service = CBMutableService(type: serviceUUID, primary: true)
               let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: .write, value: nil, permissions: .writeable)
               service.characteristics = [characteristic]
               peripheralManager.add(service)
           }
       }

       // MARK: - NearbyInteraction Methods

       func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
           for object in nearbyObjects {
               print("Nearby object found: \(object)")
           }
       }
}
