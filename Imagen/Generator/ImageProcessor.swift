import UIKit


class ImageProcessor {
    
    func randomImageOfSize(_ imageSize: CGSize, random: Random, scale: CGFloat = 1) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(imageSize, true, scale)
        defer {
            UIGraphicsEndImageContext()
        }
        
        guard let context = UIGraphicsGetCurrentContext()
        else { return nil }
        
        random.happyColor().setFill()
        context.fill(CGRect(origin: .zero, size: imageSize))
        
        let n = random.inRange(10...Int(10 + max(imageSize.width, imageSize.height)/50))
        for _ in 0..<n {
            random.color().setFill()
            context.fill(random.rectInSize(imageSize))
        }
        
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}
