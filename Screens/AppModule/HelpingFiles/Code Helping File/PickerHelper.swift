//
//  PickerHelper.swift
//  TailSlate
//
//  Created by Muhammad Ahmad on 16/09/2022.
//

import Foundation
import MediaPlayer
import SystemConfiguration

extension AVAsset {
    var videoThumbnail: UIImage?{ 
        let assetImageGenerator = AVAssetImageGenerator(asset: self)
        assetImageGenerator.appliesPreferredTrackTransform = true
        var time = self.duration; time.value = min(time.value, 2)
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbNail = UIImage.init(cgImage: imageRef)
            return thumbNail
        } catch { return nil } 
    }
}
