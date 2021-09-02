/*
 Copyright (c) 2021, Apple Inc. All rights reserved.
 
 Redistribution and use in source and binary forms, with or without modification,
 are permitted provided that the following conditions are met:
 
 1.  Redistributions of source code must retain the above copyright notice, this
 list of conditions and the following disclaimer.
 
 2.  Redistributions in binary form must reproduce the above copyright notice,
 this list of conditions and the following disclaimer in the documentation and/or
 other materials provided with the distribution.
 
 3.  Neither the name of the copyright holder(s) nor the names of any contributors
 may be used to endorse or promote products derived from this software without
 specific prior written permission. No license is granted to the trademarks of
 the copyright holders even if such marks are included in this software.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE
 FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

import SwiftUI

@available(iOS 13.0, *)
struct TextChoiceView: View {
    @ObservedObject var textChoiceHelper: SwiftUITextChoiceHelper
    
    var answerDidUpdateClosure: ((Any) -> Void)?
    
    @State private var width: CGFloat?
    
    var body: some View {
        VStack() {
            ForEach(textChoiceHelper.swiftUItextChoices) { textChoice in
                let selected = textChoiceHelper.selectedIndexes.contains(textChoice.index)
                let isLast = textChoice.index == textChoiceHelper.size - 1;
                
                VStack {
                    TextChoiceRow(text: textChoice.text,
                                  image: textChoice.image,
                                  buttonTapped: buttonTapped(_:),
                                  index: textChoice.index,
                                  selected: selected,
                                  isLast: isLast,
                                  width: width)
                    
                    if (!isLast) {
                        Divider()
                            .padding(.leading, getDividerPadding(imagePresent: textChoice.image != nil))
                    }
                }
            }
        }
        .background(
                    GeometryReader { geo in
                        Color.clear
                            .preference(
                                key: WidthPreferenceKey.self,
                                value: geo.size.width
                            )
                    }
                )
                .onPreferenceChange(
                    WidthPreferenceKey.self,
                    perform: { geoWidth in
                        self.width = geoWidth
                    }
                )
    }
     
    private func buttonTapped(_ index: Int) {
        
        if let closure = answerDidUpdateClosure {
            textChoiceHelper.didSelectRowAtIndex(index: index)
            
            closure(textChoiceHelper.answersForSelectedIdexes())
        }
    }
    
    private func getDividerPadding(imagePresent: Bool) -> CGFloat {
        var dividerPadding: CGFloat = 20
        
        if let geoWidth = width, imagePresent {
            dividerPadding += ((geoWidth * 0.30) + 16)
        }
        
        return dividerPadding
    }
}

@available(iOS 13.0, *)
struct TextChoiceRow: View {
    var text: String
    var image: UIImage?
    var buttonTapped: (Int) -> Void
    var index: Int
    var selected: Bool
    var isLast: Bool
    var width: CGFloat?
    @State private var isPresented = false
    
    var body: some View {
        Button(action: {
            buttonTapped(index)
        }) {
            HStack {
                
                if let img = image {
                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: width.map { $0 * 0.30 })
                        .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.clear, lineWidth: 1))
                        .shadow(radius: 6, x: 1, y: 1)
                        .padding([.trailing], 16)
                        .compatibleFullScreen(isPresented: $isPresented) {
                            TextChoiceImageFullView(isPresented: $isPresented, text: text, image: img)
                        }
                        .onTapGesture {
                            isPresented.toggle()
                        }
                }
                
                Text(text)
                    .foregroundColor(Color.init(.label))
                    .font(.system(.subheadline))
                    .fontWeight(.light)
                
                Spacer()
                
                Image(systemName: selected ?  "checkmark.circle.fill" : "circle")
                    .resizable()
                    .frame(width: 25, height: 25)
                    .foregroundColor( selected ? Color.init(UIColor.systemBlue) : Color.init(UIColor.systemGray3))
                
            }
            .padding([.leading, .trailing], 20)
            .padding([.top, .bottom], 12)
        }
    }
}

@available(iOS 13.0, *)
struct TextChoiceImageFullView: View {
    @Binding var isPresented: Bool
    var text: String
    var image: UIImage
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                
                VStack {
                    Spacer()
                    
                    Image(uiImage: image)
                    
                    Spacer()
                    
                    HStack {
                        Text(text)
                    }
                    .frame(maxWidth: .infinity, minHeight: 100)
                    .accentColor(.white)
                    .background(Color.gray.opacity(0.23))
                }
            }
            .edgesIgnoringSafeArea([.bottom, .top])
            
            .navigationBarItems(trailing:
                                    Button(action: {
                                        isPresented.toggle()
                                    }) {
                                        Text("Done")
                                    }
                                    .foregroundColor(.blue)
            )
        }
    }
    
}

@available(iOS 13.0, *)
struct SwiftUITextChoice: Identifiable {
    var id: String
    var text: String
    var image: UIImage?
    var index: Int
}

@available(iOS 13.0, *)
class SwiftUITextChoiceHelper: ObservableObject {
    var textChoices = [ORKTextChoice]()
    var swiftUItextChoices = [SwiftUITextChoice]()
    var answer: Any
    var answerFormat: ORKTextChoiceAnswerFormat
    var size: Int
    
    @Published var selectedIndexes = [Int]()
    
    init(answer: Any, answerFormat: ORKTextChoiceAnswerFormat) {
        self.answer = answer
        self.answerFormat = answerFormat
        self.textChoices = answerFormat.textChoices
        self.size = textChoices.count
        
        setSwiftUITextChoices()
    }
    
    func didSelectRowAtIndex(index: Int) {
        
        if (!selectedIndexes.contains(index)) {
            
            if (answerFormat.style == .singleChoice) {
                selectedIndexes.removeAll()
            }
            selectedIndexes.append(index)
        } else if (answerFormat.style == .multipleChoice) {
            selectedIndexes = selectedIndexes.filter { $0 != index }
        }
        
        answer = answersForSelectedIdexes()
    }
    
    func answersForSelectedIdexes() -> Any {
        var answers = [Any]()
        
        for index in selectedIndexes {
            let textChoice = textChoices[index]
            answers.append(textChoice.value)
        }
        
        return answers
    }
    
    private func setSwiftUITextChoices() {
        var arr = [SwiftUITextChoice]()
        
        for (index, textChoice) in textChoices.enumerated() {
            let choiceID = "\(textChoice.text)-\(DateFormatter().string(from: Date()))"
            arr.append(SwiftUITextChoice(id: choiceID, text: textChoice.text, image: textChoice.image, index: index))
        }
        
        swiftUItextChoices = arr
    }
}

@available(iOS 13.0, *)
struct WidthPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat?

    static func reduce(
        value: inout CGFloat?,
        nextValue: () -> CGFloat?
    ) {
        if value == nil {
            value = nextValue()
        }
    }
}

@available(iOS 13.0, *)
struct FullScreenModifier<V: View>: ViewModifier {
    let isPresented: Binding<Bool>
    let builder: () -> V

    @ViewBuilder
    func body(content: Content) -> some View {
        if #available(iOS 14.0, *) {
            content.fullScreenCover(isPresented: isPresented, content: builder)
        } else {
            content.sheet(isPresented: isPresented, content: builder)
        }
    }
}

@available(iOS 13.0, *)
extension View {
    func compatibleFullScreen<Content: View>(isPresented: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
        self.modifier(FullScreenModifier(isPresented: isPresented, builder: content))
    }
}
