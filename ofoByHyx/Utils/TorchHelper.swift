//
//  TorchHelper.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/13.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import AVFoundation

func changeTorchState() {
    guard let device = AVCaptureDevice.default(for: AVMediaType.video) else { return }
    
    // 如果设备有前置摄像头且摄像头可用
    if device.hasTorch && device.isTorchAvailable {
        try? device.lockForConfiguration()
        
        if device.torchMode == .on {
            device.torchMode = .off
        } else {
            device.torchMode = .on
        }
        
        device.unlockForConfiguration()
    }
}
