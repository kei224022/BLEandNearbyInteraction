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
let serviceUUID = CBUUID(string: "5A59EA39-CD9B-8913-A742-33A5784D5227")
let characteristicUUID = CBUUID(string: "4D3872C6-4E58-6599-AE2A-76DA9225B923")

class InteractionManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralManagerDelegate, NISessionDelegate, CBPeripheralDelegate {
    var centralManager: CBCentralManager!
    var peripheralManager: CBPeripheralManager!
    var niSession: NISession!
    var discoveredPeripheral: CBPeripheral?
    var writableCharacteristic: CBCharacteristic?
    
    @Published var DeviceU: String = ""
    
    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        peripheralManager = CBPeripheralManager(delegate: self, queue: nil)
        niSession = NISession()
        niSession.delegate = self
        print("InteractionManager initialized")
    }
    
    // MARK: - CoreBluetooth Methods

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("Central Manager State: \(central.state.rawValue)")
        if central.state == .poweredOn {
            centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil)
            print("Scanning for peripherals...")
        }
    }

    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
        print("Discovered peripheral: \(peripheral)")
        discoveredPeripheral = peripheral
        centralManager.connect(peripheral, options: nil)
        print("Connecting to peripheral...")
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Connected to peripheral: \(peripheral)")
        peripheral.delegate = self
        peripheral.discoverServices([serviceUUID])
        print("Discovering services...")
    }

    // CBPeripheralDelegate methods
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        print("Services discovered: \(String(describing: peripheral.services))")
        for service in peripheral.services! {
            if service.uuid == serviceUUID {
                peripheral.discoverCharacteristics([characteristicUUID], for: service)
                print("Discovering characteristics for service: \(service)")
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        print("Characteristics discovered for service: \(service)")
        for characteristic in service.characteristics! {
            if characteristic.uuid == characteristicUUID {
                writableCharacteristic = characteristic
                print("Writable characteristic discovered: \(characteristic)")
                // Now you can use the characteristic to write data (your token)
            }
        }
    }

    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        print("Peripheral Manager State: \(peripheral.state.rawValue)")
        if peripheral.state == .poweredOn {
            let service = CBMutableService(type: serviceUUID, primary: true)
            let characteristic = CBMutableCharacteristic(type: characteristicUUID, properties: .write, value: nil, permissions: .writeable)
            service.characteristics = [characteristic]
            peripheralManager.add(service)
            print("Service and characteristic added to peripheral manager")
        }
    }

    // MARK: - NearbyInteraction Methods

    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        for object in nearbyObjects {
            print("Nearby object found: \(object)")
            self.DeviceU = String(1)
        }
    }
}
