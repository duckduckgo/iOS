//
//  OnboardingBackground.swift
//  DuckDuckGo
//
//  Copyright © 2024 DuckDuckGo. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//

import SwiftUI
import Onboarding

struct OnboardingBackground: View {
    @Environment(\.verticalSizeClass) private var vSizeClass
    @Environment(\.horizontalSizeClass) private var hSizeClass
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        GeometryReader { proxy in
            // On iPhone we want the background image to start from the left but on iPad we want to take the center part
            let alignment = Metrics.imageCentering.build(v: vSizeClass, h: hSizeClass)
            Image(.onboardingBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                //.opacity(colorScheme == .light ? 0.5 : 0.3)
                .frame(width: proxy.size.width, height: proxy.size.height, alignment: alignment)
                .background(
                    DarkGradient01()
                        .ignoresSafeArea()
                )
        }
    }
}

private enum Metrics {
    static let imageCentering = MetricBuilder<Alignment>(iPhone: .bottomLeading, iPad: .center)
}


private struct HighlightsLightGradient: View {
    var body: some View {
        ZStack {
            EllipticalGradient(
                colors: [
                    Color(red: 0.8, green: 0.85, blue: 1).opacity(0.58),
                    Color(red: 0.8, green: 0.85, blue: 1).opacity(0)
                ],
                center: UnitPoint(x: 1.02, y: 0.5),
                endRadiusFraction: 1
            )
            EllipticalGradient(
                colors: [
                    Color(red: 0.93, green: 0.9, blue: 1).opacity(0.8),
                    Color(red: 0.93, green: 0.9, blue: 1).opacity(0),
                ],
                center: UnitPoint(x: 0.89, y: 1.07),
                endRadiusFraction: 1
            )
            EllipticalGradient(
                colors: [
                    Color(red: 0.93, green: 0.9, blue: 1).opacity(0.8),
                    Color(red: 0.93, green: 0.9, blue: 1).opacity(0),
                ],
                center: UnitPoint(x: 0.92, y: 0),
                endRadiusFraction: 1
            )
            EllipticalGradient(
                colors: [
                    Color(red: 1, green: 0.91, blue: 0.64).opacity(0.12),
                    Color(red: 1, green: 0.91, blue: 0.64).opacity(0),
                ],
                center: UnitPoint(x: 0.16, y: 0.86),
                endRadiusFraction: 1
            )
            EllipticalGradient(
                colors: [
                    Color(red: 0.97, green: 0.73, blue: 0.67).opacity(0.5),
                    Color(red: 0.97, green: 0.73, blue: 0.67).opacity(0),
                ],
                center: UnitPoint(x: 0.2, y: 0.17),
                endRadiusFraction: 1
            )
        }
        .background(.white)
    }
}

private struct DarkGradient01: View {
    var body: some View {
        ZStack {
            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0.32), location: 0.15),
                    Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0), location: 1.00),
                ],
                center: UnitPoint(x: 1.0, y: 0.5)
            )

            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                ],
                center: UnitPoint(x: 0.89, y: 1.07)
            )

            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                ],
                center: UnitPoint(x: 0.92, y: 0)
            )

            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 1, green: 1, blue: 0.54).opacity(0), location: 0.00),
                    Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.64).opacity(0), location: 1.00),
                ],
                center: UnitPoint(x: 0.16, y: 0.86)
            )

            EllipticalGradient(
                stops: [
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.5), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                ],
                center: UnitPoint(x: 0.2, y: 0.17)
            )
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
}

private struct DarkGradient02: View {
    var body: some View {
        ZStack {
            // Gradient Layer 1
            EllipticalGradient(
                colors: [
                    Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0.32),
                    Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0),
                ],
                center: UnitPoint(x: 1.02, y: 0.5),
                endRadiusFraction: 1
            )

            // Gradient Layer 2
            EllipticalGradient(
                colors: [
                    Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8),
                    Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0),
                ],
                center: UnitPoint(x: 0.89, y: 1.07),
                endRadiusFraction: 1
            )

            // Gradient Layer 3
            EllipticalGradient(
                colors: [
                    Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8),
                    Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0),
                ],
                center: UnitPoint(x: 0.92, y: 0),
                endRadiusFraction: 1
            )

            // Gradient Layer 4
            EllipticalGradient(
                colors: [
                    Color(red: 1, green: 1, blue: 0.54).opacity(0),
                    Color(red: 1, green: 0.91, blue: 0.64).opacity(0),
                ],
                center: UnitPoint(x: 0.16, y: 0.86),
                endRadiusFraction: 1
            )

            // Gradient Layer 5
            EllipticalGradient(
                colors: [
                    Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.5),
                    Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0),
                ],
                center: UnitPoint(x: 0.2, y: 0.17),
                endRadiusFraction: 1
            )
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
}

private struct DarkGradient03: View {
    var body: some View {
        ZStack { }
            .frame(width: 390, height: 844)
            .position(x:195, y:422)
            .background(
                EllipticalGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0.32), location: 0.15),
                        Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0), location: 1.00),
                    ],
                    center: UnitPoint(x: 1.02, y: 0.5)
                )
            )
            .background(
                EllipticalGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                    ],
                    center: UnitPoint(x: 0.89, y: 1.07)
                )
            )
            .background(
                EllipticalGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                    ],
                    center: UnitPoint(x: 0.92, y: 0)
                )
            )
            .background(
                EllipticalGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 1, green: 1, blue: 0.54).opacity(0), location: 0.00),
                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.64).opacity(0), location: 1.00),
                    ],
                    center: UnitPoint(x: 0.16, y: 0.86)
                )
            )
            .background(
                EllipticalGradient(
                    stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.5), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                    ],
                    center: UnitPoint(x: 0.2, y: 0.17)
                )
            )
            .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
}

struct DarkGradient04: View {

    var body: some View {
        ZStack {
            // Radial Gradient 1
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 228/255, green: 111/255, blue: 79/255).opacity(0.32), Color(red: 228/255, green: 111/255, blue: 79/255).opacity(0.00)]),
                center: UnitPoint(x: 102.11 / 100, y: 50 / 100),
                startRadius: 0,
                endRadius: 200
            )
            //.blendMode(.overlay)

            // Radial Gradient 2
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 44/255, green: 20/255, blue: 111/255).opacity(0.80), Color(red: 44/255, green: 20/255, blue: 111/255).opacity(0.00)]),
                center: UnitPoint(x: 88.72 / 100, y: 107.35 / 100),
                startRadius: 0,
                endRadius: 150
            )
            //.blendMode(.overlay)

            // Radial Gradient 3
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 44/255, green: 20/255, blue: 111/255).opacity(0.80), Color(red: 44/255, green: 20/255, blue: 111/255).opacity(0.00)]),
                center: UnitPoint(x: 91.67 / 100, y: 0),
                startRadius: 0,
                endRadius: 150
            )
            //.blendMode(.overlay)

            // Radial Gradient 4
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 255/255, green: 254/255, blue: 138/255).opacity(0.00), Color(red: 255/255, green: 232/255, blue: 163/255).opacity(0.00)]),
                center: UnitPoint(x: 15.78 / 100, y: 85.59 / 100),
                startRadius: 0,
                endRadius: 150
            )
            //.blendMode(.overlay)

            // Radial Gradient 5
            RadialGradient(
                gradient: Gradient(colors: [Color(red: 44/255, green: 20/255, blue: 111/255).opacity(0.50), Color(red: 44/255, green: 20/255, blue: 111/255).opacity(0.00)]),
                center: UnitPoint(x: 20.47 / 100, y: 17.2 / 100),
                startRadius: 0,
                endRadius: 150
            )
            //.blendMode(.overlay)
        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
}

struct DarkGradient05: View {

    var body: some View {

            Image(.onboardingBackground)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .opacity(0.3)
                //.frame(width: proxy.size.width, height: proxy.size.height, alignment: .leading)
        
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0.32), location: 0.15),
              Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 1.02, y: 0.5)
          )
        )
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
              Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 0.89, y: 1.07)
          )
        )
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
              Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 0.92, y: 0)
          )
        )
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 1, green: 1, blue: 0.54).opacity(0), location: 0.00),
              Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.64).opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 0.16, y: 0.86)
          )
        )
        .background(
          EllipticalGradient(
            stops: [
              Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.5), location: 0.00),
              Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
            ],
            center: UnitPoint(x: 0.2, y: 0.17)
          )
        )
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
}

struct DarkGradient06: View {

    var body: some View {
            // Define a single gradient with multiple stops and centers if needed
            LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0.32), location: 0.15),
                    Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0), location: 1.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00),
                    Gradient.Stop(color: Color(red: 1, green: 1, blue: 0.54).opacity(0), location: 0.00),
                    Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.64).opacity(0), location: 1.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.5), location: 0.00),
                    Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00)
                ]),
                startPoint: UnitPoint(x: 0, y: 0),
                endPoint: UnitPoint(x: 1, y: 1)
            )
    }
}

struct DarkGradient07: View {

    var body: some View {
        ZStack {
            // LinearGradient approximation of the first EllipticalGradient
            LinearGradient(
                gradient: Gradient(stops: [
                    Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0.32), location: 0.15),
                    Gradient.Stop(color: Color(red: 0.89, green: 0.44, blue: 0.31).opacity(0), location: 1.00)
                ]),
                startPoint: UnitPoint(x: 1.0, y: 0.5),  // Mimicking the center x:1.02
                endPoint: UnitPoint(x: 0.0, y: 0.5)     // Approximating the elliptical spread
            )

                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00)
                    ]),
                    startPoint: UnitPoint(x: 0.89, y: 1.07),  // Mimicking the center
                    endPoint: UnitPoint(x: 0.92, y: 0.0)     // Approximating the elliptical spread
                )

                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.8), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00)
                    ]),
                    startPoint: UnitPoint(x: 0.92, y: 0.0),  // Mimicking the center
                    endPoint: UnitPoint(x: 0.0, y: 1.0)     // Approximating the elliptical spread
                )

                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: Color(red: 1, green: 1, blue: 0.54).opacity(0), location: 0.00),
                        Gradient.Stop(color: Color(red: 1, green: 0.91, blue: 0.64).opacity(0), location: 1.00)
                    ]),
                    startPoint: UnitPoint(x: 0.16, y: 0.86),  // Mimicking the center
                    endPoint: UnitPoint(x: 1.0, y: 1.0)     // Approximating the elliptical spread
                )

                LinearGradient(
                    gradient: Gradient(stops: [
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0.5), location: 0.00),
                        Gradient.Stop(color: Color(red: 0.17, green: 0.08, blue: 0.44).opacity(0), location: 1.00)
                    ]),
                    startPoint: UnitPoint(x: 0.2, y: 0.17),  // Mimicking the center
                    endPoint: UnitPoint(x: 0.8, y: 0.8)     // Approximating the elliptical spread
                )

        }
        .background(Color(red: 0.07, green: 0.07, blue: 0.07))
    }
}

#Preview("Light Mode") {
    OnboardingBackground()
        .preferredColorScheme(.light)
}

#Preview("Dark Mode") {
    OnboardingBackground()
        .preferredColorScheme(.dark)
}

#Preview("Gradient 01") {
    DarkGradient01()
}

#Preview("Gradient 02") {
    DarkGradient02()
}

#Preview("Gradient 03") {
    DarkGradient03()
}

#Preview("Gradient 04") {
    DarkGradient04()
}

#Preview("Gradient 05") {
    DarkGradient05()
}

#Preview("Gradient 07") {
    DarkGradient07()
}
