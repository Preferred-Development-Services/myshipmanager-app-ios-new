//
//  ContentView.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import SwiftUI


struct Budget: View {
    @State var loading = true
    @State var monthlyBudget = [BudgetLine]()
    @State var monthOffset = 0     // used to select month to show report for
    @State var monthStr: String = ""
    
    var body: some View {
        ScrollView {
            ZStack {
                LazyVStack {
                    ForEach (monthlyBudget) { l in
                        if (l.monthStr != "") {
                            HStack {
                               Text(l.monthStr)
                                    .font(.title)
                            }
                        }
                    }
                    ForEach(monthlyBudget) { l in
                        VStack {
                            ZStack {
                                Color(.systemGray5)
                                .frame(height: 20)
                                Text(l.category)
                            }
                            HStack{
                                VStack {
                                  Text("Budget")
                                  Text(l.budget)
                                }
                                .padding(.leading ,12)
                                Spacer()
                                VStack {
                                    Text("Actual")
                                    Text(l.actual)
                                }
                                Spacer()
                                VStack {
                                    Text("Difference")
                                    Text(l.diff)
                                        .foregroundColor(l.diffVal < 0 ? .red : .green)
                                }
                                .padding(.trailing ,12)
                            }
                        }
                    }
                }
                if loading {
                    VStack {
                        Image(systemName: "arrow.up.arrow.down.circle.fill")
                            .resizable()
                            .frame(width: 150, height: 150, alignment: .center)
                            .foregroundColor(.brandPrimary)
                            .padding()
                        Text("Loading...")
                            .bold()
                            .padding()
                            .foregroundColor(.brandPrimary)
                            .background(Color.brandWhite)
                    }
                }
            }
        }
        .navigationBarItems(leading: Button(action: {
            loading = true
            monthOffset = monthOffset - 1
            getBudget()
        }) {
            Image(systemName: "arrow.turn.up.left")
        },
        trailing: Button(action: {
            loading = true
            monthOffset = monthOffset + 1
            getBudget()
        }) {
            Image(systemName: "arrow.turn.up.right")
        }

        )
        .onAppear() {
            loading = true
            monthOffset = 0
            getBudget()
        }
    }
    
    func getBudget() {
            let req = API.shared.getAppendAuth(proc: "include/m-budgetByCategory-show.php?monthoffset=" + String(monthOffset))!
            let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
                if let err = err {
                    print(err)
                    return
                }
//print(data)
                if let data = data {
                    let json = try? JSONSerialization.jsonObject(with: data, options: [])
                    let jsonDict = json as! [String: Any]
                    loading = false
                    if let vd = jsonDict["budgetArray"] as? [[String: Any]] {
                        let bl = budgetline(json: vd)
                        print("budgetline:  \(bl)")
                        monthlyBudget = bl
                    }
                }
            }
            
            task.resume()
        }
}


