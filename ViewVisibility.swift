//
//  ViewVisibility.swift
//
//  Created by Илья Аникин on 06.03.2025.
//

import SwiftUI


extension View {
    /// Detects whether this view is **entirely visible** within the given *rect*.
    ///
    /// A visibility check is performed whenever the view's geometry changes, including during ``View/onAppear(_:)``.
    /// The check applies a scaling transformation to the view's *visibility* rect using the **scale** parameter,
    /// which represents the horizontal and vertical scaling factors.
    ///
    /// The *perform* closure is triggered with the updated visibility status whenever the view's
    /// rect position changes - either extending beyond or fitting within the bounds of **rect**.
    ///
    /// Negative values for **scale** are not supported and will be clamped to *0*. Scale with **0** value
    /// means that view's *visibility* rect is represented by a point at the view's center.
    ///
    /// - Note: Avoid using this function in environments with frequent updates for a large number of views,
    ///   as it may lead to performance issues.
    /// - Important: The *rect* must be provided in global coordinates and should be larger than the view's frame.
    ///   If the view's frame exceeds the *rect* in even a single dimension,
    ///   it will never be considered **entirely visible**, and **perform** will not be triggered.
    ///
    func onVisibilityChange(
        in rect: CGRect,
        scale: CGSize,
        perform: @escaping (Bool) -> Void
    ) -> some View {
        self.modifier(VisibilityDetector(rect: rect, scale: scale, onChanged: perform))
    }

    /// Detects whether this view is **entirely visible** within the given *rect*.
    ///
    /// A visibility check is performed whenever the view's geometry changes, including during ``View/onAppear(_:)``.
    /// The check applies a scaling transformation to the view's *visibility* rect using the **scale** parameter,
    /// which represents the horizontal and vertical scaling factors.
    ///
    /// The *perform* closure is triggered with the updated visibility status whenever the view's
    /// rect position changes - either extending beyond or fitting within the bounds of **rect**.
    ///
    /// Negative values for **scale** are not supported and will be clamped to *0*. Scale with **0** value
    /// means that view's *visibility* rect is represented by a point at the view's center.
    ///
    /// - Note: Avoid using this function in environments with frequent updates for a large number of views,
    ///   as it may lead to performance issues.
    /// - Important: The *rect* must be provided in global coordinates and should be larger than the view's frame.
    ///   If the view's frame exceeds the *rect* in even a single dimension,
    ///   it will never be considered **entirely visible**, and **perform** will not be triggered.
    ///
    func onVisibilityChange(
        in rect: CGRect,
        scale: CGFloat = 1,
        perform: @escaping (Bool) -> Void
    ) -> some View {
        self.modifier(
            VisibilityDetector(
                rect: rect,
                scale: CGSize(width: scale, height: scale),
                onChanged: perform
            )
        )
    }
}

struct VisibilityDetector: ViewModifier {
    let rect: CGRect
    let scale: CGSize
    let onChanged: (Bool) -> Void

    func body(content: Content) -> some View {
        content
            .onGeometryChange(for: Bool.self) { proxy in
                let sourceFrame = proxy.frame(in: .global)

                let frame = sourceFrame
                    .insetBy(
                        dx: -(sourceFrame.width * max(scale.width, 0) - sourceFrame.width) / 2.0,
                        dy: -(sourceFrame.height * max(scale.height, 0) - sourceFrame.height) / 2.0
                    )

                return frame.minY >= rect.minY
                    && frame.maxY <= rect.maxY
                    && frame.minX >= rect.minX
                    && frame.maxX <= rect.maxX

            } action: { isVisible in
                onChanged(isVisible)
            }
    }
}

// MARK: Example
fileprivate struct ExampleView: View {
    @State var scale: Double = 1.0

    var body: some View {
        ScrollView([.horizontal, .vertical]) {
            RoundedRectangle(cornerRadius: 20)
                .fill(.indigo)
                .frame(width: 200, height: 400)
                .overlay {
                    ZStack {
                        Rectangle().fill(.orange.opacity(0.2))

                        Rectangle()
                            .strokeBorder(.orange, lineWidth: 3)

                        Text("Visibility rect")
                            .foregroundStyle(.orange)
                            .monospaced()
                            .multilineTextAlignment(.center)
                    }
                    .scaleEffect(scale)
                }
                .onVisibilityChange(
                    in: UIScreen.main.bounds,
                    scale: scale
                ) { visible in
                    print(visible ? "✅ visible" : "❌ hidden")
                }
        }
        .overlay(alignment: .center) {
            scaleSliderBlock
                .frame(width: 300)
                .offset(y: -300)
        }
        .frame(width: 10_000, height: 10_000)
    }

    var scaleSliderBlock: some View {
        VStack {
            HStack {
                Text("Visibility rect scale: ")
                Text(scale.formatted(.number.precision(.fractionLength(1))))
                    .bold()
            }
            .monospaced()

            Slider(value: $scale, in: 0...1.5, step: 0.1) { _ in }
        }
    }
}

#Preview {
    ExampleView()
}
