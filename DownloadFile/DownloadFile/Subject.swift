
import Foundation

protocol Subject {
    func register(o: Observer, identifire: [String]);
    func unregister(o: Observer);
 

}
