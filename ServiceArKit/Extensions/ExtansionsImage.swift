//
//  ExtansionsImage.swift
//  ServiceArKit
//
//  Created by Александр Панин on 04.10.2024.
//

import SwiftUI

// MARK: - расширение для UIImage функция поворота
extension UIImage {
    
    // поворот изображения
    func rotate(radians: CGFloat) -> UIImage {
        let rotatedSize = CGRect(origin: .zero, size: size)
            .applying(CGAffineTransform(rotationAngle: CGFloat(radians)))
            .integral.size
        UIGraphicsBeginImageContext(rotatedSize)
        if let context = UIGraphicsGetCurrentContext() {
            let origin = CGPoint(x: rotatedSize.width / 2.0,
                                 y: rotatedSize.height / 2.0)
            context.translateBy(x: origin.x, y: origin.y)
            context.rotate(by: radians)
            draw(in: CGRect(x: -origin.y, y: -origin.x,
                            width: size.width, height: size.height))
            let rotatedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            return rotatedImage ?? self
        }
        return self
    }
    
    // изменение размера изображения key = heigth / width
    func cropImageKey(to key: CGFloat) -> UIImage? {
        guard let cgImage: CGImage = self.cgImage else { return nil }
        let size = self.size
        debugPrint("Начало получили исходный размер \(size)")
        let keyImage = size.height / size.width
        let checkKey = key > keyImage                          // если требуемый коэф болльше текущего за основу выбираем текущую высоту
        debugPrint("Получили коэффицент проверки \(checkKey) keyImage \(keyImage) key \(key)")
        let width = checkKey ? size.height / key : size.width
        let heigth = checkKey ? size.height : size.width * key
        let newSize = CGSize(width: width, height: heigth)
        let y = abs((size.height - newSize.height) / 2)
        let x = abs((size.width - newSize.width) / 2)
        let point = CGPoint(x: x, y: y)
        let rect = CGRect(origin: point, size: newSize)
        debugPrint("Получили область вырезки \(rect)")
        guard let cropCGImage = cgImage.cropping(to: rect) else { return nil}
        return UIImage(cgImage: cropCGImage)
    }

    // изменение размера изображения
    func cropImage() -> UIImage? {
        guard let cgImage: CGImage = self.cgImage else { return nil }
        debugPrint("Начало получили context")
        let size = self.size
        let side = size.width > size.height ? size.height : size.width  // минимальная сторона
        let newSize = CGSize(width: side, height: side)
        let y = abs((size.height - newSize.height) / 2)
        let x = abs((size.width - newSize.width) / 2)
        let point = CGPoint(x: x, y: y)
        let rect = CGRect(origin: point, size: newSize)
        guard let cropCGImage = cgImage.cropping(to: rect) else { return nil}
        return UIImage(cgImage: cropCGImage)
    }
    
    // обрезка изображения
    func createdImage(to point: CGPoint, size: CGSize, course: CGSize) -> CGImage? {
        let sizeCource = self.size
        if sizeCource.width > course.width {
            let delta = (self.size.width - course.width) / 2 // смещение от левого края до начала картинки
            let rectPoint = CGPoint(x: delta + point.x , y: 0)
            let rectTarget = CGRect(origin: rectPoint, size: size)
            let cgImage = self.cgImage
            return cgImage?.cropping(to: rectTarget)
        } else {
            let count = Int(course.width / sizeCource.width)
            var images = [UIImage]()
            for _ in 0...count { images.append(self) }
            guard let uiImage = compositeImages(composite: .horisontal, images: images) else { return nil}
    //        let rectTarget = CGRect(origin: point, size: size) // что мы вырезаем
            // определили прямоугольник для вырезания
            let rect = CGRect(origin: point, size: size)
            // преобразуем и вырезаем
            let cgImage = uiImage.cgImage
            return cgImage?.cropping(to: rect)
        }
    }
    
    // переформатирование изображения
    func compositeImages(composite: TypeComposite, images: [UIImage]) -> UIImage? {
        var compositeImage: UIImage?
        var size: CGSize = CGSize.zero
        switch composite {
        case .blend:
            size.height = images.compactMap({$0.size.height}).max() ?? 0
            size.width = images.compactMap({$0.size.width}).max() ?? 0
            images.forEach { image in
                let rect = CGRect(x: 0, y: 0, width: size.width , height: size.height)
                image.draw(in: rect)
            }
            compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return compositeImage
        case .vertical:
            size.height = images.compactMap({$0.size.height}).reduce(0, +)
            size.width = images.compactMap({$0.size.width}).min() ?? 0
            UIGraphicsBeginImageContext(size)
            var y: CGFloat = 0
            images.forEach { image in
                let height = image.size.height
                let rect = CGRect(x: 0, y: y, width: size.width , height: height)
                image.draw(in: rect)
                y += height
            }
            compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return compositeImage
        case .horisontal:
            size.height = images.compactMap({$0.size.height}).min() ?? 0
            size.width = images.compactMap({$0.size.width}).reduce(0, +)
            debugPrint("Новый размер полотна \(size)")
            UIGraphicsBeginImageContext(size)
            var x: CGFloat = 0
            images.forEach { image in
                let width = image.size.width
                let rect = CGRect(x: x, y: 0, width: width , height: size.height)
                image.draw(in: rect)
                x += width
            }
            compositeImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return compositeImage
        case .place:
            return compositeImage
        }
    }
    
    // тип изменения изображения
    enum TypeComposite { case blend, vertical, horisontal, place }
}

extension CGImage {
    var png: Data? {
        guard let mutableData = CFDataCreateMutable(nil, 0) else { return nil }
        guard let destination = CGImageDestinationCreateWithData(mutableData, "public.png" as CFString, 1, nil) else { return nil }
        CGImageDestinationAddImage(destination, self, nil)
        guard CGImageDestinationFinalize(destination) else { return nil }
        return mutableData as Data
    }
}
