
import Foundation



protocol Observer: class {
    func update(for indentifire: String, status: DownloadStatus<Progress, URL?>)
}  
