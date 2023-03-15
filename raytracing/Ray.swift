//
//  Ray.swift
//  raytracing
//
//  Created by Ilya Kulinkovich on 15/3/23.
//

import Foundation

struct Ray {
    let origin: Point
    let direction: Vector3
    
    func point(atOffset offset: Double) -> Point {
        origin + direction * offset
    }
}
