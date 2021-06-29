//
//  Data.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//

import SwiftUI


struct OnboardingPageDetails<Content: View>: Identifiable {
    
    
    internal init(@ViewBuilder view: @escaping () -> Content) {
        self.view = view()
    }
    
    var id: UUID = UUID()
    var view: Content
}

let OnboardingPagesViewList: [OnboardingPageDetails<AnyView>] = [
    OnboardingPageDetails<AnyView>(view: {AnyView(PageImagePresentation())}),
]

struct PageImagePresentation: View {
    
    var body: some View {
        VStack(spacing: 50) {
            AnimatedLogosView().padding()
            Text("MasterFeed is a simple yet powerfull news aggregator from all your favorite sources").font(.title2).padding()
        }.background(Rectangle().foregroundColor(.white.opacity(0.3)).cornerRadius(10))
    }
}


struct PageImagePresentation_Previews: PreviewProvider {
    static var previews: some View {
        PageImagePresentation().preferredColorScheme(.dark).colorScheme(.dark)
    }
}


struct AnimatedLogosView : View {
    @State var start: Bool = false
    var body: some View {
        VStack {
            if start {
                Image("new-york-times").resizable().scaledToFit()
                    .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1.5)))).padding([.top, .horizontal])
            }
            HStack {
                VStack {
                    if start {
                        Image("sky-news-2").resizable().scaledToFit()//.frame(maxWidth: 130)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1)))).padding()
                        
                        Image("msnbc-2015-logo").resizable().scaledToFit()//.frame(maxWidth: 90)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1))))
                        Image("bbc-world-news").resizable().scaledToFit()//.frame(maxWidth: 90)
                            .padding()
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1))))
                    }
                }
                VStack {
                    if start {
                        Image("cnbc-1").resizable().scaledToFit()//.frame(maxWidth: 120)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1.5)))).padding()
                        Image("huffpost").resizable().scaledToFit()//.frame(maxWidth: 180)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1.5)))).padding()
                        Image("politico").resizable().scaledToFit()//.frame(maxWidth: 90)
                            .transition(AnyTransition.scale.animation(.easeInOut(duration: 0.5).delay(Double.random(in: 0.5...1.5))))
                    }
                }
            }
        }
        .onAppear(perform: {
            withAnimation {
                start = true
            }
        })
    }
}

