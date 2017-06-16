//
//  LocationInfo.swift
//  Map
//
//  Created by 123 on 2017/6/15.
//  Copyright © 2017年 123. All rights reserved.
//

import Foundation

class LocationInfo: NSObject, NSCoding{
    var title: String
    var latitude: String
    var longitude: String
    
    //构造方法
    init(title: String = "", latitude: String = "",longitude: String = ""){
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
        super.init()
    }
    
    //从nsobject解析回来
    required init(coder aDecoder:NSCoder){
        self.title=aDecoder.decodeObject(forKey: "Title") as! String
        self.latitude=aDecoder.decodeObject(forKey: "Latitude") as! String
        self.longitude=aDecoder.decodeObject(forKey: "Longitude") as! String
    }
    
    //编码成object
    func encode(with aCoder:NSCoder){
        aCoder.encode(title,forKey:"Title")
        aCoder.encode(latitude,forKey:"Latitude")
        aCoder.encode(longitude,forKey:"Longitude")
    }
}
