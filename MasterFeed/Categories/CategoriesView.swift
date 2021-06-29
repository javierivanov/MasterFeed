//
//  CategoriesView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 01-06-21.
//

import SwiftUI

struct CategoriesView: View {
    var columns: [GridItem] =
        Array(repeating: .init(.flexible(minimum: 100)), count: 2)
    @EnvironmentObject var feedModel: FeedModel
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(feedModel.currentCategories(), id:\.self) { cat in
                    NavigationLink(
                        destination: MainFeedView(category: cat),
                        label: {
                            CategoryView(text: cat/*, img: (feedModel.filterSegments(for: cat).first?.resultGroup.first?.article as? Tweet)?.imageLarge*/).padding()
                        })
                }
            }.font(.title3)
        }.navigationTitle("Categories")
        .navigationSearchBarHiddenWhenScrolling(true)
    }
}

struct CategoryView: View {
    
    var text: String?
//    var img: URL?
    
    var colors: [Color] = [.blue, .red, .orange, .yellow, .green, .purple, .gray]
    
    var startPoint: [UnitPoint] = [.top, .topLeading, .topTrailing]
    var endPoint: [UnitPoint] = [.bottom, .bottomLeading, .bottomTrailing]
    
    var body: some View {
        VStack {
//            HStack {
//                Image(systemName: img ?? "tray.fill")
//                    .font(.title2)
//                Spacer()
//            }.padding([.horizontal, .bottom])
            HStack {
                Text(text ?? "Category")
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
            }.padding([.horizontal])
        }
        .foregroundColor(.primary)
        .frame(width: UIScreen.main.bounds.width/2-30, height: 100)
        .background(
            LinearGradient(gradient: Gradient(colors: Array(colors.shuffled().prefix(2))), startPoint: startPoint.randomElement()!, endPoint: endPoint.randomElement()!).opacity(0.3))
//        .background(AsyncImage(url: img, placeholder: {Color.clear}).aspectRatio(contentMode: .fill).blur(radius: 5, opaque: true))
        .cornerRadius(10)
    }
}

struct CategoriesView_Previews: PreviewProvider {
    static var previews: some View {
        CategoriesView().environmentObject(FeedModel()).preferredColorScheme(.dark)
    }
}

