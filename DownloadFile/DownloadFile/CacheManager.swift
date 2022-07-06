
import Foundation
import Alamofire



enum DownloadStatus<T,S> { 
    case inPregress(T)
    case success(S)
    case failure(Error?)
    case cancled
}



class CacheManager: Subject {
    
    
    static let shared = CacheManager()
    
    
    struct ObserverHandler {
        var identifire: [String]!
        var observer: Observer!
    }
    
    
    private var observers: [ObserverHandler] = []
    
    
    func register(o: Observer, identifire: [String]) {
        // Adds a new observer to the ArrayList
        observers.append(ObserverHandler(identifire: identifire, observer: o));
        
    }
    
    
    
    func unregister(o: Observer) {
        // Get the index of the observer to delete
        
        guard let observerIndex: Int = (observers.firstIndex { (element) -> Bool in
            return element.observer === o
        }) else  {
            return
        }
        observers.remove(at: observerIndex)
        
        
    }
    
    func notifyObserver(identifire: String, status: DownloadStatus<Progress, URL?>) {
        // Cycle through all observers and notifies them of
        // price changes
        
        for observer in observers {
            if observer.identifire.contains(identifire){
                observer.observer.update(for: identifire, status: status);
            }
        }
        
    }
    
    public static var downloadRequest: [String: DownloadRequest] = [:]
    
    
    
    
    //    fileprivate var upload: UploadRequest?
    
    //    private lazy var mainDirectoryUrl: URL = {
    //
    //        let documentsUrl = self.fileManager.urls(for: .cachesDirectory, in: .userDomainMask).first!
    //        return documentsUrl
    //    }()
    
    //    func getFileWith(stringUrl: String, completionHandler: @escaping (Result<URL>) -> Void ) {
    //
    //
    //        let file = directoryFor(stringUrl: stringUrl)
    //
    //        //return file path if already exists in cache directory
    //        guard !fileManager.fileExists(atPath: file.path)  else {
    //            completionHandler(Result.success(file))
    //            return
    //        }
    //
    //        DispatchQueue.global().async {
    //
    //            if let videoData = NSData(contentsOf: URL(string: stringUrl)!) {
    //                videoData.write(to: file, atomically: true)
    //
    //                DispatchQueue.main.async {
    //                    completionHandler(Result.success(file))
    //                }
    //            } else {
    //                DispatchQueue.main.async {
    //                    completionHandler(Result.failure(NSError(domain: "Can't download video", code: 001, userInfo: nil)))
    //                }
    //            }
    //        }
    //    }
    //
    //    private func directoryFor(stringUrl: String) -> URL {
    //
    //        let fileURL = URL(string: stringUrl)!.lastPathComponent
    //
    //        let file = self.mainDirectoryUrl.appendingPathComponent(fileURL)
    //
    //        return file
    //    }
    //
    func downloadFiles(url: String, identifire: String, stopDownloading: Bool = false) {
        
        if let downloadRequest: DownloadRequest = CacheManager.downloadRequest[url.toMD5()]{
            
            if stopDownloading {
                downloadRequest.cancel()
                CacheManager.downloadRequest.removeValue(forKey: url.toMD5())
                //                self.notifyObserver(identifire: identifire, status: .cancelled, downloadPercentage: nil)
                
                self.notifyObserver(identifire: identifire, status: .cancled)
            }else{
                startRenderProgress(downloadRequest, url, identifire: identifire)
                
            }
            
        } else{
            let destination: DownloadRequest.DownloadFileDestination = DownloadRequest.suggestedDownloadDestination(for: .documentDirectory)
            
            let destinationFile =  DownloadRequest.suggestedDownloadDestination(for: .documentDirectory,
                                                                            in: .userDomainMask,
                                                                            with: [DownloadRequest.DownloadOptions.removePreviousFile])
            
            
            if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first,
               let fileURl = URL(string: url){
                
                let fileURL = dir.appendingPathComponent(fileURl.lastPathComponent)
                
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    self.notifyObserver(identifire: identifire, status: .success(fileURL))
                    return
                }
                
            }
            
            
            let downloadRequest = Alamofire.download(url, method: .get, to: destination)
            CacheManager.downloadRequest[url.toMD5()] = downloadRequest
            
            startRenderProgress(downloadRequest, url, identifire: identifire)
        }
        
    }
    
    
    fileprivate func startRenderProgress(_ downloadRequest: DownloadRequest, _ url: String, identifire: String) {
        downloadRequest.downloadProgress(closure: { (progress) in
            self.notifyObserver(identifire: identifire, status: .inPregress(progress))
        }).response(completionHandler: { (DefaultDownloadResponse) in
            //            print(DefaultDownloadResponse)
            DispatchQueue.main.async {
                if DefaultDownloadResponse.error == nil{
                    self.notifyObserver(identifire: identifire, status: .success(DefaultDownloadResponse.destinationURL))
                }else{
                    self.notifyObserver(identifire: identifire, status: .failure(DefaultDownloadResponse.error))
                }
            }
            CacheManager.downloadRequest.removeValue(forKey: url.toMD5())
            
        })
    }
    
    
    
}


extension Alamofire.DownloadRequest {
    open class func suggestedDownloadDestination(
        for directory: FileManager.SearchPathDirectory = .documentDirectory,
        in domain: FileManager.SearchPathDomainMask = .userDomainMask,
        with options: DownloadOptions)
    -> DownloadFileDestination
    {
        return { temporaryURL, response in
            let destination = DownloadRequest.suggestedDownloadDestination(for: directory, in: domain)(temporaryURL, response)
            return (destination.destinationURL, options)
        }
    }
}
