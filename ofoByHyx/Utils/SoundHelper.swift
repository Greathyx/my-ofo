//
//  SoundHelper.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/14.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import AVFoundation

struct SoundHelper {
    
}

extension SoundHelper {
    
    // 获取音频时长（秒）
    static func getDurationSecs(audioURL: URL) -> Double {
        let audioAsset = AVURLAsset.init(url: audioURL, options: nil)
        let audioDuration = audioAsset.duration
        return CMTimeGetSeconds(audioDuration)
    }
    
}
