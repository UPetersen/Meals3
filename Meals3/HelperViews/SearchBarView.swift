//
//  SearchBarView.swift
//  Meals3
//
//  Created by Uwe Petersen on 09.11.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import SwiftUI


struct SearchBarView: View {
    
    @Binding var searchText: String
    @State private var showCancelButton: Bool = false
//    var onCommit: () ->Void = {print("onCommit")}
    var onCommit: () ->Void = {}

    var body: some View {
        HStack {
            HStack {
                Image(systemName: "magnifyingglass")
                
                // Search text field
                ZStack (alignment: .leading) {
                    if searchText.isEmpty { // Separate text for placeholder to give it the proper color
                        Text("Search")
                    }
                    TextField("", text: $searchText, onEditingChanged: { isEditing in
                        showCancelButton = true
//                        print("Isediting: \(isEditing)")
                    }, onCommit: onCommit).foregroundColor(.primary)
                }
                // Clear button
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill").opacity(searchText == "" ? 0 : 1)
                }
            }
            .padding(EdgeInsets(top: 8, leading: 6, bottom: 8, trailing: 6))
            .foregroundColor(.secondary) // For magnifying glass and placeholder test
            .background(Color(.tertiarySystemFill))
            .cornerRadius(10.0)
            
            if showCancelButton  {
                // Cancel button
                Button("Cancel") {
                    UIApplication.shared.endEditing(true) // this must be placed before the other commands here
                    searchText = ""
                    showCancelButton = false
                }
                .foregroundColor(Color(.systemBlue))
            }
        }
        .padding(.horizontal)
//        .navigationBarHidden(showCancelButton)
    }
}


struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {
        SearchBarView(searchText: .constant(""))
    }
}


// MARK: - UIApplication extension for resgning keyboard on pressing the cancel buttion of the search bar
extension UIApplication {
    /// Resigns the keyboard.
    ///
    /// Used for resigning the keyboard when pressing the cancel button in a searchbar based on [this](https://stackoverflow.com/a/58473985/3687284) solution.
    /// - Parameter force: set true to resign the keyboard.
    func endEditing(_ force: Bool) {
        let scenes = UIApplication.shared.connectedScenes
        let windowScene = scenes.first as? UIWindowScene
        let window = windowScene?.windows.first
        window?.endEditing(force)
    }
}
