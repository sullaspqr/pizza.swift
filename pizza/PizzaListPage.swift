import SwiftUI

struct PizzaListPage: View {
    @State private var pizzas: [Pizza] = []
    @State private var isFetchPending: Bool = false

    var body: some View {
        VStack {
            // Új pizza létrehozása gomb
            NavigationLink(destination: PizzaCreatePage()) {
                Text("Új Pizza")
                    .bold()
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding(.horizontal)
            }
            .padding(.top)

            if isFetchPending {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                pizzaListView
            }
        }
        .onAppear(perform: fetchPizzas)
        .navigationTitle("Pizzák")
        .background(Color(UIColor.systemGray6))
    }

    private var pizzaListView: some View {
        ScrollView {
            LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))]) {
                ForEach(pizzas) { pizza in
                    PizzaView(pizza: pizza)
                }
            }
            .padding()
        }
    }

    func fetchPizzas() {
        guard let url = URL(string: "https://pizza.kando-dev.eu/Pizza") else {
            print("Érvénytelen URL") // Nyomtatjuk, ha a URL nem megfelelő
            return
        }
        isFetchPending = true

        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isFetchPending = false }

            if let error = error {
                print("Hálózati hiba: \(error.localizedDescription)")
                return
            }

            guard let data = data else {
                print("Nem kaptam adatokat!")
                return
            }

            do {
                let decodedPizzas = try JSONDecoder().decode([Pizza].self, from: data)
                DispatchQueue.main.async {
                    pizzas = decodedPizzas
                }
            } catch {
                print("Hiba az adatok dekódolásában: \(error)")
            }
        }.resume()
    }
}

struct PizzaView: View {
    let pizza: Pizza

    var body: some View {
        VStack {
            Text(pizza.name)
                .font(.headline)
                .foregroundColor(.black)

            Text("Gluténmentes: \(pizza.isGlutenFree != 0 ? "Igen" : "Nem")")
                .font(.subheadline)
                .foregroundColor(pizza.isGlutenFree != 0 ? .green : .red)

            NavigationLink(destination: PizzaSinglePage(pizzaId: pizza.id)) {
                AsyncImage(url: URL(string: pizza.kepURL ?? "https://via.placeholder.com/400x800")) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(height: 150)
                } placeholder: {
                    ProgressView()
                }
            }
            .buttonStyle(PlainButtonStyle())

            HStack {
                NavigationLink(destination: PizzaModPage(pizzaId: pizza.id)) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
                .buttonStyle(PlainButtonStyle())

                NavigationLink(destination: PizzaDelPage(pizzaId: pizza.id)) {
                    Image(systemName: "trash")
                        .foregroundColor(.red)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 5)
    }
}

struct PizzaListPage_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            PizzaListPage()
        }
    }
}
