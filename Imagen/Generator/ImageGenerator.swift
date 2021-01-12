import UIKit


class ImageGenerator {

    struct ImageFormats : OptionSet {
        let rawValue: Int
        static let png = ImageFormats(rawValue: 1 << 0)
        static let jpeg = ImageFormats(rawValue: 1 << 1)
    }
    
    var imageFormats: ImageFormats = [.png]
    var jpegQuality: Float = 0.65
    var imageWidth: ClosedRange<Int> = 100...2160
    var imageHeight: ClosedRange<Int> = 100...2160
    
    private(set) var progress: Progress?
    
    func generate(imageCount: Int) {
        let parentProgress = Progress(totalUnitCount: Int64(imageCount))
        self.progress = parentProgress
        
        let random = Random(seed: Int(ProcessInfo.processInfo.systemUptime))
        
        let settings = BatchSettings(
            imageWidth: imageWidth,
            imageHeight: imageHeight,
            pngOn: imageFormats.contains(.png),
            jpegOn: imageFormats.contains(.jpeg),
            jpegQuality: jpegQuality)

        asyncGenerateBatch(imageCount, parentProgress: parentProgress, settings: settings, random: random)
    }
    
    func cancel() {
        progress?.cancel()
    }
}


extension ImageGenerator {
    
    func estimateTotalSizeForImageCount(_ imageCount: Int) -> Int {
        return imageCount * estimatedImageSize
    }
    
    func estimateImageCountForTotalSize(_ totalSize: Int) -> Int {
        return Int((Double(totalSize) / Double(estimatedImageSize)).rounded())
    }
    
    private var estimatedImageSize: Int {
        return ((imageWidth.upperBound + imageWidth.lowerBound) * (imageHeight.upperBound + imageHeight.lowerBound) / 64)
    }
}


private struct BatchSettings {
    let imageWidth: ClosedRange<Int>
    let imageHeight: ClosedRange<Int>
    let pngOn: Bool
    let jpegOn: Bool
    let jpegQuality: Float
}


private func asyncGenerateBatch(_ pendingWork: Int, parentProgress: Progress, settings: BatchSettings, random: Random) {
    guard pendingWork > 0 else { return }
    guard !parentProgress.isCancelled else { return }
    
    DispatchQueue.global(qos: .userInitiated).async {
        let child = Progress(totalUnitCount: 1, parent: parentProgress, pendingUnitCount: 1)
        
        var jpegOn = settings.jpegOn
        var pngOn = settings.pngOn
        if jpegOn && pngOn {
            if random.next() % 2 == 0 {
                jpegOn = false
            }
            else {
                pngOn = false
            }
        }

        let imageSize = randomSizeInRange(width: settings.imageWidth, height: settings.imageHeight, random: random)

        autoreleasepool {
            let processor = ImageProcessor()
            if let image = processor.randomImageOfSize(imageSize, random: random) {
                if jpegOn, let data = image.jpegData(compressionQuality: CGFloat(settings.jpegQuality)) {
                    writeToSavedPhotosAlbumImageData(data)
                }
                else if pngOn, let data = image.pngData() {
                    writeToSavedPhotosAlbumImageData(data)
                }
            }
        }
        
        child.completedUnitCount = 1
        asyncGenerateBatch(pendingWork - 1, parentProgress: parentProgress, settings: settings, random: random)
    }
}


private func randomSizeInRange(width: ClosedRange<Int>, height: ClosedRange<Int>, random: Random) -> CGSize {
    let ratio: Float = 3 / 4
    var w = random.inRange(width)
    var h = random.inRange(height)
    if w > h {
        h = max(h, Int(Float(w) * ratio))
    }
    else {
        w = max(w, Int(Float(h) * ratio))
    }
    return CGSize(width: w, height: h)
}


private func writeToSavedPhotosAlbumImageData(_ data: Data) {
    guard let image = UIImage(data: data)
    else { return }
    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
}
