//
//  UserInfoModelView.swift
//  CavyLifeBand2
//
//  Created by xuemincai on 16/3/8.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import Foundation
import UIKit
import Log
import JSONJoy
import EZSwiftExtensions

struct UserInfoModelView {

    var userInfo: UserInfoModel?
    var viewController: UIViewController? = nil

    /**
     初始化
     
     - parameter viewController: 当前的viewController
     - parameter userId:         用户id
     - parameter callback:       回调
     
     - returns:
     */
    init(viewController: UIViewController? = nil, userId: String, callback: ((Bool) -> Void)? = nil) {

        let netPara = [UserNetRequsetKey.UserID.rawValue: userId]

        let userInfoRealm = UserInfoOperate().queryUserInfo(userId)
        
        self.userInfo = UserInfoModel()
        self.userInfo!.userId = userId

        if userInfoRealm != nil {
            
            self.userInfo!.sex = userInfoRealm!.sex
            self.userInfo!.height = userInfoRealm!.height
            self.userInfo!.weight = userInfoRealm!.weight
            self.userInfo!.birthday = userInfoRealm!.birthday
            self.userInfo!.avatarUrl = userInfoRealm!.avatarUrl
            self.userInfo!.address = userInfoRealm!.address
            self.userInfo!.nickname = userInfoRealm!.nickname
            self.userInfo!.sleepTime = userInfoRealm!.sleepTime
            self.userInfo!.stepNum = userInfoRealm!.stepNum
            
        }

        userNetReq.queryProfile(netPara) { (result) in
            
            if result.isFailure {

                callback?(false)
                CavyLifeBandAlertView.sharedIntance.showViewTitle(self.viewController, userErrorCode: result.error!)
                return
                
            }

            do {

                let profileMsg = try UserProfileMsg(JSONDecoder(result.value!))

                if profileMsg.commonMsg!.code != WebApiCode.Success.rawValue {

                    callback?(false)
                    CavyLifeBandAlertView.sharedIntance.showViewTitle(self.viewController, webApiErrorCode: profileMsg.commonMsg!.code!)
                    return

                }

                self.userInfo!.sex = profileMsg.sex!.toInt()!
                self.userInfo!.height = profileMsg.height!
                self.userInfo!.weight = profileMsg.weight!
                self.userInfo!.birthday = profileMsg.birthday!
                self.userInfo!.avatarUrl = profileMsg.avatarUrl!
                self.userInfo!.address = profileMsg.address!
                self.userInfo!.nickname = profileMsg.nickName!
                self.userInfo!.sleepTime = profileMsg.sleepTime!
                self.userInfo!.stepNum = profileMsg.stepNum!

                callback?(true)

            } catch {

                callback?(false)
                CavyLifeBandAlertView.sharedIntance.showViewTitle(self.viewController, webApiErrorCode: L10n.UserModuleErrorCodeNetError.string)

            }
            
        }

    }

    /**
     更新信息
     
     - parameter successCallback: 更新成功回调
     */
    func updateInfo(successCallback: (Void -> Void)? = nil) {

        let netPara: [String: AnyObject] = [UserNetRequsetKey.UserID.rawValue: self.userInfo!.userId,
        UserNetRequsetKey.Sex.rawValue: "\(self.userInfo!.sex)",
        UserNetRequsetKey.Height.rawValue: self.userInfo!.height,
        UserNetRequsetKey.Weight.rawValue: self.userInfo!.weight,
        UserNetRequsetKey.Birthday.rawValue: self.userInfo!.birthday,
        UserNetRequsetKey.Address.rawValue: self.userInfo!.address,
        UserNetRequsetKey.NickName.rawValue: self.userInfo!.nickname,
        UserNetRequsetKey.StepNum.rawValue: self.userInfo!.stepNum,
        UserNetRequsetKey.SleepTime.rawValue: self.userInfo!.sleepTime]

        userNetReq.setProfile(netPara) { (result) in
            
            if result.isFailure {

                CavyLifeBandAlertView.sharedIntance.showViewTitle(self.viewController, userErrorCode: result.error!)
                return
            }
            
            do {
                
                let resultMsg = try CommenMsg(JSONDecoder(result.value!))
                
                if resultMsg.code != WebApiCode.Success.rawValue {

                    CavyLifeBandAlertView.sharedIntance.showViewTitle(self.viewController, webApiErrorCode: resultMsg.code!)
                    return

                }

                if UserInfoOperate().isUserExist(self.userInfo!.userId) {

                    UserInfoOperate().updateUserInfo(self.userInfo!)

                } else {

                    UserInfoOperate().addUserInfo(self.userInfo!)

                }

                successCallback?()

            } catch {

                CavyLifeBandAlertView.sharedIntance.showViewTitle(self.viewController, userErrorCode: UserRequestErrorType.NetErr)

            }

        }

    }


}
