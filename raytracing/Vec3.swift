//
//  Vec3.swift
//  raytracing
//
//  Created by Ilya Kulinkovich on 15/3/23.
//

import Foundation

struct Vector3 {
    static var zero: Self { .init(x: 0, y: 0, z: 0) }
    
    var x: Double, y: Double, z: Double
    
    var lengthSquared: Double {
        pow(x, 2) + pow(y, 2) + pow(z, 2)
    }
    
    var length: Double {
        sqrt(lengthSquared)
    }
    
    var unit: Self {
        self / length
    }
    
    static func +(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x + rhs.x, y: lhs.y + rhs.y, z: lhs.z + rhs.z)
    }
    
    static func -(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x - rhs.x, y: lhs.y - rhs.y, z: lhs.z - rhs.z)
    }
    
    static prefix func -(self: Self) -> Self {
        Self(x: -self.x, y: -self.y, z: -self.z)
    }
    
    static func *(lhs: Self, rhs: Double) -> Self {
        Self(x: lhs.x * rhs, y: lhs.y * rhs, z: lhs.z * rhs)
    }
    
    static func *(lhs: Double, rhs: Self) -> Self {
        rhs * lhs
    }
    
    static func *(lhs: Self, rhs: Self) -> Self {
        Self(x: lhs.x * rhs.x, y: lhs.y * rhs.y, z: lhs.z * rhs.z)
    }
    
    static func /(lhs: Self, rhs: Double) -> Self {
        lhs * (1 / rhs)
    }
    
    init(x: Double, y: Double, z: Double) {
        (self.x, self.y, self.z) = (x, y, z)
    }
    
    init(r: Int, g: Int, b: Int) {
        (x, y, z) = (Double(r), Double(g), Double(b))
    }
    
    subscript(index: Int) -> Double {
        get { [x, y, z][index] }
        mutating set { self[keyPath: [\Self.x, \.y, \.z][index]] = newValue }
    }
    
    func dot(_ rhs: Self) -> Double {
        x * rhs.x + y * rhs.y + z * rhs.z
    }
    
    func cross(_ rhs: Self) -> Self {
        Self(x: y * rhs.z - z * rhs.y,
             y: z * rhs.x - x * rhs.z,
             z: x * rhs.y - y * rhs.x)
    }
}

typealias Color = Vector3
typealias Point = Vector3
