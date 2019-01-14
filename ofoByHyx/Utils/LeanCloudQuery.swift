//
//  LeanCloudQuery.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/14.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import AVOSCloud
import FTIndicator

struct LeanCloudQuery {
    
}

extension LeanCloudQuery {
    
    // 根据车牌号，查询解锁码
    static func getUnlockCode(license_plate: String, completion: @escaping (String?) -> Void) {
        let query = AVQuery.init(className: "unlock_code")
        query.whereKey("license_plate", equalTo: license_plate)
        
        query.getFirstObjectInBackground { (result, error) in
            if let error = error {
                print("query error: ", error.localizedDescription)
                FTIndicator.showInfo(withMessage: "车牌号不存在")
            }
            
            if let result = result, let unlock_code = result["unlock_code"] as? String {
                completion(unlock_code)
            }
        }
    }
    
}
