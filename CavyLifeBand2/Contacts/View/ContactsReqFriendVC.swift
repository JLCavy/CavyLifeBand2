//
//  VerifyViewController.swift
//  CavyLifeBand2
//
//  Created by Jessica on 16/3/18.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import UIKit
import MHRotaryKnob
import Log

class ContactsReqFriendVC: UIViewController, BaseViewControllerPresenter, UITextFieldDelegate {
    
    enum RequestStyle {
        
        case AddFriend
        case ChangeNotesName
        case ChangeSelfName
        
    }
    
    /// 最大输入18个字符
    let MAX_COUNT = 18
    
    var viewModel: ContactsReqFriendPortocols?
    
    @IBOutlet weak var textFieldView: UIView!
    
    /// TextField
    @IBOutlet weak var requestTextField: UITextField!
    
    /// Button
    @IBOutlet weak var sendButton: MainPageButton!
    
    var requestStyle: RequestStyle = .AddFriend
    
    var navTitle: String {
        
        return viewModel?.navTitle ?? ""
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(named: .HomeViewMainColor)
        
        requestTextField.delegate = self
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(ContactsReqFriendVC.textChange(_:)), name: UITextFieldTextDidChangeNotification, object: nil)
        
        updateNavUI()
        
        requestViewLayout()
        
    }
    
    
    /**
     点击发送按钮
     
     - parameter sender:
     */
    @IBAction func sendRequest(sender: AnyObject) {
        
        viewModel?.textFieldTitle = requestTextField.text ?? ""
        viewModel?.onClickButton()
        
    }
    
    
    
    /**
     配置视图
     
     - parameter dataSource:
     */
    func viewConfig(model: ContactsReqFriendPortocols) {
        
        self.viewModel = model
        
    }
    
    /**
     布局
     */
    func requestViewLayout() {
        
        textFieldView.layer.cornerRadius = CavyDefine.commonCornerRadius
        sendButton.layer.masksToBounds = true
        sendButton.layer.cornerRadius = 3
        
        sendButton.setTitle(viewModel?.bottonTitle, forState: .Normal)
        
        requestTextField.placeholder = viewModel?.placeholderText
        requestTextField.text = viewModel?.textFieldTitle
        requestTextField.textColor = UIColor(named: .TextFieldTextColor)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    func textChange(Noti: NSNotification) {
        
        if requestTextField.markedTextRange != nil {
            
            return
        }
        
        let string = requestTextField.text
        
        
        requestTextField.text = confineTextFiledText(string) as String
        
    }
    
    
    //MARK: UITextFieldDelegate
    
    /**
     限制输入的字符长度为18
     */
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        
        
        if string.length == 0 || textField.markedTextRange != nil {
            
            return true
        }
        
        let text: NSString =  (textField.text! as NSString).stringByReplacingCharactersInRange(range, withString: string)
        
        if text.length > MAX_COUNT {
            
            return false
        }
        
        return true
        
    }
    
    
    
    func confineTextFiledText(text: NSString?) -> NSString {
        
        let length = text?.lengthOfBytesUsingEncoding(NSUTF8StringEncoding)
        var newText = text
        
        if length > MAX_COUNT {
            
            newText  = confineTextFiledText(newText?.substringToIndex(newText!.length - 1))
            
        }
        
        return newText!
        
    }
    
}
