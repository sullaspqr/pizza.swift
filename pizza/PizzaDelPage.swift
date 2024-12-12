//
//  PizzaDelPage.swift
//  pizza
//
//  Created by Németh Bence on 2024. 12. 10..
//
import SwiftUI

struct PizzaDelPage: View {
    @State private var pizza: Pizza? = nil
    @State private var isPending: Bool = false
    @Environment(\.presentationMode) var presentationMode
    let pizzaId: Int

    var body: some View {
        VStack {
            if isPending || pizza == nil {
                ProgressView()
            } else {
                VStack(spacing: 20) {
                    Text("Törlendő elem: \(pizza?.name ?? "Ismeretlen")")
                        .font(.headline)
                    
                    Text(pizza?.isGlutenFree != 0 ? "Gluténmentes: Igen" : "Gluténmentes: Nem")
                        .foregroundColor(.secondary)
                    
                    if let imageUrl = pizza?.kepURL, let url = URL(string: imageUrl) {
                        AsyncImage(url: url) { image in
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(height: 300)
                                .cornerRadius(10)
                        } placeholder: {
                            ProgressView()
                        }
                    } else {
                        Image(systemName: "photo")
                            .resizable()
                            .scaledToFit()
                            .frame(height: 300)
                            .foregroundColor(.gray)
                    }

                    HStack {
                        NavigationLink(destination: PizzaListPage()) {
                            Label("Mégsem", systemImage: "arrow.backward")
                                .padding()
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }

                        Button(action: deletePizza) {
                            Label("Törlés", systemImage: "trash")
                                .padding()
                                .background(Color.red.opacity(0.8))
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                    }
                }
                .padding()
            }
        }
        .onAppear {
            print("Pizza ID: \(pizzaId)")
            fetchPizza()
        }
        .navigationTitle("Pizza törlése")
    }

    // API hívás: Adatok letöltése
    func fetchPizza() {
        guard let url = URL(string: "https://pizza.kando-dev.eu/Pizza/\(pizzaId)") else { return }
        isPending = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isPending = false }

            guard let data = data else { return }
            do {
                let decodedPizza = try JSONDecoder().decode(Pizza.self, from: data)
                DispatchQueue.main.async {
                    pizza = decodedPizza
                }
            } catch {
                print("Hiba az adatok letöltésekor: \(error)")
            }
        }.resume()
    }

    // API hívás: Törlés
    func deletePizza() {
        guard let url = URL(string: "https://pizza.kando-dev.eu/Pizza/\(pizzaId)") else { return }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        URLSession.shared.dataTask(with: request) { _, response, error in
            guard error == nil else {
                print("Hiba a törlés során: \(error!)")
                return
            }

            DispatchQueue.main.async {
                presentationMode.wrappedValue.dismiss()
            }
        }.resume()
    }
}

struct PizzaDelPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PizzaDelPage(pizzaId: 1)
        }
    }
}
