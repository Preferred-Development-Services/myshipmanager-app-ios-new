//
//  ContentView.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import SwiftUI

struct ShipmentList: View {
    @State var showModal = false
    @State var checked = false
    @State var loading = true
    @State var shipmentListFilter = 0
    @State var showFilter = false
    
    @State var listings = [ShipmentListing]()
    
    var body: some View {
        ScrollView {
            ZStack {
            LazyVStack {
            ForEach(listings) { l in
                VStack {
                    ZStack {
                        Color(l.backgroundColor)
                            .frame(height: 20)
                        Text(l.status)
                    }
                    Text(dateToHuman(l.start))
                        .font(.subheadline)
                        .bold()
                        .foregroundColor(.gray)
                        .padding(.bottom, 3)
                    Text(l.title)
                        .padding(.bottom, 6)
                }
                .background(Color(.systemGray6))
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
            getOrders()
        }) {
            Image(systemName: "arrow.clockwise")
        },
        trailing: Button(action: {
            showFilter = true
        }) {
            Image(systemName: "line.3.horizontal.decrease.circle")
        }
                            
        )
        .sheet(isPresented: $showFilter, onDismiss: {getOrders()} , content: {
            ShipmentListFilterView(shipmentListFilter: $shipmentListFilter,showFilter: $showFilter)
        })
        .fullScreenCover(isPresented: $showModal, content: {
            CreateQueued(isPresented: $showModal)
        })
        .onAppear() {
            loading = true
 //           checkSession()
            getOrders()
        }
    }

    func getOrders() {
        //let start = dateToPHPString(Date(timeInterval: -86400 * 1, since: Date()))
        //let end = dateToPHPString(Date(timeInterval: 86400 * 4, since: Date()))
        let url = "include/m-calendarView-get.php?filter=\(shipmentListFilter)"//?start=\(start)&end=\(end)"

        print("url: \(url)")
        
        let req = API.shared.getAppendAuth(proc: url)!
        
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            
            if let data = data, let dataString = String(data: data, encoding: .utf8) {
                print("dataString: \(dataString)")
                let listingsPHP = (try? JSONDecoder().decode([ShipmentListingPHP].self, from: data)) ?? []
                print(listingsPHP)
                DispatchQueue.main.async {
                    listings = convertShipmentListings(listingsPHP)
                    loading = false
 //                   print(listings)
                }
            }
        }
        
        task.resume()
    }
    
    func checkSession() {
        guard !checked else { return }
        checked = true
        
        let req = API.shared.sessionRefreshRequest()!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                print(err)
                return
            }
            
            guard data != nil else { return }
            
            let json = try? JSONSerialization.jsonObject(with: data!, options: [])
            let jsonDict = json as! [String: Any]
            let success = jsonDict["sessionValid"] as? Bool
            if (success == nil) || (success! != true) {
                print("session dead!")
                refreshSession()
            } else {
                print("session good!")
            }
        }
        
        task.resume()
    }
    
    func refreshSession() {
        let req = API.shared.loginRequest()!
        let task = URLSession.shared.dataTask(with: req) { (data, resp, err) in
            if let err = err {
                // TODO: ui show error
                print(err)
                return
            }

            if let data = data {
                let json = try? JSONSerialization.jsonObject(with: data, options: [])
                let jsonDict = json as! [String: Any]
                if let success = jsonDict["loginsuccess"] as? String {
                    if success == "1" {
                        if let r = resp as? HTTPURLResponse {
                            let sessionCookie = (r.value(forHTTPHeaderField: "Set-Cookie") ?? "").components(separatedBy: ";").first ?? ""
                            if sessionCookie != "" {
                                DispatchQueue.main.async {
                                    API.shared.saveSession(cookie: sessionCookie)
                                }
                                return
                            }
                        }
                    }
                }
                print("bad credentials")
                
                DispatchQueue.main.async {
                    API.shared.clearSession()
                }
            }
        }
        
        task.resume()
    }
    
}

struct ShipmentList_Previews: PreviewProvider {
    static var previews: some View {
        ShipmentList()
    }
}
