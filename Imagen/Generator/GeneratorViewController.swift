import UIKit


class GeneratorViewController: UIViewController {
    
    var viewModel: GeneratorViewModel!
    
    @IBOutlet weak var generateButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var numberOfImagesLabel: UILabel!
    @IBOutlet weak var estimatedSizeLabel: UILabel!
    @IBOutlet weak var numberOfImagesSlider: UISlider!
    @IBOutlet weak var estimatedSizeSlider: UISlider!
    @IBOutlet weak var generatePngSwitch: UISwitch!
    @IBOutlet weak var generateJpegSwitch: UISwitch!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBAction func handleGeneratorButton(_ sender: Any) {
        viewModel.startGeneration()
    }
    
    @IBAction func handleCancelButton(_ sender: Any) {
        viewModel.cancelGeneration()
    }
    
    @IBAction func handleNumberOfImagesSlider(_ sender: Any) {
        viewModel.numberOfImagesSliderInteract(numberOfImagesSlider.value)
        numberOfImagesLabel.text = viewModel.numberOfImagesText
    }
    
    @IBAction func handleEstimatedSizeSlider(_ sender: Any) {
        viewModel.estimatedSizeSliderInteract(estimatedSizeSlider.value)
        estimatedSizeLabel.text = viewModel.estimatedSizeText
    }
    
    @IBAction func handleGeneratePngSwitch(_ sender: Any) {
        viewModel.isPngGenerationOn = generatePngSwitch.isOn
    }
    
    @IBAction func handleGenerateJpegSwitch(_ sender: Any) {
        viewModel.isJpegGenerationOn = generateJpegSwitch.isOn
    }
}


extension GeneratorViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel = GeneratorViewModel()
        viewModel.delegate = self
        
        generatePngSwitch.isOn = viewModel.isPngGenerationOn
        generateJpegSwitch.isOn = viewModel.isJpegGenerationOn
        numberOfImagesSlider.value = viewModel.numberOfImagesSlider
        estimatedSizeSlider.value = viewModel.estimatedSizeSlider
        numberOfImagesLabel.text = viewModel.numberOfImagesText
        estimatedSizeLabel.text = viewModel.estimatedSizeText
    }
}


extension GeneratorViewController : GeneratorViewModelDelegate {
    
    func viewModel(_ viewModel: GeneratorViewModel, didStartGeneration sender: Any) {
        activityIndicator.startAnimating()
        generateButton.isHidden = true
        cancelButton.isHidden = false
    }
    
    func viewModel(_ viewModel: GeneratorViewModel, didStopGeneration sender: Any) {
        activityIndicator.stopAnimating()
        cancelButton.isHidden = true
        generateButton.isHidden = false
    }
    
    func viewModel(_ viewModel: GeneratorViewModel, didChangeNumberOfImages countSlider: Float) {
        numberOfImagesSlider.value = countSlider
        numberOfImagesLabel.text = viewModel.numberOfImagesText
    }
    
    func viewModel(_ viewModel: GeneratorViewModel, didChangeSizeEstimation sizeSlider: Float) {
        estimatedSizeSlider.value = sizeSlider
        estimatedSizeLabel.text = viewModel.estimatedSizeText
    }
    
    func viewModel(_ viewModel: GeneratorViewModel, didChangePngGeneration isOn: Bool) {
        generatePngSwitch.isOn = isOn
    }
    
    func viewModel(_ viewModel: GeneratorViewModel, didChangeJpegGeneration isOn: Bool) {
        generateJpegSwitch.isOn = isOn
    }
    
    func viewModel(_ viewModel: GeneratorViewModel, startedObservingProgress progress: Progress?) {
        progressView.observedProgress = progress
    }
}
