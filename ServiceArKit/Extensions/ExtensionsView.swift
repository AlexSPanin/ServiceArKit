//
//  ExtensionsView.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import SwiftUI

/// Обзервер для отслеживания изменения размеров констант
class ConstantSetting: ObservableObject {
    @Published var orientation: UIDeviceOrientation                  // ориентация устройства
    @Published var view: CGSize                                      // размер экрана устройства
    @Published var screen: CGFloat                                   // приведенная ширина экрана
    @Published var midPoint: CGPoint                                 // срединная точка экрана
    @Published var scaleWidth: CGFloat                               // отношение ширины к базовой ширине
    @Published var scaleHeight: CGFloat                              // отношение высоты к базовой высоте
    @Published var isSmall: Bool                                     // признак малого экрана
    
    @Published var corner: CGFloat                                   // базовый радиус скругления
    @Published var hPadding: CGFloat                                 // базовый горизонтальный отступ
    @Published var vPadding: CGFloat                                 // базовый вертикальный отступ
    
    @Published var imageXL: CGFloat                                  // размеры ширины для изображений
    @Published var imageL: CGFloat
    @Published var imageN: CGFloat
    @Published var imageS: CGFloat
    @Published var pickerL: CGFloat
    @Published var picker: CGFloat
    
    init () {
        let orientation = UIDevice.current.orientation
        let isLandscape = orientation.isLandscape
        let bounds = UIScreen.main.bounds
        let midPoint = CGPoint(x: bounds.midX, y: bounds.midY)
        let width = isLandscape ? bounds.height : bounds.width
        let scaleWidth = width / (isLandscape ? base.height : base.width)
        let heigth = isLandscape ? bounds.width : bounds.height
        let scaleHeight = heigth / (isLandscape ? base.width : base.height)
        let size = CGSize(width: width, height: heigth)
        let isSmall = width < small || heigth < small
        let widthScale: CGFloat = width / scaleWidth
        

        self.orientation = orientation
        self.view = size
        self.screen = size.width * 0.95
        self.midPoint = midPoint
        self.scaleWidth = scaleWidth
        self.scaleHeight = scaleHeight
        self.isSmall = isSmall
        self.corner = scaleWidth > 1 ? 10 : 10 * scaleWidth
        self.hPadding = scaleWidth > 2 ? 30 : 15 * scaleWidth
        self.vPadding = scaleHeight > 1.5 ? 25 : 15 * scaleHeight
        self.imageXL = widthScale * (isSmall ? 0.3 : 0.4)
        self.imageL = widthScale * (isSmall ? 0.2 : 0.3)
        self.imageN = widthScale * (isSmall ? 0.15 : 0.2)
        self.imageS = widthScale * (isSmall ? 0.08 : 0.1)
        self.pickerL = widthScale * (isSmall ? 0.05 : 0.06)
        self.picker = widthScale * (isSmall ? 0.02 : 0.03)

    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let setting: (ConstantSetting) -> Void
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                setting ( ConstantSetting() )
            }
    }
}

extension View {
    /// Определяет поворот устройства
    /// - Parameter setting: тип ориентации и размер экрана и увеличения по ширине и высоте взависимости от размера экрана
    /// - Returns: отработка поворота
    func onRotate(perform setting: @escaping (ConstantSetting) -> Void ) -> some View {
        self.modifier(DeviceRotationViewModifier(setting: setting))
    }
}


extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

/// Обзервер для отслеживания активности приложения и сохранения кеш
class AppState: ObservableObject {
    @Published var isActive = true
    private var observers = [NSObjectProtocol]()
    
    init() {
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
                self.isActive = true
            }
        )
        observers.append(
            NotificationCenter.default.addObserver(forName: UIApplication.willResignActiveNotification, object: nil, queue: .main) { _ in
                self.isActive = false }
        )
    }
    deinit { observers.forEach(NotificationCenter.default.removeObserver) }
}
