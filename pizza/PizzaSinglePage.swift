//
//  PizzaSinglePage.swift
//  pizza
//
//  Created by Németh Bence on 2024. 12. 10..
//

import SwiftUI

struct PizzaSinglePage: View {
    @State private var pizza: Pizza? = nil
    @State private var isPending: Bool = false
    let pizzaId: Int

    var body: some View {
        VStack {
            if isPending || pizza == nil {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                VStack {
                    if let pizza = pizza {
                        VStack {
                            Text(pizza.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)

                            Text("Gluténmentes: \(pizza.isGlutenFree != 0 ? "igen" : "nem")")
                                .font(.title2)
                                .foregroundColor(pizza.isGlutenFree != 0 ? .green : .red)

                            AsyncImage(url: URL(string: pizza.kepURL ?? "https://via.placeholder.com/400x800")) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(maxHeight: 500)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }

                            HStack {
                                NavigationLink(destination: PizzaModPage(pizzaId: pizza.id)) {
                                    Image(systemName: "pencil")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                }

                                Spacer()

                                NavigationLink(destination: PizzaListPage()) {  // Navigálj a PizzaListPage-ra
                                       Image(systemName: "arrow.backward.circle")
                                           .font(.title)
                                           .foregroundColor(.gray)
                                   }
                               }
                            .padding()
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(15)
                        .shadow(radius: 10)
                    }
                }
                .padding()
            }
        }
        .onAppear {
            print("Pizza ID: \(pizzaId)")
            fetchPizza()
        }
        .navigationTitle("Pizza Részletei")
    }

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
}

struct PizzaSinglePage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PizzaSinglePage(pizzaId: 1)
        }
    }
}
