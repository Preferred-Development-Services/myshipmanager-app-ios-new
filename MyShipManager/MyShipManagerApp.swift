//
//  MyShipManagerApp.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import SwiftUI

@main
struct MyShipManagerApp: App {
    @ObservedObject var api = API.shared
    
    init() {
        UINavigationBar.appearance().tintColor = UIColor(Color.brandPrimary)
    }
    @State private var showModal = false
    var body: some Scene {
        WindowGroup {
            if api.isAuthed {
                TabView {
                    NavigationView {
                        ShipmentList()
                            .navigationTitle("Upcoming Deliveries")
                    }
                    .tabItem {
                        Image(systemName: "calendar")
                        Text("Upcoming".uppercased())
                            .accentColor(.brandPrimary)
                    }

                    NavigationView {
                        NewProduct()
                            .navigationTitle("Add Product")
                    }
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Product".uppercased())
                            .accentColor(.brandPrimary)
                    }
                    NavigationView {
                        CreateShipment()
                            .navigationTitle("Create Shipment")
                    }
                    .tabItem {
                        Image(systemName: "shippingbox")
                        Text("Create".uppercased())
                            .accentColor(.brandPrimary)
                    }
                    NavigationView {
                        ContentView()
                            .navigationTitle("Scan Barcode")
                    }
                    .tabItem {
                        Image(systemName: "barcode")
                        Text("Barcode".uppercased())
                            .accentColor(.brandPrimary)
                    }
                    NavigationView {
                        SetDefaults(isPresented: $showModal)
                            .navigationTitle("Set Defaults")
                            .navigationBarItems( trailing: Button("Set") {})
                    }
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Defaults".uppercased())
                            .accentColor(.brandPrimary)
                    }
                    NavigationView {
                        Account()
                            .navigationTitle("Account")
                    }
                    .tabItem {
                        Image(systemName: "person")
                        Text("Account".uppercased())
                            .accentColor(.brandPrimary)
                    }
/*
                    NavigationView{
                        Account()
                            .navigationTitle("My Account")
                    }
                    .tabItem {
                        Image(systemName: "person.crop.circle")
                            .colorMultiply(.brandPrimary)
                        Text("Account".uppercased())
                    }
 */
                }
                    .accentColor(.brandPrimary)
                /* TODO: throw a sheet here for the session re-log in */
            } else {
                Welcome()
            }
        }
    }
}
