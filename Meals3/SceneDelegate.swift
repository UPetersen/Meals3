//
//  SceneDelegate.swift
//  Meals3
//
//  Created by Uwe Petersen on 31.10.19.
//  Copyright © 2019 Uwe Petersen. All rights reserved.
//

import UIKit
import SwiftUI
import CoreData


class CurrentIngredientCollection: ObservableObject {
    @Published var collection: IngredientCollection
    init(_ value: IngredientCollection) {
        self.collection = value
    }
//    init(context: NSManagedObjectContext) {
//        self.currentIngredientCollection = Meal.newestMeal(managedObjectContext: context)
//    }
}

class CurrentMeal: ObservableObject {
    @Published var meal: Meal
    init(_ meal: Meal) {
        self.meal = meal
    }
}
//class CurrentIngredientCollectionType: ObservableObject {
//@Published var collection: IngredientCollectionType
//init(_ value: IngredientCollectionType) {
//    self.collection = value
//}

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).

        // Get the managed object context from the shared persistent container
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

        // Other shared classes
//        let search = Search() // everything for the search bars
        let currentMeal = Meal.newestMeal(managedObjectContext: context)
        // The ingredient collection (aka meal or recipe) to which foods will be added to as ingredients.
        // Has to be changed, if a new meal is created or the current meal is deleted.
//        var currentIngredientCollection: some IngredientCollection = Meal.newestMeal(managedObjectContext: context)

        let currentIngredientCollection = CurrentIngredientCollection(currentMeal)
//        let currentIngredientCollectionType = CurrentIngredientCollectionType(.meal(currentMeal))
        let theCurrentMeal = CurrentMeal(currentMeal)

        // Create the SwiftUI view and set the context as the value for the managedObjectContext environment keyPath
        let contentView = ContentView()
            .environment(\.managedObjectContext, context)
            .environmentObject(currentIngredientCollection)
            .environmentObject(currentMeal)
//            .environmentObject(currentIngredientCollectionType)
            .environmentObject(theCurrentMeal)
//            .environmentObject(search)

        // Use a UIHostingController as window root view controller.
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            
            window.rootViewController = UIHostingController(rootView: contentView)
//            window.rootViewController = UIHostingController(rootView: appView)
            
            // Speed up all animations (view transitions)
            window.layer.speed = 2.0

            self.window = window
            window.makeKeyAndVisible()
        }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}

