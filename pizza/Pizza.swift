//
//  Pizza.swift
//  pizza
//
//  Created by Németh Bence on 2024. 12. 10..
//
// Pizza.swift
import Foundation

struct Pizza: Identifiable, Codable {
    let id: Int
    let name: String
    let isGlutenFree: Int
    let kepURL: String?
}
