//
//  FCPExtensions.swift
//  flutter_carplay
//
//  Created by Oğuzhan Atalay on 21.08.2021.
//

extension UIImage {
    convenience init?(withURL url: URL) throws {
        let imageData = try Data(contentsOf: url)
        self.init(data: imageData)
    }

    @available(iOS 14.0, *)
    func fromFlutterAsset(name: String) -> UIImage {
        guard let registrar = SwiftFlutterCarplayPlugin.registrar,
              let fileName = URL(string: name)?.lastPathComponent else {
            return UIImage(systemName: "questionmark")!
        }
        
        let imageAsset = UIImage().imageAsset
        
        // Register images for different scales
        for scale in [1, 2, 3] {
            let scaleSuffix = scale > 1 ? "\(scale)x/" : ""
            let imageName = name.replacingOccurrences(of: "\(fileName)", with: "\(scaleSuffix)\(fileName)")
            let key = registrar.lookupKey(forAsset: imageName)
            
            if let image = UIImage(named: key) {
                let config = UITraitCollection(displayScale: CGFloat(scale))
                imageAsset?.register(image, with: config)
            }
        }
        
        // Get the image for the current display scale
        let currentScale = UIScreen.main.scale
        return imageAsset?.image(with: UITraitCollection(displayScale: currentScale)) ?? UIImage(systemName: "questionmark")!
    }

    func resizeImageTo(size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: CGRect(origin: CGPoint.zero, size: size))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return newImage
    }
}

extension String {
    func match(_ regex: String) -> [[String]] {
        let nsString = self as NSString
        return (try? NSRegularExpression(pattern: regex, options: []))?.matches(in: self, options: [], range: NSMakeRange(0, nsString.length)).map { match in
            (0 ..< match.numberOfRanges).map { match.range(at: $0).location == NSNotFound ? "" : nsString.substring(with: match.range(at: $0)) }
        } ?? []
    }
}
