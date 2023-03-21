//
//  InteractiveIndicator.swift
//  ScribbleCode
//
//  Copyright (c) 2023 Kazuhiro Hayashi
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.

import SwiftUI

private var menus: [String] = [
    "cat",
    "car",
    "human",
    "robot",
    "coffee"
]

class SelectionState: ObservableObject {
    @Published var tab: Int = 0
    @Published var maskOffset: CGFloat = 0
}

struct ScrollingState: Equatable {
    let offset: CGFloat
    let index: Int
}

struct OffsetPreferencekey: PreferenceKey {
    static var defaultValue = ScrollingState(offset: 0, index: 0)
    
    static func reduce(value: inout ScrollingState, nextValue: () -> ScrollingState) {
        let offset = value.offset + nextValue().offset
        let index = value.index + nextValue().index
        value = ScrollingState(offset: offset, index: index)
    }
}

struct InteractiveIndicator: View {
    static let menuSize = CGSize(width: 100, height: 44)
    
    @StateObject private var selectionState = SelectionState()
    
    fileprivate func inactiveMenuItem(_ index: Int) -> some View {
        Button {
            selectionState.tab = index
            withAnimation(.spring(response: 0.3, dampingFraction: 0.75)) {
                selectionState.maskOffset = Double(index) * Self.menuSize.width
            }
        } label: {
            ZStack {
                Color.white
                Text("\(menus[index])")
                    .bold()
                    .foregroundColor(.black)
            }
            .frame(width: Self.menuSize.width)
        }
        .buttonStyle(.plain)
        .id("inactiveMenuItem_\(index)")
    }
    
    fileprivate func activeMenuItem(_ index: Int) -> some View {
        ZStack {
            Color.gray
            Text("\(menus[index])")
                .bold()
                .foregroundColor(.white)
        }
        .frame(width: Self.menuSize.width)
    }
    
    fileprivate func maskMenuItem() -> some View {
        return HStack() {
            RoundedRectangle(cornerRadius: 16)
                .frame(width: Self.menuSize.width - 8, height: Self.menuSize.height - 16, alignment: .center)
                .padding(.horizontal, 4)
        }
        .frame(width: Self.menuSize.width, height: Self.menuSize.height, alignment: .leading)
        .offset(x: selectionState.maskOffset)
    }
    
    fileprivate func menu() -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            ZStack {
                HStack(spacing: 0) {
                    ForEach(0..<menus.count, id: \.self) { index in
                        inactiveMenuItem(index)
                    }
                }
                
                HStack(spacing: 0) {
                    ForEach(0..<menus.count, id: \.self) { index in
                        activeMenuItem(index)
                    }
                }
                .mask(alignment: .leading) {
                    maskMenuItem()
                }
                .allowsHitTesting(false)
            }
        }
    }
    
    fileprivate func content(geometryProxy: GeometryProxy, scrollViewProxy: ScrollViewProxy) -> some View {
        TabView(selection: $selectionState.tab) {
            ForEach(0..<menus.count, id: \.self) { index in
                Image(menus[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: geometryProxy.size.width)
                    .clipped()
                    .ignoresSafeArea()
                    .tag(index)
                    .background {
                        GeometryReader { bgGeometryProxy in
                            let frame = bgGeometryProxy.frame(in: .named("TabView"))
                            if index == selectionState.tab {
                                Color.clear
                                    .preference(
                                        key: OffsetPreferencekey.self,
                                        value: ScrollingState(
                                            offset: frame.origin.x,
                                            index: index))
                            } else {
                                Color.clear
                            }
                        }
                    }
            }
        }
        .coordinateSpace(name: "TabView")
        .tabViewStyle(.page(indexDisplayMode: .never))
        .onPreferenceChange(OffsetPreferencekey.self) { value in
            let width = geometryProxy.size.width
            let percent = (width - value.offset) / width
            let base = CGFloat(value.index - 1)
            selectionState.maskOffset = (base + percent) * Self.menuSize.width
        }
        .onReceive(selectionState.$tab.scan((0, 0), { ($0.1, $1) })) { output in
             withAnimation {
                scrollViewProxy.scrollTo("inactiveMenuItem_\(output.1)", anchor: .center)
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometryProxy in
            ScrollViewReader { scrollViewProxy in
                VStack(spacing: 0) {
                    menu()
                        .frame(height: Self.menuSize.height)
                    content(geometryProxy: geometryProxy, scrollViewProxy: scrollViewProxy)
                }
            }
        }
        .ignoresSafeArea(edges: [.leading, .trailing, .bottom])
    }
}

struct InteractiveIndicator_Previews: PreviewProvider {
    static var previews: some View {
        InteractiveIndicator()
    }
}
