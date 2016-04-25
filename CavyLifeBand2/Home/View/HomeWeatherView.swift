//
//  HomeWeatherView.swift
//  CavyLifeBand2
//
//  Created by Jessica on 16/4/13.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import UIKit
import JSONJoy
import EZSwiftExtensions


class HomeWeatherView: UIView {

    /// 天气图片
    @IBOutlet weak var imgView: UIImageView!
    
    /// 温度
    @IBOutlet weak var temperature: UILabel!
    
    /// 空气
    @IBOutlet weak var airQuality: UILabel!
    
    /**
     加载天气视图
     */
    func loadWeatherView() {
        
        let location = "hangzhou"
        
        HomeWeatherWebApi.shareApi.parseWeatherData(location) {(result) in
            
            guard result.isSuccess else {
                
                Log.error("Get friend list error")
                return
            }
            
            do {
                
                let netResult = try HomeWeatherMsg(JSONDecoder(result.value!))
                
                Log.info(netResult)
                self.temperature.text = "\(netResult.tmp!)°C"
                self.addAirCondition(netResult.pm25!)
                self.addCondImage(netResult.cond!)
                
            } catch let error {
                
                Log.error("\(#function) result error (\(error))")
                
            }

            
        }
        
    
    }
    
    /**
     添加空气状态文本
     */
    func addAirCondition(pm25: Int) {
        
        var airCondition: String = ""
        
        if pm25 <= 35 {
            
            airCondition = L10n.HomeWeatherAirConditionBest.string
            
        } else if pm25 > 35 && pm25 <= 75 {
            
            airCondition = L10n.HomeWeatherAirConditionGood.string
            
        } else if pm25 > 75 && pm25 <= 115 {
            
            airCondition = L10n.HomeWeatherAirPollutionMild.string
            
        } else if pm25 > 115 && pm25 <= 150 {
            
            airCondition = L10n.HomeWeatherAirPollutionMiddle.string
            
        } else {
            
            airCondition = L10n.HomeWeatherAirPollutionBad.string
        }
        
        self.airQuality.text = "\(L10n.HomeWeatherAir.string)：\(airCondition)"

    }
    
    /**
     添加天气状况的图片
    */
    func addCondImage(cond: String) {
        
        imgView.layer.masksToBounds = true
        imgView.layer.cornerRadius = 10
        
        
        let weatherNames = [L10n.HomeWeatherSun.string,
                            L10n.HomeWeatherCloudy.string,
                            L10n.HomeWeatherOvercast.string,
                            L10n.HomeWeatherRainOccasional.string,
                            L10n.HomeWeatherRainThundery.string,
                            L10n.HomeWeatherRainLight.string,
                            L10n.HomeWeatherRainMiddle.string,
                            L10n.HomeWeatherRainHeavy.string,
                            L10n.HomeWeatherSnowLight.string,
                            L10n.HomeWeatherSnowMiddle.string,
                            L10n.HomeWeatherSnowHeavy.string]
        
        let weatherImages = [UIImage(asset: .HomeWeatherSun),
                             UIImage(asset: .HomeWeatherCloudy),
                             UIImage(asset: .HomeWeatherOvercast),
                             UIImage(asset: .HomeWeatherRainOccasional),
                             UIImage(asset: .HomeWeatherRainThundery),
                             UIImage(asset: .HomeWeatherRainLight),
                             UIImage(asset: .HomeWeatherRain),
                             UIImage(asset: .HomeWeatherRainHeavy),
                             UIImage(asset: .HomeWeatherSnowLight),
                             UIImage(asset: .HomeWeatherSnow),
                             UIImage(asset: .HomeWeatherSnowHeavy)]
        
        
        for i in 0  ..< weatherNames.count {
                    
            if cond.contains(weatherNames[i]) {
                
                imgView.image = weatherImages[i]
            }
        }
        
    }
    
    
}


