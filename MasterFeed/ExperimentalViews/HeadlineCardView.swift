//
//  HeadlineCardView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 30-03-21.
//

import SwiftUI


struct LargeHeadlineCardView: View {
    var aspectRatio: CGSize
    var width: CGFloat
    var body: some View {
        VStack(alignment: .leading) {
            Image("sample")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width * (aspectRatio.height/aspectRatio.width))
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 5)
                        
            Text("CNN")
                .fontWeight(.light)
                .font(.footnote)
                .foregroundColor(.gray)
                .padding(.bottom, 5)
        
            Text("How to visit two of Hong Kong's most remote islands in one day")
                .font(.title2)
                .fontWeight(.bold)
                .lineLimit(3)
                .padding(.bottom, 5)

            BottomLineView()
        }.frame(width: width)
    }
}



struct InlineHeadlineCardView: View {
    
    var height: CGFloat
    var smaller: Bool = false
    var showTopic: Bool = true
    
    var tweet: Tweet?
    
    var body: some View {
        HStack {
            Image("sample")
                .resizable()
                .scaledToFill()
                .frame(width: height, height: height, alignment: .center)
                .clipShape(RoundedRectangle(cornerRadius: 10))
            Spacer()
            VStack (alignment: .leading) {
                if !smaller {
                    Text(tweet?.source ?? "CNN")
                        .fontWeight(.light)
                        .font(.footnote)
                        .foregroundColor(showTopic ? .gray : .blue)
                        .padding(.bottom, 5)
                }

                Text(tweet?.text ?? "How to visit two of Hong Kong's most remote islands in one day")
                    .font(smaller ? .subheadline : .headline)
                    .fontWeight(.bold)
                    .lineLimit(3)
                    .padding(.bottom, 5)
                
                BottomLineView(showTopic: showTopic)
            }
        }
        .frame(height: height)
    }
}

struct BottomLineView: View {
    
    var showButtons: Bool = true
    var showTopic: Bool = true
    
    var body: some View {
        HStack {
            
            if showTopic {
                Text("Travel")
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundColor(.blue)
                
                Text("•")
                    .font(.footnote)
                    .fontWeight(.light)
                    .foregroundColor(.gray)
            }
            
            Text("1 day ago")
                .font(.footnote)
                .fontWeight(.light)
                .foregroundColor(.gray)
            
            
            Spacer()
            if showButtons {
                Group {
                    Text(Image(systemName: "bookmark"))
                        .fontWeight(.medium)
                    Text(Image(systemName: "square.and.arrow.up.on.square"))
                        .fontWeight(.medium)
                }
            }
            
        }
    }
}

struct SmallHeadlineCardView: View {
    
    var width: CGFloat
    
    var body: some View {
        VStack(alignment: .leading) {
            Image("sample")
                .resizable()
                .scaledToFill()
                .frame(width: width, height: width)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .padding(.bottom, 5)
            Text("How to visit two of Hong Kong's most remote islands in one day")
                .font(.subheadline)
                .fontWeight(.bold)
                .lineLimit(4)
                .padding(.bottom, 5)
            BottomLineView(showButtons: false)
        }.frame(width: width)
    }
}


struct LargeHeadlineCardView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            
            SmallHeadlineCardView(width: 150)
                .previewLayout(.sizeThatFits)
            
            InlineHeadlineCardView(height: 120)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.dark)
            
            InlineHeadlineCardView(height: 120, showTopic: false)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)
            
            InlineHeadlineCardView(height: 90, smaller: true)
                .previewLayout(.sizeThatFits)
                .preferredColorScheme(.light)


            LargeHeadlineCardView(aspectRatio: CGSize(width: 1, height: 1), width: 310)
                .previewLayout(.fixed(width: 320, height: 500))
                .preferredColorScheme(.dark)
            
        }
    }
}



