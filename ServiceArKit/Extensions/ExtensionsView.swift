//
//  ExtensionsView.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import SwiftUI

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

extension View {
    /// Определяет поворот устройства
    /// - Parameter action: захватывает поворот
    /// - Returns: отработка поворота
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void ) -> some View {
        self.modifier(DeviceRotationViewModifier(action: action))
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
