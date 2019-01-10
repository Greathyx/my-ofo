//
//  AvatarSelect.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/9.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit

extension UserMenuController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        avatarImageView.image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        // 关闭相册
        picker.dismiss(animated: true, completion: nil)
    }
}
