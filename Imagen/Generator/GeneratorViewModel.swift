import Foundation


protocol GeneratorViewModelDelegate : class {
    
    func viewModel(_ viewModel: GeneratorViewModel, didStartGeneration sender: Any)
    func viewModel(_ viewModel: GeneratorViewModel, didStopGeneration sender: Any)
    func viewModel(_ viewModel: GeneratorViewModel, didChangeNumberOfImages countSlider: Float)
    func viewModel(_ viewModel: GeneratorViewModel, didChangeSizeEstimation sizeSlider: Float)
    func viewModel(_ viewModel: GeneratorViewModel, didChangePngGeneration isOn: Bool)
    func viewModel(_ viewModel: GeneratorViewModel, didChangeJpegGeneration isOn: Bool)
    func viewModel(_ viewModel: GeneratorViewModel, startedObservingProgress progress: Progress?)
}


class GeneratorViewModel {
    
    static let defaultMinNumberOfImages = 1
    static let defaultMaxNumberOfImages = 1000000
    static let defaultMinEstimatedSize = 1024
    static let defaultMaxEstimatedSize = 16000000000
    
    private var minNumberOfImages = defaultMinNumberOfImages
    private var maxNumberOfImages = defaultMaxNumberOfImages
    private var minEstimatedSize = defaultMinEstimatedSize
    private var maxEstimatedSize = defaultMaxEstimatedSize

    weak var delegate: GeneratorViewModelDelegate? {
        didSet {
            delegate?.viewModel(self, startedObservingProgress: progress)
        }
    }
    
    init() {
        repeatedUpdateSizeEstimation()
    }

    private let generator = ImageGenerator()
    
    private var progress: Progress? = Progress() {
        didSet {
            progressCompletionObserver = progress?.observe(\.completedUnitCount) { [weak self] (progress, change) in
                if progress.completedUnitCount >= progress.totalUnitCount {
                    DispatchQueue.main.async {
                        self?.generatorProgressDidComplete()
                    }
                }
            }
            delegate?.viewModel(self, startedObservingProgress: progress)
        }
    }
    private var progressCompletionObserver: NSKeyValueObservation? {
        willSet {
            progressCompletionObserver?.invalidate()
        }
    }
    
    var isPngGenerationOn: Bool {
        get {
            return generator.imageFormats.contains(.png)
        }
        set {
            if newValue {
                generator.imageFormats.update(with: .png)
            }
            else {
                generator.imageFormats.remove(.png)
            }
            if generator.imageFormats.isEmpty {
                isJpegGenerationOn = true
                delegate?.viewModel(self, didChangeJpegGeneration: true)
            }
        }
    }
    
    var isJpegGenerationOn: Bool {
        get {
            return generator.imageFormats.contains(.jpeg)
        }
        set {
            if newValue {
                generator.imageFormats.update(with: .jpeg)
            }
            else {
                generator.imageFormats.remove(.jpeg)
            }
            if generator.imageFormats.isEmpty {
                isPngGenerationOn = true
                delegate?.viewModel(self, didChangePngGeneration: true)
            }
        }
    }
    
    func startGeneration() {
        delegate?.viewModel(self, didStartGeneration: self)
        generator.generate(imageCount: numberOfImages)
        progress = generator.progress
    }
    
    func cancelGeneration() {
        generator.cancel()
        delegate?.viewModel(self, didStopGeneration: self)
    }
    
    private var numberOfImages: Int {
        get {
            return minNumberOfImages + Int((pow(numberOfImagesSlider, 4) * Float(maxNumberOfImages - minNumberOfImages)).rounded())
        }
        set {
            let newValue = max(1, newValue)
            if newValue < Self.defaultMinNumberOfImages {
                minNumberOfImages = newValue
            }
            if newValue > Self.defaultMaxNumberOfImages {
                maxNumberOfImages = newValue
            }
            let linear = Float(min(newValue, maxNumberOfImages) - minNumberOfImages) / Float(maxNumberOfImages - minNumberOfImages)
            numberOfImagesSlider = pow(linear, 1/4)
        }
    }

    private(set) var numberOfImagesSlider: Float = 0
    
    func numberOfImagesSliderInteract(_ value: Float) {
        minNumberOfImages = Self.defaultMinNumberOfImages
        maxNumberOfImages = Self.defaultMaxNumberOfImages
        numberOfImagesSlider = value
        repeatedUpdateSizeEstimation()
    }
    
    var numberOfImagesText: String? {
        let value = numberOfImages
        let string = decimalNumberFormatter(value)
        let plural = value == 1 ? "image" : "images"
        return "\(string) \(plural)"
    }
    
    private var estimatedSizeBytes: Int {
        get {
            return minEstimatedSize + Int((pow(estimatedSizeSlider, 6) * Float(maxEstimatedSize - minEstimatedSize)).rounded())
        }
        set {
            let newValue = max(1, newValue)
            if newValue < Self.defaultMinEstimatedSize {
                minEstimatedSize = newValue
            }
            if newValue > Self.defaultMaxEstimatedSize {
                maxEstimatedSize = newValue
            }
            let linear = Float(min(newValue, maxEstimatedSize) - minEstimatedSize) / Float(maxEstimatedSize - minEstimatedSize)
            estimatedSizeSlider = pow(linear, 1/6)
        }
    }
    
    private(set) var estimatedSizeSlider: Float = 0

    func estimatedSizeSliderInteract(_ value: Float) {
        minEstimatedSize = Self.defaultMinEstimatedSize
        maxEstimatedSize = Self.defaultMaxEstimatedSize
        estimatedSizeSlider = value
        repeatedUpdateNumberOfImagesEstimation()
    }
    
    private static let bytesFormatter = ByteCountFormatter()
    
    var estimatedSizeText: String? {
        let value = Self.bytesFormatter.string(fromByteCount: Int64(estimatedSizeBytes))
        return "approx. \(value) total"
    }
}


private extension GeneratorViewModel {
    
    func decimalNumberFormatter(_ value: Int) -> String {
        var value = value
        var unit = ""
        if value >= 1000000 {
            value = Int((Float(value) / 1000000).rounded())
            unit = " M"
        }
        else if value >= 1000 {
            value = Int((Float(value) / 1000).rounded())
            unit = " K"
        }
        return "\(value)\(unit)"
    }

    func repeatedUpdateNumberOfImagesEstimation() {
        let imageCount = generator.estimateImageCountForTotalSize(estimatedSizeBytes)
        numberOfImages = imageCount
        delegate?.viewModel(self, didChangeNumberOfImages: numberOfImagesSlider)
    }
    
    func repeatedUpdateSizeEstimation() {
        let size = generator.estimateTotalSizeForImageCount(numberOfImages)
        estimatedSizeBytes = size
        delegate?.viewModel(self, didChangeSizeEstimation: estimatedSizeSlider)
    }

    func generatorProgressDidComplete() {
        delegate?.viewModel(self, didStopGeneration: self)
    }
}
