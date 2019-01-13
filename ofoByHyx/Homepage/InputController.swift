//
//  InputController.swift
//  ofoByHyx
//
//  Created by 黄小白 on 2019/1/13.
//  Copyright © 2019 Sherley Huang's studio. All rights reserved.
//

import UIKit

extension HomeController {
    
    /// 键盘将要显示监听
    @objc func keyboardWillShow(notification: NSNotification) {
        // 得到键盘的frame
        let userInfo: NSDictionary = notification.userInfo! as NSDictionary
        let value = userInfo.object(forKey: UIResponder.keyboardFrameEndUserInfoKey)
        let keyboardRec = (value as AnyObject).cgRectValue!
        
        let deltaY = keyboardRec.size.height
        
        // 让 inputPanelView 的底部位置在键盘顶部
        UITextView.animate(withDuration: 0.1, animations: {
            self.inputPanelView.transform = CGAffineTransform(translationX: 0, y: -deltaY)
        })
    }
    
    /// 键盘将要隐藏监听
    @objc func keyboardWillHide(notification: NSNotification) {
        // 让 inputPanelView 位置还原
        UITextView.animate(withDuration: 0.1, animations: {
            self.inputPanelView.transform = .identity
        })
    }
    
    /// 设置手动输入车牌号位数不超过8位
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = inputTextField.text else {
            return true
        }
        
        let newLength = text.count + string.count - range.length
        if newLength > 0 {
            useBikeBtn_input.layer.backgroundColor = UIColor(named: "themeColor")?.cgColor
        } else {
            useBikeBtn_input.layer.backgroundColor = UIColor(displayP3Red: 206/255, green: 206/255, blue: 206/255, alpha: 1).cgColor
        }
        
        return newLength <= 8
    }
    
}
