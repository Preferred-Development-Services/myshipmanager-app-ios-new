//
//  VariantsListView.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 4/14/22.
//

import SwiftUI



struct ShipmentListFilterView: View {
    @Binding var shipmentListFilter: Int
    @Binding var showFilter: Bool
    

    var body: some View {
        VStack {
            GeometryReader { geo in
                VStack {
                    Text("Filter Shipments").font(.largeTitle).padding()
                    Button("No Filter",action: {
                        shipmentListFilter = 0
                        showFilter = false
                    })
                    .frame(width: geo.size.width)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    Button("Pre-Ordered", action: {
                        shipmentListFilter = 1
                        showFilter = false
                    })
                    .frame(width: geo.size.width)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    Button("Ordered", action: {
                        shipmentListFilter = 2
                        showFilter = false
                    })
                    .frame(width: geo.size.width)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    Button("Shipped", action: {
                        shipmentListFilter = 3
                        showFilter = false
                    })
                    .frame(width: geo.size.width)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    Button("Received", action: {
                        shipmentListFilter = 4
                        showFilter = false
                    })
                    .frame(width: geo.size.width)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.black)
                    .font(.headline)
                    Button("Processed", action: {
                        shipmentListFilter = 5
                        showFilter = false
                    })
                    .frame(width: geo.size.width)
                    .padding()
                    .background(Color(.systemGray6))
                    .foregroundColor(Color.black)
                    .font(.headline)
                }
            }
        }
    }
}



