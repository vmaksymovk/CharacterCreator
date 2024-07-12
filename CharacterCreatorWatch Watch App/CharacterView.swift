import SwiftUI
import WatchConnectivity

struct CharacterView: View {
    @State private var avatarImage: UIImage? = UIImage(named: "avatar_1")
    @State private var age: String = "25"
    @State private var height: String = "180"
    @State private var weight: String = "75"
    @State private var isAnimating = false

    var body: some View {
        NavigationView {
            VStack {
                Image(uiImage: avatarImage ?? UIImage(named: "avatar_1")!)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true), value: isAnimating)
                    .onAppear {
                        self.isAnimating = true
                    }

                Text("Возраст: \(age)")
                Text("Рост: \(height)")
                Text("Вес: \(weight)")
                    .padding(.bottom, 20)

                HStack {
                    Button(action: editCharacter) {
                        Text("Редактировать")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: sendDataToPhone) {
                        Text("Сохранить")
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal)
                .navigationTitle("Персонаж")
            }
        }
        .onAppear {
            receiveDataFromPhone()
        }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("didReceiveMessage"))) { notification in
            if let message = notification.object as? [String: Any] {
                if let age = message["age"] as? String,
                   let height = message["height"] as? String,
                   let weight = message["weight"] as? String {
                    DispatchQueue.main.async {
                        self.age = age
                        self.height = height
                        self.weight = weight
                    }
                }
            }
        }
    }

    func editCharacter() {
        // Логика редактирования персонажа
    }

    func sendDataToPhone() {
        guard WCSession.default.isReachable else {
            print("Часы недоступны")
            return
        }

        let data = ["age": age, "height": height, "weight": weight]
        WCSession.default.sendMessage(data, replyHandler: nil) { error in
            print("Failed to send message: \(error.localizedDescription)")
        }
    }

    func receiveDataFromPhone() {
        if WCSession.default.isReachable {
            WCSession.default.sendMessage(["request": "data"], replyHandler: { response in
                if let age = response["age"] as? String,
                   let height = response["height"] as? String,
                   let weight = response["weight"] as? String {
                    DispatchQueue.main.async {
                        self.age = age
                        self.height = height
                        self.weight = weight
                    }
                }
            }, errorHandler: { error in
                print("Error receiving data: \(error.localizedDescription)")
            })
        }
    }
}

