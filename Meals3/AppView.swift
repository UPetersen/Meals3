//
//  AppView.swift
//  Meals3
//
//  Created by Uwe Petersen on 06.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI


struct AppView: View {
    @Environment(\.managedObjectContext) var viewContext
    @State var searchText = "bier"

    var body: some View {
        TabView {
            ContentView()
                .tabItem {
                    Image(systemName: "list.dash")
                    Text("Menu")
                }

            ContentView()
                .tabItem {
                    Image(systemName: "square.and.pencil")
                    Text("Order")
                }
        }
    }
}

struct AppView_Previews: PreviewProvider {
//    static var previews: some View {
//        AppView()
//    }
    static var previews: some View {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        return AppView().environment(\.managedObjectContext, context)
    }

}
