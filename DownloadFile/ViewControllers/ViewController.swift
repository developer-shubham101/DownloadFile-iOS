
import UIKit


struct FileDetails {
    var url: URL!
    var id: String = ""
}

class ViewController: UIViewController {
    
    @IBOutlet weak var downloadPercentage: UILabel!
    
    static let remoteFileDetails = FileDetails(url: URL(string: "https://test-videos.co.uk/vids/bigbuckbunny/mp4/h264/1080/Big_Buck_Bunny_1080_10s_1MB.mp4")!, id: "0001")

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        CacheManager.shared.register(o: self, identifire: [ViewController.remoteFileDetails.id])
        print("ViewController:: \(ViewController.remoteFileDetails.url.absoluteString)")
        CacheManager.shared.downloadFiles(url: ViewController.remoteFileDetails.url.absoluteString, identifire: ViewController.remoteFileDetails.id)
         
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        CacheManager.shared.unregister(o: self)
    }

   
    @IBAction func didTapNextPage(_ sender: Any) {
        
        let nextViewController = UIStoryboard(name: "Main", bundle:nil).instantiateViewController(withIdentifier: "SecondViewController") as! SecondViewController
        self.navigationController?.pushViewController(nextViewController, animated: true)
        
    }
    
}

extension ViewController: Observer {
    func update(for indentifire: String, status: DownloadStatus<Progress, URL?>) {
        switch status {
        case .cancled:
      
            break
        
        case .inPregress(let progress):
            downloadPercentage.text = "\(progress) %"
            print(progress)
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
