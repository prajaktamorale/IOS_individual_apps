//
//  VideoCameraType.swift
//  Individual app
//
//  Created by Prajakta Morale on 11/17/17.
//  Copyright © 2017 Prajakta Morale. All rights reserved.
//

import AVFoundation


enum CameraType : Int {
    case back
    case front
    
    func captureDevice() -> AVCaptureDevice {
        switch self {
        case .front:
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [], mediaType: AVMediaType.video, position: .front).devices
            print("devices:\(devices)")
            for device in devices where device.position == .front {
                return device
            }
        default:
            break
        }
        return AVCaptureDevice.default(for: AVMediaType.video)!
    }
}

