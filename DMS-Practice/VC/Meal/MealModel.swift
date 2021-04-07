//
//  MealModel.swift
//  DMS-Practice
//
//  Created by leedonggi on 2020/06/09.
//  Copyright © 2020 leedonggi. All rights reserved.
//

import Foundation

struct MealModel: Codable {
    let breakfast: [String]
    let lunch: [String]
    let dinner: [String]
    
    func getData() -> MealTuple{
        return (getStr(breakfast), getStr(lunch), getStr(dinner))
    }
    
    func getDataForExtension() -> [String]{
        return [getStr(breakfast), getStr(lunch), getStr(dinner)]
    }
    
    private func getStr(_ arr: [String]) -> String{
        var data = arr.map{ $0 + ", " }.reduce(""){ $0 + $1 }
        data.removeLast(2)
        return data
    }
}
