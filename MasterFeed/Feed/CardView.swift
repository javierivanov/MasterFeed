//
//  CardView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 20-05-21.
//

import SwiftUI

struct CardView: View {
    
    var tweet: Tweet?
    
    var body: some View {
        ZStack {
            Image("sample")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .blur(radius: 50, opaque: true)
            Color.systemBackground.opacity(0.8)
            HStack(alignment: .top) {
                Image("sample").resizable().aspectRatio(contentMode: .fill).frame(width: 120, height: 120).cornerRadius(10.0).clipped()
                TextOverlayDescriptor(tweet: tweet).padding(.top)
                Spacer()
            }
        }
        .frame(height: 120)
        .clipped()
        .cornerRadius(10.0)
        .padding()
    }
}


struct TextOverlayDescriptor: View {
    
    var tweet: Tweet?
    
    @EnvironmentObject var feedModel: FeedModel
    let formatter = RelativeDateTimeFormatter()
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(tweet?.source ?? "@CNN").foregroundColor(.blue).bold()
                Text("•")
                Text(formatter.localizedString(for: tweet?.created_at ?? Date(), relativeTo: Date()))
                Text(tweet?.domains(from: feedModel.categories).joined(separator: ", ") ?? "").fontWeight(.bold)
            }.font(.caption).lineLimit(1)
            Text(tweet?.text ?? "Sample Text")
                .font(.headline)
                .lineLimit(3)
                .padding(.bottom)
        }
        
    }
}

struct CardView_Previews: PreviewProvider {
    static var previews: some View {
        CardView().preferredColorScheme(.light).environmentObject(FeedModel())
    }
}
