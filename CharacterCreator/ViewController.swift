import UIKit
import WatchConnectivity

class ViewController: UIViewController {
    
    
    let collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 100, height: 100)
        layout.minimumLineSpacing = 20
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.showsHorizontalScrollIndicator = false
        return cv
    }()
    
    let ageTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Возраст"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textAlignment = .center
        return tf
    }()
    
    let heightTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Рост"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textAlignment = .center
        return tf
    }()
    
    let weightTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Вес"
        tf.borderStyle = .roundedRect
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.textAlignment = .center
        return tf
    }()
    
    let createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    var selectedAvatarIndex: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        
        
        view.addSubview(collectionView)
        view.addSubview(ageTextField)
        view.addSubview(heightTextField)
        view.addSubview(weightTextField)
        view.addSubview(createButton)
        
        
        setupConstraints()
        
        
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(AvatarCell.self, forCellWithReuseIdentifier: "AvatarCell")
        
        
        createButton.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        
        
        if WCSession.isSupported() {
            let session = WCSession.default
            session.delegate = self
            session.activate()
        }
        
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleReceivedMessage(_:)), name: Notification.Name("didReceiveMessage"), object: nil)
    }
    
    @objc func createButtonTapped() {
        
        guard let age = ageTextField.text, !age.isEmpty,
              let height = heightTextField.text, !height.isEmpty,
              let weight = weightTextField.text, !weight.isEmpty else {
            showAlert(message: "Пожалуйста, заполните все поля")
            return
        }
        
        
        if WCSession.default.isReachable {
            
            sendMessageToWatch(age: age, height: height, weight: weight)
        } else {
            showAlert(message: "Часы недоступны")
        }
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Ошибка", message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func sendMessageToWatch(age: String, height: String, weight: String) {
        let message = ["age": age, "height": height, "weight": weight]
        WCSession.default.sendMessage(message, replyHandler: nil) { error in
            print("Error sending message to watch: \(error.localizedDescription)")
        }
    }
    
    @objc func handleReceivedMessage(_ notification: Notification) {
        if let message = notification.object as? [String: Any] {
            if let age = message["age"] as? String,
               let height = message["height"] as? String,
               let weight = message["weight"] as? String {
                DispatchQueue.main.async {
                    self.ageTextField.text = age
                    self.heightTextField.text = height
                    self.weightTextField.text = weight
                }
            }
        }
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 120),
            
            ageTextField.topAnchor.constraint(equalTo: collectionView.bottomAnchor, constant: 20),
            ageTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            ageTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            ageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            heightTextField.topAnchor.constraint(equalTo: ageTextField.bottomAnchor, constant: 20),
            heightTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            heightTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            heightTextField.heightAnchor.constraint(equalToConstant: 40),
            
            weightTextField.topAnchor.constraint(equalTo: heightTextField.bottomAnchor, constant: 20),
            weightTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            weightTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            weightTextField.heightAnchor.constraint(equalToConstant: 40),
            
            createButton.topAnchor.constraint(equalTo: weightTextField.bottomAnchor, constant: 20),
            createButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            createButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            createButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
}

extension ViewController: WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if let error = error {
            print("WCSession activation failed with error: \(error.localizedDescription)")
        } else {
            print("WCSession activated with state: \(activationState.rawValue)")
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {}
    
    func sessionDidDeactivate(_ session: WCSession) {
        WCSession.default.activate()
    }
    
    func session(_ session: WCSession, didReceiveMessage message: [String : Any]) {
        NotificationCenter.default.post(name: Notification.Name("didReceiveMessage"), object: message)
    }
}

extension ViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AvatarCell", for: indexPath) as! AvatarCell
        
        
        let avatarName = "avatar_\(indexPath.item)"
        
        
        if let avatarImage = UIImage(named: avatarName) {
            cell.configure(with: avatarImage)
        } else {
            
            cell.configure(with: UIImage())
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let previousIndex = selectedAvatarIndex {
            collectionView.deselectItem(at: previousIndex, animated: true)
        }
        
        selectedAvatarIndex = indexPath
        collectionView.selectItem(at: indexPath, animated: true, scrollPosition: .centeredHorizontally)
    }
}

class AvatarCell: UICollectionViewCell {
    private let avatarImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.addSubview(avatarImageView)
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with image: UIImage) {
        avatarImageView.image = image
    }
    
    func setupConstraints() {
        NSLayoutConstraint.activate([
            avatarImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            avatarImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            avatarImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            avatarImageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }
}
