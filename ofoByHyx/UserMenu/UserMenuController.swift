//
//  UserMenuController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/9.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit

class UserMenuController: UITableViewController {
    
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var certificationImageView: UIImageView!
    @IBOutlet weak var certificationLabel: UILabel!
    @IBOutlet weak var creditLabel: UILabel!
    @IBOutlet weak var balanceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 修改每个section之间的间距：修改section的footer的大小
        tableView.sectionFooterHeight = 10

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // 设置头像图片为正圆形
        avatarImageView.cornerRadius = avatarImageView.frame.width / 2
    }
    
    /// 在视图加载完毕后取消第一个section的点击效果,
    /// 若在viewDidLoad()中写，则还未加载到第一个section，会报空指针
    ///
    /// - Parameter animated: Bool
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        tableView.cellForRow(at: [0, 0])?.selectionStyle = .none
    }
    
    /// 修改每个section之间的间距：修改section的header的大小
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 取消点击行则选中的状态
        tableView.deselectRow(at: indexPath, animated: true)
    }

    
    /// 选择头像监听
    ///
    /// - Parameter sender: UITapGestureRecognizer
    @IBAction func chooseAvatar(_ sender: UITapGestureRecognizer) {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let photoAction = UIAlertAction(title: "相册", style: .default) { (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else {
                return
            }
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            
            picker.delegate = self
            self.present(picker, animated: true)
        }
        
        let takePhotoAction = UIAlertAction(title: "拍照", style: .default) { (_) in
            guard UIImagePickerController.isSourceTypeAvailable(.camera) else {
                return
            }
            
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            
            picker.delegate = self
            self.present(picker, animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: .cancel)
        
        actionSheet.addAction(photoAction)
        actionSheet.addAction(takePhotoAction)
        actionSheet.addAction(cancelAction)
        
        present(actionSheet, animated: true)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
