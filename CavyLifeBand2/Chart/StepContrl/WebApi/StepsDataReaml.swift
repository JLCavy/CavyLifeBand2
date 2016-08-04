//
//  StepsDataReaml.swift
//  CavyLifeBand2
//
//  Created by Hanks on 16/6/28.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import Foundation
import RealmSwift
import Log
import Datez
import JSONJoy

class NChartStepDataRealm: Object {
    
    dynamic var userId             = ""
    dynamic var date: NSDate       = NSDate()
    dynamic var dateStr: String    = NSDate().toString(format: "yyyy-MM-dd HH:mm:ss")
    dynamic var totalTime: Int     = 0
    dynamic var totalStep: Int     = 0
    dynamic var kilometer: CGFloat = 0
    
    var stepList = List<StepListItem>()
    
   
    convenience init(userId: String = CavyDefine.loginUserBaseInfo.loginUserInfo.loginUserId, date: NSDate, totalTime: Int, totalStep: Int, stepList: List<StepListItem>) {
        
        self.init()
        self.userId    = userId
        self.date      = date
        self.dateStr   = date.toString(format: "yyyy-MM-dd HH:mm:ss")
        self.totalStep = totalStep
        self.kilometer = CGFloat(self.totalStep) * 0.0006
        self.totalTime = totalTime
        self.stepList  = stepList
    }
    
    override class func primaryKey() -> String? {
        return "dateStr"
    }
    
}

class StepListItem: Object {
    
    dynamic var step = 0
    
    convenience required init(step: Int) {
        
        self.init()
        self.step = step
    }
    
}



// MARK: 服务器计步数据库操作协议
protocol ChartStepRealmProtocol {
    
    var realm: Realm { get }
    var userId: String { get }
    
    func isNeedUpdateNStepData() -> Bool
    func queryAllStepInfo(userId: String) -> Results<(NChartStepDataRealm)>?
    func delecNSteptDate(beginTime: NSDate, endTime: NSDate) -> Bool
    func addStepData(chartStepInfo: NChartStepDataRealm) -> Bool
    func delecNSteptDate(chartStepInfo: NChartStepDataRealm) -> Bool
    func queryNStepNumber(beginTime: NSDate, endTime: NSDate, timeBucket: TimeBucketStyle) -> StepChartsData?
    
}




extension ChartStepRealmProtocol {
 
  
    
    /**
     删除某一段时间的数据
     
     - parameter beginTime: <#beginTime description#>
     - parameter endTime:   <#endTime description#>
     
     - returns: <#return value description#>
     */
    
    func delecNSteptDate(beginTime: NSDate, endTime: NSDate) -> Bool {
        
        
        let dataInfo = realm.objects(NChartStepDataRealm).filter("userId == '\(userId)' AND date > %@ AND date < %@", beginTime, endTime)
        
        self.realm.beginWrite()
        
        for data in dataInfo {
            
            self.realm.delete(data)
        }
        
        do {
            
            try self.realm.commitWrite()
            
        } catch let error {
            
            Log.error("\(#function) error = \(error)")
            
            return false
        }
        Log.info("delete charts info success")
        
        return true
        
    }
    
    /**
     删除某一条数据
     
     - parameter chartStepInfo: <#chartStepInfo description#>
     
     - returns: <#return value description#>
     */
    
    func delecNSteptDate(chartStepInfo: NChartStepDataRealm) -> Bool {
        
        self.realm.beginWrite()
        
        self.realm.delete(chartStepInfo)
    
        do {
            
            try self.realm.commitWrite()
            
        } catch let error {
            
            Log.error("\(#function) error = \(error)")
            
            return false
        }
        Log.info("delete charts info success")
        
        return true
        
    }

    /**
     删除全部
     
     - parameter beginDate:
     
     - returns:
     */
    func deleteNSteptDate() -> Bool {
        
        let personalList = realm.objects(NChartStepDataRealm)
        
        guard personalList.count > 0 else { return true }
        
        self.realm.beginWrite()
        
        self.realm.delete(personalList)
        
        do {
            
            try self.realm.commitWrite()
            
        } catch let error {
            
            Log.error("\(#function) error = \(error)")
            
            return false
        }
        
        Log.info("delete charts info success")
        
        return true
        
    }
    
    
    /**
     是否需要从服务器拉取计步数据
     
     - returns: <#return value description#>
     */
    
    func isNeedUpdateNStepData() -> Bool {
        
        let list = realm.objects(NChartStepDataRealm)
        
        if list.count == 0 {
            return true
        }
        
        let personalList = realm.objects(NChartStepDataRealm).filter("userId = '\(userId)'")
        
        if personalList.count == 0 {
            return true
        }
        
        let totalMinutes = (NSDate().gregorian.beginningOfDay.date - personalList.last!.date).totalMinutes
        Log.info(totalMinutes)
        
        if totalMinutes > 10 {
            return true
        }
        
        return false
        
    }
    
    
    /**
     返回从服务器存储拉取的所有单条数据
     */
    func queryAllStepInfo(userId: String = CavyDefine.loginUserBaseInfo.loginUserInfo.loginUserId) -> Results<(NChartStepDataRealm)>? {

        return realm.objects(NChartStepDataRealm).filter("userId = '\(userId)'")
        
    }
    

    
    /**
     添加计步数据
     - parameter chartsInfo: 用户的计步信息
     - returns: 成功：true 失败： false
     */
    func addStepData(chartsInfo: NChartStepDataRealm) -> Bool {
        
        do {
            
            try realm.write {
                
                realm.add(chartsInfo, update: true)
            }
            
        } catch {
            
            Log.error("Add charts info error [\(chartsInfo)]")
            return false
            
        }
        
        Log.info("Add charts info success")
        
        return true
        
    }
    

    /**
     查询 日周月下 某一时段的 数据信息
     */
    func queryNStepNumber(beginTime: NSDate, endTime: NSDate, timeBucket: TimeBucketStyle) -> StepChartsData? {
    
        //转换时间格式
        
        let nowDate = NSDate()
        
        var scanTime: NSDate = endTime
        
        if (nowDate - beginTime).totalMinutes >= 0 && (nowDate - endTime).totalMinutes <= 0 {
            
            scanTime = (NSDate().gregorian.beginningOfDay - 1.seconds).date
        }
        
        let dataInfo = realm.objects(NChartStepDataRealm).filter("userId == '\(userId)' AND date => %@ AND date <= %@", beginTime.gregorian.beginningOfDay.date, scanTime)
            
           
            print("=============\(dataInfo.count)==============")
            
            switch timeBucket {
                
            case .Day:

                return returnHourChartsArray(dataInfo)
                
            case .Week, .Month:
                
                return returnDayChartsArray(beginTime, endTime: endTime, dataInfo: dataInfo)
            
        }
        
    }
    
    
    
    /**
     按小时分组 一天24小时
     */
    func returnHourChartsArray(dataInfo: Results<(NChartStepDataRealm)>?) -> StepChartsData? {
        
        
        guard let newData = dataInfo else {
            
            return nil
        }
        
        var stepChartsData = StepChartsData(datas: [], totalStep: 0, totalKilometer: 0, finishTime: 0, averageStep: 0)
        
        // 初始化0~23 24 小时
        for i in 0...23 {
            
            stepChartsData.datas.append(PerStepChartsData(time: "\(i)", step: 0))
        }
        
        for data in newData {
          
            stepChartsData.totalStep = data.totalStep
            stepChartsData.totalKilometer = data.kilometer
            stepChartsData.finishTime = data.totalTime
            stepChartsData.averageStep = data.totalStep
            
            var index: Int = 0
            for step in data.stepList {
                
                index += 1
                stepChartsData.datas[index - 1].step = step.step
                
            }
            
        
        }
        
        return stepChartsData
        
    }
    
    
    
    /**
     按天分组 一周七天 一个月30天
     */    func returnDayChartsArray(beginTime: NSDate, endTime: NSDate, dataInfo: Results<(NChartStepDataRealm)>) -> StepChartsData {
        
        var stepChartsData = StepChartsData(datas: [], totalStep: 0, totalKilometer: 0, finishTime: 0, averageStep: 0)
        
        
        let maxNum = (endTime - beginTime).totalDays + 1
        
        for i in 1...maxNum {
            
            stepChartsData.datas.append(PerStepChartsData(time: "\(i)", step: 0))
        }
        
        var averageStepCount = 0
        
        var indext = 0
        
        // 数据补齐操作 在什么时候需要??
        var dataInfoArr: [NChartStepDataRealm] = []

        for data in dataInfo {
            dataInfoArr.append(data)
        }
        
        
        if maxNum != dataInfo.count {
            
          dataInfoArr  = completeStepData(beginTime, endTime: endTime, dataInfo: dataInfo)
            
        }
       
        
        for data in dataInfoArr {
           
            indext += 1
            stepChartsData.totalKilometer += data.kilometer
            stepChartsData.totalStep += data.totalStep
            stepChartsData.finishTime += data.totalTime
            
            
            // 取平局数时候去除0步的情况
            
            if data.totalStep != 0 {
        
                averageStepCount += 1
            }
            
            
            if indext - 1 < maxNum   {
                
                 stepChartsData.datas[indext - 1].step = data.totalStep
            }
           
            
        }
        
        if averageStepCount == 0 {
            
            stepChartsData.averageStep = 0
            
        }else {
            
             stepChartsData.averageStep = Int(stepChartsData.finishTime / averageStepCount)
        }
       
    
        return stepChartsData
        
    }
    
    
    /**
     数据补齐操作
     
     - parameter beginTime: <#beginTime description#>
     - parameter endTime:   <#endTime description#>
     
     - returns: <#return value description#>
     */
    
    func completeStepData(beginTime: NSDate, endTime: NSDate, dataInfo: Results<(NChartStepDataRealm)>) -> [NChartStepDataRealm]{
       
//        //计算开始到取出第一条数据的时间间隔
//        
//        let firstDate = (dataInfo.first?.date.gregorian.date) ?? beginTime.gregorian.date
//        
//        let lastDate = (dataInfo.last?.date.gregorian.date) ?? endTime.gregorian.date
//        
//        let firstDistance = ((firstDate - beginTime.gregorian.date)).totalDays
//        //计算最后一条数据 到最后时间的间隔
//        let lastDistance = (endTime.gregorian.date - (dataInfo.last?.date.gregorian.date)!).totalDays
//        
         var resultDataArr: [NChartStepDataRealm] = []
//
//        
//        //补齐前端数据
//        if firstDistance > 0 {
//           
//            for _ in 0..<firstDistance {
//              resultDataArr.append(NChartStepDataRealm())
//            }
//        }
//        
//        
//        //添加查询数据
//        for data in dataInfo {
//            
//            resultDataArr.append(data)
//        }
//        
//        
//        //补齐后段数据
//        if lastDistance > 0 {
//            
//            for _ in 0..<lastDistance {
//              
//                resultDataArr.append(NChartStepDataRealm())
//            }
//        }
//        
//        
//        return resultDataArr
        
        
        let dayTotal = (endTime - beginTime).totalDays
        
        var realmIndex = 0
        
        Log.info("querySleepInfoDays Begin \(beginTime.toString(format: "yyyy-MM-dd")) - \(endTime.toString(format: "yyyy-MM-dd")))")
        
        /// 数据库中没有数据
        if dataInfo.count == 0 {
            
            for _ in 0...dayTotal {
                
                resultDataArr.append(NChartStepDataRealm())
                
            }
            
        } else {
            
            /// 转化数据库中的数据，并做断档数据补0
            for i in 0...dayTotal {
                
                if realmIndex < dataInfo.count {
                    
                    if ((beginTime.gregorian + i.day).beginningOfDay.date - dataInfo[realmIndex].date).totalDays == 0 {
                        
                        resultDataArr.append(dataInfo[realmIndex])
                        
                        realmIndex += 1
                        
                    } else {
                        resultDataArr.append(NChartStepDataRealm())
                    }
                    
                } else {
                    
                    resultDataArr.append(NChartStepDataRealm())
                    
                }
                
            }
            
            Log.info("querySleepInfoDays end \(beginTime.toString(format: "yyyy-MM-dd")) - \(endTime.toString(format: "yyyy-MM-dd")))")
            
        }
        
        return resultDataArr

    }
    
    
}




