//
//  MyShipManagerApp.swift
//  MyShipManager
//
//  Created by Matt on 4/23/21.
//

import SwiftUI

class AppState: ObservableObject {
    @Published var barcodeFound: Bool
    @Published var currentBarcode: String
    
    init(barcodeFound: Bool, currentBarcode: String) {
        self.barcodeFound = barcodeFound
        self.currentBarcode = currentBarcode
    }
}


@main

struct MyShipManagerApp: App {
    @ObservedObject var appState = AppState(barcodeFound: false,currentBarcode: "")
    @ObservedObject var api = API.shared
    let defaults = UserDefaults.standard
    
    init() {
        UINavigationBar.appearance().tintColor = UIColor(Color.brandPrimary)
    }
    
    @State private var showModal = false
    @State var showCreateProduct = false;
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

 /*                   NavigationView {
                        if defaults.object(forKey: "useShopify") as? Bool ?? false == true {
                          CreateProduct()
                              .navigationTitle("Add Product")
                        }
                        else {
                           CreateProductNS()
                            .navigationTitle("Add Product")
                        }
                    }
                    .tabItem {
                        Image(systemName: "bag")
                        Text("Product".uppercased())
                            .accentColor(.brandPrimary)
                    }
*/

                    NavigationView {
                        CreateShipment()
                            .navigationTitle("Create Shipment")
                    }
                    .tabItem {
                        Image(systemName: "shippingbox")
                        Text("Shipment".uppercased())
                            .accentColor(.brandPrimary)
                    }
  /*
                    NavigationView {
                        TextScanView()

                        if !appState.barcodeFound {
                            BarcodeContentView()
                                .navigationTitle("Scan Barcode")
                                .environmentObject(appState)
                                .transition(.slide)
                        }
                        else {
                            BarcodeInfoView()
                                .navigationTitle("Product Information")
                                .environmentObject(appState)
                                .transition(.slide)
                        }
 
                    }

                    .tabItem {
                        Image(systemName: "barcode")
                        Text("Barcode".uppercased())
                            .accentColor(.brandPrimary)
                    }
*/
                    NavigationView {
                        if defaults.object(forKey: "useShopify") as? Bool ?? false == true {
                            SetDefaults()
                            .navigationTitle("Set Defaults")
                        }
                        else {
                                SetDefaultsNS()
                                .navigationTitle("Set Defaults")
                        }
                    }
                    .tabItem {
                        Image(systemName: "gearshape")
                        Text("Defaults".uppercased())
                            .accentColor(.brandPrimary)
                    }
                    NavigationView {
                        Budget()
                            .navigationTitle("Budget By Category")
                    }
                    .tabItem {
                        Image(systemName: "list.bullet.rectangle.portrait.fill")
                        Text("Budget".uppercased())
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
                    NavigationView {
                        ShowHelp()
                            .navigationTitle("Help")
                    }
                    .tabItem {
                        Image(systemName: "questionmark.circle.fill")
                        Text("Help".uppercased())
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
