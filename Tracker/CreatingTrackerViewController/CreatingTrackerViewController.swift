import UIKit

// MARK: - CreatingTrackerViewController

final class CreatingTrackerViewController: UIViewController {
    weak var delegate: TrackerCreationDelegate?
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .ypWhite
        
        navigationItem.title = "Создание трекера"
        
        setUpCreatingTrackerViewController()
    }
    
    // MARK: - Setup UI
    
    func setUpCreatingTrackerViewController() {
        let habitButton = UIButton()
        habitButton.setTitle("Привычка", for: .normal)
        habitButton.setTitleColor(.ypWhite, for: .normal)
        habitButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        habitButton.layer.cornerRadius = 16
        habitButton.backgroundColor = .ypBlack
        habitButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(habitButton)
        
        NSLayoutConstraint.activate([
            //habitButton.topAnchor.constraint(equalTo: header.bottomAnchor, constant: 295),
            habitButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            habitButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            habitButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            habitButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        let irregularEventButton = UIButton()
        irregularEventButton.setTitle("Нерегулярное событие", for: .normal)
        irregularEventButton.setTitleColor(.ypWhite, for: .normal)
        irregularEventButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        irregularEventButton.layer.cornerRadius = 16
        irregularEventButton.backgroundColor = .ypBlack
        irregularEventButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(irregularEventButton)
        
        NSLayoutConstraint.activate([
            irregularEventButton.topAnchor.constraint(equalTo: habitButton.bottomAnchor, constant: 16),
            irregularEventButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            irregularEventButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            irregularEventButton.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        habitButton.addTarget(self, action: #selector(habitButtonTapped), for: .touchUpInside)
        irregularEventButton.addTarget(self, action: #selector(irregularEventButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc
    func habitButtonTapped() {
        let creatingHabitVC = CreatingHabitViewController()
        creatingHabitVC.delegate = self.delegate
        navigationController?.pushViewController(creatingHabitVC, animated: true)
    }
    
    @objc
    func irregularEventButtonTapped() {
        let irregularEventTrackerVC = CreatingIrregularEventViewContoller()
        irregularEventTrackerVC.delegate = self.delegate
        navigationController?.pushViewController(irregularEventTrackerVC, animated: true)
    }
}
