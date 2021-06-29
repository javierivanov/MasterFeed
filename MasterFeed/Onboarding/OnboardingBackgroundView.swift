//
//  OnboardingBackground.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//

import SwiftUI

struct OnboardingBackgroundView: View {
    
    @State var start: UnitPoint = UnitPoint(x: 0, y: -4)
    @State var end: UnitPoint = UnitPoint(x: 4, y: 0)
    
    let gradient1: [Color] = [Color.purple.opacity(0.2), Color.yellow.opacity(0.2), Color.blue.opacity(0.3)]
    let gradient2: [Color] = [Color.orange.opacity(0.3), Color.blue.opacity(0.2), Color.red.opacity(0.2)]
    
    var body: some View {
        LinearGradient(gradient: Gradient(colors: gradient2), startPoint: start, endPoint: end)
            .blur(radius: 50)
            .animation(Animation.easeInOut(duration: 10).repeatForever(autoreverses: true).delay(2))
            .onAppear(perform: {
                withAnimation {
                    start = UnitPoint(x: -2, y: 0)
                    end = UnitPoint(x: 0, y: 4)
                }
            })
            .ignoresSafeArea()
    }
}

struct OnboardingBackground_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingBackgroundView()
    }
}
