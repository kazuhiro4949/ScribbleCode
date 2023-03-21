//
//  Clock.swift
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
import Combine

// MARK: - Data
class CurrentTime: ObservableObject {
    @Published var seconds = Double.zero
    
    private let timer = Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()
    private var cancellableSet = Set<AnyCancellable>()
    
    init() {
        timer.map { date in
            let components = Calendar.current.dateComponents([.year, .month, .day], from: date)
            let referenceDate = Calendar.current.date(
                from: DateComponents(
                    year: components.year,
                    month: components.month,
                    day: components.day
                )
            )!
            return Date().timeIntervalSince(referenceDate)
        }
        .assign(to: \.seconds, on: self)
        .store(in: &cancellableSet)
    }
}

// MARK: - View
struct Clock: View {
    @ObservedObject var currentTime = CurrentTime()
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 8)
            ForEach(0..<60) { tick in
                VStack {
                    Rectangle()
                        .fill(.primary)
                        .opacity(1)
                        .frame(width: 2, height: tick % 5 == 0 ? 15 : 7)
                    Spacer()
                }
                .rotationEffect(.degrees(Double(tick)/60 * 360))
            }
            
            ForEach(1..<13) { tick in
                VStack {
                    Text("\(tick)")
                        .font(.title)
                        .rotationEffect(.degrees(-Double(tick)/12 * 360))
                    Spacer()
                }
                .rotationEffect(.degrees(Double(tick)/12 * 360))
            }
            .padding(20)
            
            // sencod
            Hand(angleMultipler: currentTime.seconds.remainder(dividingBy: 60) / 60, scale: 0.7)
                .stroke(.red, lineWidth: 1)
            // minute
            Hand(angleMultipler:  currentTime.seconds/60 / 60, scale: 0.6)
                .stroke(lineWidth: 2)
            // hour
            Hand(angleMultipler: currentTime.seconds / (60 * 12) / 60, scale: 0.5)
                .stroke(lineWidth: 4)
            
            ZStack {
                Circle()
                    .fill(.primary)
                    .frame(width: 8, height: 8)
                Circle()
                    .fill(.background)
                    .frame(width: 4, height: 4)
            }
            
        }
        .frame(width: 300, height: 300)
    }
}

struct Hand: Shape {
    let angleMultipler: CGFloat
    let scale: CGFloat
    
    func path(in rect: CGRect) -> Path {
        Path { path in
            let length = rect.width / 2
            let center = CGPoint(x: rect.midX, y: rect.midY)
            
            path.move(to: center)
            
            let angle = CGFloat.pi/2 - CGFloat.pi * 2 * angleMultipler
            
            path.addLine(to: CGPoint(
                x: rect.midX + cos(angle) * length * scale,
                y: rect.midY - sin(angle) * length * scale
            ))
        }
    }
}

struct Clock_Previews: PreviewProvider {
    static var previews: some View {
        Clock()
    }
}
