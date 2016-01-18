//
//  UserNetJSON.swift
//  CavyLifeBand2
//
//  Created by xuemincai on 16/1/14.
//  Copyright © 2016年 xuemincai. All rights reserved.
//

import Foundation
import AlamofireObjectMapper
import ObjectMapper


class CommonResphones: Mappable {
    
    var code = ""
    var msg = ""
    
    required init?(_ map: Map) {
        
    }
    
    func mapping(map: Map) {
        code <- map["code"]
        msg <- map["msg"]
    }
    
}