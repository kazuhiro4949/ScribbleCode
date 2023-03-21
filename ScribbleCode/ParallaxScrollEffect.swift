//
//  ParallaxScrollEffect.swift
//  ScribbleCode
//
//  Created by Kazuhiro Hayashi on 2023/03/21.
//

import SwiftUI

import SwiftUI

struct ParallaxScrollEffect: View {
    private static let imageHeight: CGFloat = 300
    
    @State private var offset: CGFloat = 0
    
    
    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                Image("zonbie_image")
                    .resizable()
                    .scaledToFill()
                    .frame(height: Self.imageHeight)
                    .frame(maxWidth: .infinity)
                    .scaleEffect(CGSize(width: imageScale, height: imageScale), anchor: .top)
                    .offset(y: imageOffset)
                
                ZStack {
                    Rectangle()
                        .fill(Color.white)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: -16)
                        .mask(Rectangle().padding(.top, -Self.imageHeight))
                    
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("The Day Zombies Fell in Love")
                                .font(.title2)
                                .bold()
                            HStack {
                                Text(" (2023) Drama, 120min")
                                    .font(.caption2)
                                Spacer()
                            }
                        }
                        
                        Text("One day, people all over the world suddenly mutate into zombies, facing the threat of human extinction. While walking with other zombies in a devastated city, the protagonist zombie, George, catches sight of a beautiful woman named Emma. George falls in love with her and tries to get closer to her, but she is a human and is surrounded by humans attacking zombies. Despite this, George does not give up on his love for her and takes action to change their situation. He teaches other zombies about love and works towards their coexistence with humans. However, the world still fears and attacks zombies. Can George convey his love to humans and save the world?")
                            .font(.callout)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .padding()
                }
                .frame(height: 1000)
            }
            .background {
                GeometryReader { proxy in
                    Color
                        .clear
                        .preference(key: OffsetPreferenceKey.self, value: proxy.frame(in: .named("ScrollView")).origin.y)
                }
            }
        }
        .coordinateSpace(name: "ScrollView")
        .onPreferenceChange(OffsetPreferenceKey.self) { value in
            offset = value
        }
        .ignoresSafeArea()

    }
    
    private var imageOffset: CGFloat {
        let offset = max(offset, -Self.imageHeight)
        if offset < 0 {
            return -offset * 0.7
        } else {
            return -offset
        }
    }
    
    private var imageScale: CGFloat {
        1 + (max(offset, 0) / Self.imageHeight)
    }
}

struct OffsetPreferenceKey: PreferenceKey {
    static var defaultValue = CGFloat.zero
    
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct ParallaxScrollEffect_Previews: PreviewProvider {
    static var previews: some View {
        ParallaxScrollEffect()
    }
}
