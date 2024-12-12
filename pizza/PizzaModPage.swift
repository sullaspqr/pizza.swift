//
//  PizzaModPage.swift
//  pizza
//
//  Created by Németh Bence on 2024. 12. 10..
//
import SwiftUI

struct PizzaModPage: View {
    @State private var pizza: Pizza? = nil
    @State private var modName: String = ""
    @State private var modIsGlutenFree: Int = 0
    @State private var modKepUrl: String = ""
    @State private var isPending: Bool = true // Kezdetben igaz, amíg az adatokat betöltjük.
    @Environment(\.presentationMode) var presentationMode
    
    let pizzaId: Int
    
    var body: some View {
        VStack {
            if isPending {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
            } else {
                Form {
                    Section(header: Text("Pizza ID")) {
                        Text("\(pizza?.id ?? 0)")
                    }
                    
                    Section(header: Text("Pizza név")) {
                        TextField("Pizza név", text: $modName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                    Section(header: Text("Gluténmentes")) {
                        Toggle(isOn: Binding(
                            get: { modIsGlutenFree == 1 },
                            set: { modIsGlutenFree = $0 ? 1 : 0 }
                        )) {
                            Text(modIsGlutenFree == 1 ? "Igen" : "Nem")
                        }
                    }
                    
                    Section(header: Text("Kép URL")) {
                        TextField("Kép URL", text: $modKepUrl)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                        if let url = URL(string: modKepUrl), !modKepUrl.isEmpty {
                            AsyncImage(url: url) { image in
                                image
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 175)
                                    .cornerRadius(10)
                            } placeholder: {
                                ProgressView()
                            }
                        } else {
                            Text("Nincs kép elérhető")
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Button(action: submitPizza) {
                        Text("Mentés")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
        }
        .navigationTitle("Pizza Módosítása")
        .padding()
        .onAppear {
            fetchPizza()
        }
        .navigationBarItems(leading: HStack {
                    NavigationLink(destination: PizzaListPage()) {
                        Image(systemName: "arrow.left.circle.fill")
                            .imageScale(.large)
                            .foregroundColor(.blue)
                    }
                    Spacer()
                    Button(action: submitPizza) {
                        Text("Mentés")
                            .frame(maxWidth: .infinity) // Ezt elhagyhatod, ha kisebb gombot szeretnél
                            .padding(.horizontal, 20) // Csökkentheted a padding-ot
                            .padding(.vertical, 8)    // Csökkentheted a vertikális padding-ot
                            .foregroundColor(.white)
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                })
            }
            
    
    func submitPizza() {
        guard let url = URL(string: "https://pizza.kando-dev.eu/Pizza/\(pizzaId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let updatedPizza = Pizza(
            id: pizzaId,
            name: modName,
            isGlutenFree: modIsGlutenFree,
            kepURL: modKepUrl
        )
        
        do {
            let encodedData = try JSONEncoder().encode(updatedPizza)
            request.httpBody = encodedData
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Hiba a mentés során: \(error)")
                    return
                }
                
                DispatchQueue.main.async {
                    presentationMode.wrappedValue.dismiss()
                }
            }.resume()
        } catch {
            print("Hiba a JSON kódolás során: \(error)")
        }
    }
    
    func fetchPizza() {
        guard let url = URL(string: "https://pizza.kando-dev.eu/Pizza/\(pizzaId)") else {
            print("Érvénytelen URL: \(pizzaId)")
            return
        }
        
        isPending = true
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            defer { isPending = false }
            
            if let error = error {
                print("Hiba történt az API hívás során: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("Nem érkezett adat az API-tól.")
                return
            }
            
            do {
                let decodedPizza = try JSONDecoder().decode(Pizza.self, from: data)
                DispatchQueue.main.async {
                    pizza = decodedPizza
                    modName = decodedPizza.name
                    modIsGlutenFree = decodedPizza.isGlutenFree
                    modKepUrl = decodedPizza.kepURL ?? ""
                }
            } catch {
                print("Hiba az adat dekódolásakor: \(error)")
            }
        }.resume()
        
    }
    struct PizzaModPage_Previews: PreviewProvider {
        static var previews: some View {
            NavigationView {
                PizzaModPage(pizzaId: 1) // Pizza ID 1
            }
        }
    }
}
