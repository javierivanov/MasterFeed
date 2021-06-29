////
////  CategoriesConfigurationView.swift
////  MasterFeed
////
////  Created by Javier Fuentes on 30-03-21.
////
//
//import SwiftUI
//
//struct CategoriesConfigurationView: View {
//    
//    var categories: [String] = ["Latest", "US", "Politics", "Health", "Education", "Economy"]
//    
//    var body: some View {
//        NavigationView {
//            Form {
//                List {
//                    Section(header: Text("Important tasks")) {
//                        ForEach(categories, id:\.self) { cat in
//                            Text(cat)
//                        }.onMove(perform: { indices, newOffset in
//                            
//                        })
//                    }
//
//                    Section(header: Text("Other tasks")) {
//                        ForEach(categories, id:\.self) { cat in
//                            Text(cat)
//                        }.onMove(perform: { indices, newOffset in
//                            
//                        })
//                    }
//                }
//            }
//            .navigationBarItems(trailing: EditButton())
//            .navigationBarTitle("Category Selection", displayMode: .large)
//        }
//    }
//}
//
//struct CategoriesConfigurationView_Previews: PreviewProvider {
//    static var previews: some View {
//        CategoriesConfigurationView()
//    }
//}
