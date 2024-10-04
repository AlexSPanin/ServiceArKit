//
//  ExtansionsSimd.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import RealityKit


extension simd_quatf: Codable {
    
    //MARK: - методы для возможности кодирования и декодирования - simd_quatf
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(vector: container.decode(SIMD4.self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(vector)
    }
}


extension simd_float4x4: Codable {
    
    //MARK: - методы для возможности кодирования и декодирования - simd_float4x4
    public init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        try self.init(container.decode([SIMD4<Float>].self))
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode([columns.0,columns.1, columns.2, columns.3])
    }
    
    /// вычисление позиции из матрицы координат
    /// - Returns: позиция simd_float3
    public func position() -> simd_float3 {
        let point = self.columns.3
        return SIMD3(point.x, point.y, point.z)
    }
    
    /// изменение расстояния от текущих координатна заданную величину
    /// - Parameter distance: заданая величина изменения расстояния
    /// - Returns: новая позиция simd_float3
    public func changeDistance(to distance: Float) -> simd_float3 {
        return self.position() + (distance > 0 ? distance : -distance)
    }
}
