import UIKit

final class TrackerViewController: UIViewController {
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let textField = searchBar.value(forKey: "searchField") as? UITextField {
            //textField.clearButtonMode = .never
            textField.font = UIFont.systemFont(ofSize: 17)
        }
    }

}
