/*
 Copyright (c) 2024, Apple Inc. All rights reserved.

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

public struct InstructionStep: Step {
    
    public let identifier: String
    
    public let iconImage: Image?
    
    public let title: String?
    
    public let subtitle: String?
    
    public let bodyItems: [BodyItem]
    
    public init(
        identifier: String,
        iconImage: Image? = nil,
        title: String? = nil,
        subtitle: String? = nil,
        bodyItems: [BodyItem] = []
    ) {
        self.identifier = identifier
        self.iconImage = iconImage
        self.title = title
        self.subtitle = subtitle
        self.bodyItems = bodyItems
    }
    
    @ViewBuilder
    public func makeContent() -> some View {
        ForEach(bodyItems) { bodyItem in
            HStack {
                bodyItem.image
                    .frame(width: 40, height: 40)
                    .foregroundStyle(.blue)
                
                Text(bodyItem.text)
                    .font(.subheadline)
            }
        }
    }
    
}

public struct BodyItem: Identifiable {
    
    public let id = UUID()
    
    public let text: String
    
    public let image: Image
    
    public init(
        text: String,
        image: Image
    ) {
        self.text = text
        self.image = image
    }
    
}
