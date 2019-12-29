//
//  MealDetailViewToolbar.swift
//  Meals3
//
//  Created by Uwe Petersen on 29.12.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI

struct MealDetailViewToolbar: View {
    
    @Environment(\.managedObjectContext) var viewContext
    @State private var isShowingGeneralSearchView = false
    
    
    var body: some View {
        HStack {
            Button(action: { withAnimation{print("book")} },
                   label: { Image(systemName: "book") }
            )

            Spacer()
            
            Button(action: { withAnimation{self.isShowingGeneralSearchView = true} },
                   label: { Image(systemName: "magnifyingglass") }
            )

            Spacer()
            
            Button(action: { withAnimation {print("delete the meal with questions")} },
                   label: { Image(systemName: "trash") }
            )
            
            // Zero size (thus invisible) NavigationLink with EmptyView() to move to
            NavigationLink(destination: GeneralSearchView(),
                           isActive: $isShowingGeneralSearchView,
                           label: {EmptyView()})
                .frame(width: 0, height: 0)
        }
        .padding()
    }


}

struct MealDetailViewToolbar_Previews: PreviewProvider {
    static var previews: some View {
        MealDetailViewToolbar()
    }
}
