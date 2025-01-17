//
//  ModelKeyMapper.swift
//  SmartCodable
//
//  Created by Mccc on 2024/3/4.
//

import Foundation




struct ModelKeyMapper<T> {
    /// 尝试转换为一个映射后的模型相关的格式
    static func convertToMappedFormat(_ jsonValue: Any) -> Any {
        guard let type = T.self as? SmartDecodable.Type else { return jsonValue }
        
        if let stringValue = jsonValue as? String {
            return parseJSON(from: stringValue, as: type)
        } else if let dictValue = jsonValue as? [String: Any] {
            return mapDictionary(dict: dictValue, using: type)
        }
        return jsonValue
    }
    
    private static func parseJSON(from string: String, as type: SmartDecodable.Type) -> Any {
        guard let jsonObject = string.toJSONObject() else { return string }
        if let dict = jsonObject as? [String: Any] {
            return mapDictionary(dict: dict, using: type)
        } else {
            return jsonObject
        }
    }
    
    private static func mapDictionary(dict: [String: Any], using type: SmartDecodable.Type) -> [String: Any] {
        var newDict = dict
        type.mapping()?.forEach { mapping in
            for oldKey in mapping.from {
                if let value = newDict[oldKey], !(value is NSNull) { // 如果存在有效值(存在并不是null)
                    let newKey = mapping.to.stringValue
                    newDict[newKey] = newDict.removeValue(forKey: oldKey)
                    break
                }
            }
        }
        return newDict
    }
}

extension String {
    fileprivate func toJSONObject() -> Any? {
        guard starts(with: "{") || starts(with: "[") else { return nil }
        return data(using: .utf8).flatMap { try? JSONSerialization.jsonObject(with: $0) }
    }
}
