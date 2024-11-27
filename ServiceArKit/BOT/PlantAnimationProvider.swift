/*
See the LICENSE.txt file for this sample’s licensing information.

Abstract:
Loads and provides access to plant animations.
*/

import Foundation
import RealityKit
import SwiftUI
import Spatial

/// An object that loads and provides all the necessary animations for each plant model.
@MainActor
class PlantAnimationProvider: Sendable {
    static var shared = PlantAnimationProvider()
    
    /// A dictionary of the grow animations for each type of plant.
    public var growAnimations = [PlantComponent.PlantTypeKey: AnimationResource]()
    /// A dictionary of the celebration animations for each type of plant.
    public var celebrateAnimations = [PlantComponent.PlantTypeKey: AnimationResource]()
    /// A dictionary of the current animation controllers for each type of plant.
    public var currentGrowAnimations = [PlantComponent.PlantTypeKey: AnimationPlaybackController]()
    
    init() {
        Task { @MainActor in
            await withTaskGroup(of: PlantAnimationResult.self) { taskGroup in
                for plantType in PlantComponent.PlantTypeKey.allCases {
                    taskGroup.addTask {
                        let growAnim = await self.generateGrowAnimationResource(for: plantType)
                        let celeAnim = await self.generateCelebrateAnimationResource(for: plantType)
                        return PlantAnimationResult(growAnim: growAnim, celebrateAnim: celeAnim, plantType: plantType)
                    }
                }
                for await result in taskGroup {
                    growAnimations[result.plantType] = result.growAnim
                    celebrateAnimations[result.plantType] = result.celebrateAnim
                }
            }
        }
    }
    
    /// Loads the grow animation for the given plant type.
    private func generateGrowAnimationResource(for plantType: PlantComponent.PlantTypeKey) async -> AnimationResource {
 //       let sceneName = "BOT/Assets/plants/animations/\(plantType.rawValue)_grow_anim"
        let sceneName = "\(plantType.rawValue)_grow_anim.usdz"
        var ret: AnimationResource? = nil
        do {
    //        let rootEntity = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
            let rootEntity = try await Entity(named: sceneName)
            rootEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { entity, component in
                if let index = entity.animationLibraryComponent?.animations.startIndex {
                    ret = entity.animationLibraryComponent?.animations[index].value
                }
            }
            guard let ret else { fatalError("Animation resource unexpectedly nil.") }
            return ret
        } catch {
            fatalError("Error generateGrowAnimationResource: \(error.localizedDescription)")
        }
    }
    
    /// Loads the celebration animation for the given plant type.
    private func generateCelebrateAnimationResource(for plantType: PlantComponent.PlantTypeKey) async -> AnimationResource {
 //       let sceneName = "BOT/Assets/plants/animations/\(plantType.rawValue)_celebrate_anim"
        let sceneName = "\(plantType.rawValue)_celebrate_anim.usdz"
        var ret: AnimationResource? = nil
        do {
//            let rootEntity = try await Entity(named: sceneName, in: BOTanistAssetsBundle)
            let rootEntity = try await Entity(named: sceneName)
             rootEntity.forEachDescendant(withComponent: BlendShapeWeightsComponent.self) { entity, component in
                 ret = entity.animationLibraryComponent?.defaultAnimation
             }
            guard let ret else { fatalError("Animation resource unexpectedly nil.") }
            return ret
        } catch {
            fatalError("Error generateCelebrateAnimationResource: \(error.localizedDescription)")
        }
    }
}

@MainActor
public struct PlantAnimationResult: Sendable {
    var growAnim: AnimationResource
    var celebrateAnim: AnimationResource
    var plantType: PlantComponent.PlantTypeKey
}
