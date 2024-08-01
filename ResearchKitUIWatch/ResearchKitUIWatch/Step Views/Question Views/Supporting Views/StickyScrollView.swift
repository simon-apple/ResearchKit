//
//  StickyScrollView.swift
//  ResearchKitUI(Watch)
//
//  Created by Jessi Aboukasm on 3/13/24.
//

//
//  StickyScrollView.swift
//  HARPUI
//
//  Created by Andrew Plummer on 9/10/2022.
//

import SwiftUI

/// A vertical ScrollView with a sticky footer, that returns to flow inline if
/// the content is longer than the available height.
/// Usage:
/// ```
/// StickyScrollView {
///   allowsExtendedLayout: true,
///   bodyContent: { /* Your Content */ },
///   footerContent: { /* Will stick to bottom if bodyContent is short */ }
/// }
/// ```
public struct StickyScrollView<BodyContent: View, FooterContent: View>: View {

    /// Create a StickyScrollView with footer content that can stick to the content bounds if the content is longer
    /// than the scrollView frame.
    /// - Parameters:
    ///   - allowsExtendedLayout: Allow the footer to stick to bottom of content if the content is longer
    /// than the container height.
    ///   - bodyContent: The body content for the ScrollView
    ///   - footerContent: The footer content.
    public init(
        allowsExtendedLayout: Bool = false,
        paddingAboveKeyboard: CGFloat = 0.0,
        centerContentIfFits: Bool = false,
        bodyContent: @escaping (CGSize) -> BodyContent,
        footerContent: @escaping () -> FooterContent
    ) {
        self.allowsExtendedLayout = allowsExtendedLayout
        self.bodyContent = bodyContent
        self.footerContent = footerContent
        self.paddingAboveKeyboard = paddingAboveKeyboard
        self.centerContentIfFits = centerContentIfFits
    }

    public init(
        allowsExtendedLayout: Bool = false,
        paddingAboveKeyboard: CGFloat = 0.0,
        centerContentIfFits: Bool = false,
        bodyContent: @escaping () -> BodyContent,
        footerContent: @escaping () -> FooterContent
    ) {
        self.init(
            allowsExtendedLayout: allowsExtendedLayout,
            paddingAboveKeyboard: paddingAboveKeyboard,
            centerContentIfFits: centerContentIfFits,
            bodyContent: { _ in bodyContent() },
            footerContent: footerContent
        )
    }

    @ViewBuilder public let bodyContent: (CGSize) -> BodyContent

    @ViewBuilder public let footerContent: () -> FooterContent

    public let paddingAboveKeyboard: CGFloat

    public let centerContentIfFits: Bool

    private let allowsExtendedLayout: Bool

    @Namespace
    var scrollCoordinateSpace

    @State
    private var offset = CGFloat.zero

    @State
    private var frameSize = CGSize.zero

    @State
    private var totalLayoutHeight = CGFloat.zero

    @State
    private var availableContentHeight = CGFloat.zero

    @State
    private var bodySize = CGSize.zero

    @State
    private var safeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    @State
    private var keyboardIgnoringSafeAreaInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)

    @State
    private var isFooterBackgroundVisible = false

    public var body: some View {
        GeometryReader { outerGeo in
            ScrollView {
                GeometryReader { geo in
                    let offset = geo.frame(in: .named(scrollCoordinateSpace)).origin.y
                    StickyLayout(
                        allowsExtendedLayout: allowsExtendedLayout,
                        size: frameSize,
                        bodySize: bodySize,
                        offset: offset,
                        safeAreaInsets: safeAreaInsets,
                        keyboardIgnoringSafeAreaInsets: keyboardIgnoringSafeAreaInsets,
                        isContentCenteringEnabled: centerContentIfFits,
                        totalLayoutHeight: $totalLayoutHeight,
                        availableContentHeight: $availableContentHeight,
                        isFooterBackgroundVisible: $isFooterBackgroundVisible
                    ) {

                        let bodySize = CGSize(
                            width: geo.size.width - geo.safeAreaInsets.leading - geo.safeAreaInsets.trailing,
                            height: availableContentHeight
                        )
                        VStack(spacing: 0) {
                            bodyContent(bodySize)
                                .fixedSize(horizontal: false, vertical: true)
                                .background(GeometryReader {
                                    Color.clear.preference(
                                        key: BodySizeKey.self,
                                        value: $0.size
                                    )
                                })
                        }
                        .frame(
                            maxWidth: bodySize.width,
                            minHeight: centerContentIfFits ? outerGeo.size.height - outerGeo.safeAreaInsets.top - outerGeo.safeAreaInsets.bottom : nil
                        )
                        StickyFooterLayout(
                            safeAreaInsets: safeAreaInsets
                        ) {
                            VStack(spacing: 0) {
                                Rectangle()
                                    .frame(
                                        maxWidth: .infinity,
                                        minHeight: 1,
                                        maxHeight: 1,
                                        alignment: .topLeading
                                    )
                                    .background(Color.gray)
                                    .opacity(isFooterBackgroundVisible ? 0.1 : 0)
                                footerContent()
                                    .padding()
                            }
                        }
                        .edgesIgnoringSafeArea(.bottom)
#if !os(watchOS)
                        .background(Material.bar.opacity(isFooterBackgroundVisible ? 100 : 0))
#endif
                        .frame(maxWidth: .infinity)
                    }
                }
                .frame(height: totalLayoutHeight, alignment: .topLeading)
            }
            .safeAreaInset(edge: .bottom) {
                Color.clear.frame(height: safeAreaInsets != keyboardIgnoringSafeAreaInsets
                    ? paddingAboveKeyboard
                    : 0.0
                )
            }
            .background(GeometryReader {
                Color.clear.preference(
                    key: FrameSizeKey.self,
                    value: $0.size
                )
                Color.clear.preference(
                    key: SafeAreaInsetsKey.self,
                    value: $0.safeAreaInsets
                )
            })
            .overlay {
                GeometryReader {
                    Color.clear.preference(
                        key: KeyboardIgnoringSafeAreaInsets.self,
                        value: $0.safeAreaInsets
                    )
                }
                .ignoresSafeArea(.keyboard, edges: .all)
            }
            .coordinateSpace(name: scrollCoordinateSpace)
            .onPreferenceChange(FrameSizeKey.self) { value in
                self.frameSize = value
            }
            .onPreferenceChange(SafeAreaInsetsKey.self) { value in
                self.safeAreaInsets = value
            }
            .onPreferenceChange(KeyboardIgnoringSafeAreaInsets.self) { value in
                self.keyboardIgnoringSafeAreaInsets = value
            }
            .onPreferenceChange(BodySizeKey.self, perform: { value in
                self.bodySize = value
            })
        }
    }
}

private struct FrameSizeKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue = CGSize.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = CGSize(
            width: value.width + nextValue().width,
            height: value.height + nextValue().height
        )
    }
}

private struct BodySizeKey: PreferenceKey {
    typealias Value = CGSize
    static var defaultValue = CGSize.zero
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value = CGSize(
            width: value.width + nextValue().width,
            height: value.height + nextValue().height
        )
    }
}

private struct KeyboardIgnoringSafeAreaInsets: PreferenceKey {
    typealias Value = EdgeInsets
    static var defaultValue = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let nextValue = nextValue()
        value = EdgeInsets(
            top: value.top + nextValue.top,
            leading: value.leading + nextValue.leading,
            bottom: value.bottom + nextValue.bottom,
            trailing: value.trailing + nextValue.trailing
        )
    }
}

private struct SafeAreaInsetsKey: PreferenceKey {
    typealias Value = EdgeInsets
    static var defaultValue = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    static func reduce(value: inout Value, nextValue: () -> Value) {
        let nextValue = nextValue()
        value = EdgeInsets(
            top: value.top + nextValue.top,
            leading: value.leading + nextValue.leading,
            bottom: value.bottom + nextValue.bottom,
            trailing: value.trailing + nextValue.trailing
        )
    }
}


public struct ToolbarButton: ButtonStyle {
    let isDisabled: Bool

    public init(isDisabled: Bool = false) {
        self.isDisabled = isDisabled
    }

    var buttonColor: Color {
        return isDisabled ? .gray : .blue
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(12)
            .background(
                configuration.isPressed
                ? buttonColor.opacity(0.8).cornerRadius(12) : buttonColor.cornerRadius(12)
            )
            .disabled(isDisabled)
            .scaleEffect(configuration.isPressed ? 1.05 : 1)
            .animation(.easeOut(duration: 0.2), value: configuration.isPressed)
    }
}
