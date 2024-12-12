//
//  PizzaCreatePage.swift
//  pizza
//
//  Created by Németh Bence on 2024. 12. 10..
//

import SwiftUI

struct PizzaCreatePage: View {
    @State private var name: String = ""
    @State private var isGlutenFree: Int = 0
    @State private var kepURL: String = ""
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        VStack(spacing: 20) {
            Text("Új Pizza Létrehozása")
                .font(.title)
                .padding()

            Form {
                Section(header: Text("Pizza Adatok")) {
                    TextField("Pizza név", text: $name)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical)

                    Picker("Gluténmentes", selection: $isGlutenFree) {
                        Text("Nem").tag(0)
                        Text("Igen").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.vertical)

                    TextField("Kép URL-je", text: $kepURL)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.vertical)
                }
            }
            .padding()

            Button(action: createPizza) {
                Text("Küldés")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.horizontal)

            Spacer()
        }
        .navigationTitle("Új Pizza")
    }

    func createPizza() {
        guard let url = URL(string: "https://pizza.kando-dev.eu/Pizza") else { return }

        let newPizza = [
            "name": name,
            "isGlutenFree": isGlutenFree,
            "kepURL": kepURL
        ] as [String : Any]

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: newPizza, options: [])
            request.httpBody = jsonData
        } catch {
            print("Hiba a JSON létrehozásakor: \(error)")
            return
        }

        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print("Hiba a kérés során: \(error!)")
                return
            }

            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }.resume()
    }
}

struct PizzaCreatePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PizzaCreatePage()
        }
    }
}
