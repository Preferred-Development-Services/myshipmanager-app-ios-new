//
//  Help.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 4/10/22.
//

import SwiftUI
//
//  help.swift
//  MyShipManager
//
//  Created by Hayden Peeples on 4/10/22.
//

import SwiftUI

struct ShowHelp: View {
    var body: some View {
        VStack {
            Text("MyShipManager Help Screen")
            Text(" ")
            Group {
                HStack {
                    Text("Upcoming").font(.callout)
                    Spacer()
                }
                Text("This screen shows deliveries expected in the next 3 days").font(.caption)
                
                Text(" ")
                HStack {
                    Text("Product").font(.callout)
                    Spacer()
                }
                Text("This screen shows shipments expected to be delivered in the next 3 days").font(.caption)
            }
            Group {
                Text(" ")
                HStack {
                    Text("Defaults").font(.callout)
                    Spacer()
                }
                Text("This screen allows you to set defaults for certain fields when creating a product").font(.caption)

                Text(" ")
                HStack {
                    Text("Account").font(.callout)
                    Spacer()
                }
                HStack {
                    Text("This screen allows you to log out         ").font(.caption)
                    Spacer()
                }
            }
            
 
            
        }
        .padding()
        Spacer()
    }
}

struct showHelp_Previews: PreviewProvider {
    static var previews: some View {
        ShowHelp()
    }
}
