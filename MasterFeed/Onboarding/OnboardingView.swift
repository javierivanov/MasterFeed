//
//  OnboardingView.swift
//  MasterFeed
//
//  Created by Javier Fuentes on 07-05-21.
//

import SwiftUI
import OAuthSwift

struct OnboardingView: View {
    
    @State var selection: Int = 0
    @ObservedObject var userAuthentication: UserAuthorization = UserAuthorization()
    @EnvironmentObject var feeedModel: FeedModel
    
    var body: some View {
        VStack {
            Text("MasterFeed")
                .fontWeight(.heavy)
                .font(.title)
            
            OnboardingTabsView(selection: $selection)
            
            ButtonsNextPreviousView(selection: $selection)
            
            
            Button(action: {
                userAuthentication.tokenGeneration(feedModel: feeedModel)
            }, label: {
                HStack {
                    Text("Login With Twitter")
                    Image("twitter").resizable().scaledToFit().frame(height: 30)
                }
                .buttonStyle(CGSize(width: 220, height: 50))
            })
        }
        .onOpenURL(perform: { url in
            OAuthSwift.handle(url: url)
        })
        .padding()
        .background(OnboardingBackgroundView())
        .sheet(isPresented: $userAuthentication.displayLogin, content: {
            TwitterLoginView(url: $userAuthentication.authUrl)
        })
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            OnboardingView().preferredColorScheme(.light).colorScheme(.light)
            OnboardingView().preferredColorScheme(.dark).colorScheme(.dark)
        }.environmentObject(UserAuthorization())
    }
}

