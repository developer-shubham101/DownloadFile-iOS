
import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var downloadPercentage: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        CacheManager.shared.register(o: self, identifire: [ViewController.remoteFileDetails.id])
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        CacheManager.shared.unregister(o: self)
    }
}
extension SecondViewController: Observer {
    func update(for indentifire: String, status: DownloadStatus<Progress, URL?>) {
        switch status {
        case .cancled:
            
            break
            
        case .inPregress(let progress):
            print(progress)
            downloadPercentage.text = "\(progress) %"
            break
            
        case .success(let destinationUrl):
            if let destinationUrl = destinationUrl {
                print(destinationUrl)
                downloadPercentage.text = "File downloaded at \(destinationUrl)"
            }
            
            break
            
        case .failure(let error):
            print(error)
            break
        }
    }
}
