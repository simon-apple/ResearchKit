/*
 Copyright (c) 2019, Apple Inc. All rights reserved.
 
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

// apple-internal

#if RK_APPLE_INTERNAL

import Foundation
import UIKit
import ResearchKit
import ResearchKitUI
import ResearchKitUI_Private

// swiftlint:disable:next type_body_length
class StudyPromoViewController: ORKCustomStepViewController {
    
    enum Constants {
        static let imageToHeader: CGFloat = 26
        static let expectationsBottomPadding: CGFloat = 24
        static let sectionPadding: CGFloat = 22
    }
    
    private var ineligibleView: UIView?
    static var imageWidth: CGFloat = UIScreen.main.bounds.width
    
    private var ineligibleViewConstraints = [NSLayoutConstraint]()
    private var noIneligibleViewConstraints = [NSLayoutConstraint]()


    init() {
        let contentView = UIView()

        let promoImageView = UIImageView(image: UIImage(named: "promo_image"))
        promoImageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(promoImageView)
        

        let headerSection = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        headerSection.text = "Sample Header"
        
        headerSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(headerSection)
        
        let purposePromoView = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        purposePromoView.text = "Sample Promo View"
        
        purposePromoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(purposePromoView)
        
        let aboutPromoView = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        aboutPromoView.text = "Sample About Promo View"
        
        aboutPromoView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(aboutPromoView)

      
        let expectationsPromoSection = UILabel(frame: CGRect.init(x: 0, y: 0, width: 200, height: 50))
        expectationsPromoSection.text = "Promo Bullet View"

        expectationsPromoSection.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(expectationsPromoSection)
        
        promoImageView.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        promoImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor).isActive = true
        promoImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor).isActive = true

        headerSection.topAnchor.constraint(equalTo: promoImageView.bottomAnchor, constant: Constants.imageToHeader).isActive = true
        headerSection.layoutHorizontally(to: contentView)

        purposePromoView.topAnchor.constraint(equalTo: headerSection.bottomAnchor, constant: Constants.sectionPadding).isActive = true
        purposePromoView.layoutHorizontally(to: contentView)

        aboutPromoView.topAnchor.constraint(equalTo: purposePromoView.bottomAnchor, constant: Constants.sectionPadding).isActive = true
        aboutPromoView.layoutHorizontally(to: contentView)

        expectationsPromoSection.topAnchor.constraint(equalTo: aboutPromoView.bottomAnchor,
                                                      constant: Constants.sectionPadding).isActive = true
        expectationsPromoSection.layoutHorizontally(to: contentView)

        // Initialize the step
        
        let step = ORKCustomStep(identifier: "studyPromoStepIdentifier", contentView: contentView)
        step.pinNavigationContainer = false
        step.useExtendedPadding = true
        super.init(step: step)
        // Set up inelible view
        ineligibleView = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 100))
        guard let inelegibileView = ineligibleView else {
            return
        }

        inelegibileView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(inelegibileView)
        ineligibleViewConstraints = [
            inelegibileView.topAnchor.constraint(equalTo: expectationsPromoSection.bottomAnchor, constant: 12.0),
            inelegibileView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                    constant: -Constants.expectationsBottomPadding),
            inelegibileView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            inelegibileView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        
        noIneligibleViewConstraints = [
            expectationsPromoSection.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor,
                                                             constant: -Constants.expectationsBottomPadding)
        ]
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelTapped))

    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func stepDidChange() {
        super.stepDidChange()
        self.showScrollIndicator = true
    }
 
    @objc func cancelTapped() {
        
    }
}

extension UIView {
    
    public enum LayoutAttribute {
        case leading
        case trailing
        case top
        case bottom

        static var all: [LayoutAttribute] { return [.leading, .trailing, .top, .bottom] }
    }
    
    // MARK: Layout
    
    public func layoutHorizontallyWithStandardPadding(to view: UIView) {
        layoutHorizontally(to: view, padding: Style.Constants.standardPadding)
    }
    
    public func layoutHorizontally(to view: UIView, padding: CGFloat = 0) {
        layout(equalTo: view, directions: [.leading, .trailing], constant: padding)
    }
    
    public func layoutVertically(to view: UIView, padding: CGFloat = 0) {
        layout(equalTo: view, directions: [.top, .bottom], constant: padding)
    }
    
    public func layout(filling view: UIView, padding: CGFloat = 0) {
        layout(equalTo: view, directions: LayoutAttribute.all, constant: padding)
    }
    
    public func layout(equalTo view: UIView, directions: [LayoutAttribute], constant: CGFloat = 0) {
        if directions.contains(.leading) {
            self.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: constant).isActive = true
        }

        if directions.contains(.trailing) {
            self.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -constant).isActive = true
        }

        if directions.contains(.top) {
            self.topAnchor.constraint(equalTo: view.topAnchor, constant: constant).isActive = true
        }

        if directions.contains(.bottom) {
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -constant).isActive = true
        }
    }
    
    public func centerVertically(in view: UIView) {
        self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }
    
    public func layoutSize(height: CGFloat = 0, width: CGFloat = 0) {
        self.heightAnchor.constraint(equalToConstant: height).isActive = true
        self.widthAnchor.constraint(equalToConstant: width).isActive = true
    }
    
    public func layoutSquare(constant: CGFloat) {
        self.layoutSize(height: constant, width: constant)
    }
    
    // MARK: Subviews
    
    public func addSubviews(_ views: [UIView]) {
        views.forEach { self.addSubview($0) }
    }
}

public enum Style {
    
    public static func configureGlobalAppearance() {
        UINavigationBar.appearance().prefersLargeTitles = true
    }
    
    public enum Colors {
        public static var keyColor: UIColor {
            return UIColor.systemBlue
        }
        public static var systemGrayColor: UIColor {
            return UIColor(red: 142.0 / 255, green: 142.0 / 255, blue: 147.0 / 255, alpha: 1.0)
        }
        public static var systemMidGrayColor: UIColor {
            return UIColor(red: 199.0 / 255, green: 199.0 / 255, blue: 204.0 / 255, alpha: 1.0)
        }
        public static var cellBackgroundColor: UIColor {
            return UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1.0)
        }
        public static var primaryLabelColor: UIColor {
            return UIColor.black
        }
        public static var secondaryLabelColor: UIColor {
            return systemGrayColor
        }
        public static var overlayStampTextColor: UIColor {
            return UIColor.white
        }
        public static var overlayStampBackgroundColor: UIColor {
            return UIColor(red: 0.297, green: 0.501, blue: 1, alpha: 1)
        }
        public static var radarColor: UIColor {
            return UIColor(red: 0.49, green: 0.27, blue: 0.96, alpha: 1)
        }
        public static var dataSourceBackgroundColor: UIColor {
            return UIColor(red: 249 / 255.0, green: 249 / 255.0, blue: 249 / 255.0, alpha: 1.0)
        }
        public static var dividerColor: UIColor {
            return UIColor(red: 224 / 255.0, green: 224 / 255.0, blue: 224 / 255.0, alpha: 1)
        }
        public static var completedTasksMetricColor: UIColor {
            return UIColor(red: 90 / 255.0, green: 87 / 255.0, blue: 218 / 255.0, alpha: 1)
        }
        public static var questionsAnsweredMetricColor: UIColor {
            return UIColor(red: 25 / 255.0, green: 201 / 255.0, blue: 252 / 255.0, alpha: 1)
        }
        public static var daysInStudyMetricColor: UIColor {
            return UIColor.black
        }
    }
    
    public enum Constants {
        
        private static let isScreenSmall: Bool = {
            return UIScreen.main.bounds.width <= Constants.smallScreenBoundary
        }()
        
        // Generic
        public static let smallScreenBoundary: CGFloat = 320.0
        public static let cornerRadius: CGFloat = 10.0
        public static let standardPadding: CGFloat = 24.0
        public static let innerCardPadding: CGFloat = 16.0
        public static let dividerStroke: CGFloat = 0.5
        public static let layoutMargin: CGFloat = {
            return isScreenSmall ? 16.0 : 24.0
        }()
        
        // Buttons
        public static let buttonCornerRadius: CGFloat = 14.0
        public static let standardButtonHeight: CGFloat = 50.0
        public static let profileButtonPointSize: CGFloat = {
            return isScreenSmall ? 32.0 : 34.0
        }()
        
        // Table Cells
        public static let groupedTablePadding: CGFloat = 19.0
        public static let tableCellInnerPadding: CGFloat = 16.0
        public static let innerTableCellVerticalPadding: CGFloat = 12.0
        public static let imageIconSize: CGFloat = 29.0
        public static let leadingTableCellPadding: CGFloat = {
            return isScreenSmall ? 16.0 : 20.0
        }()
        
        // Tables
        public static let sectionFooterInset: CGFloat = 16.0
        public static let tableCardVerticalSpacing: CGFloat = 10.0
        
        // Stacks
        public static let stackViewHorizontalSpacing: CGFloat = 6.0
    }
    
    public enum Fonts {
        private static func preferredBoldFont(withTextStyle textStyle: UIFont.TextStyle) -> UIFont {
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: textStyle)
            guard let boldDescriptor = fontDescriptor.withSymbolicTraits(.traitBold) else {
                fatalError("Error adding symbolic traits to preferredFontDescriptor")
            }
            return UIFont(descriptor: boldDescriptor, size: 0.0)
        }
        
        public static func boldBody() -> UIFont {
            return preferredBoldFont(withTextStyle: .body)
        }
        
        public static func boldSubheadline() -> UIFont {
            return preferredBoldFont(withTextStyle: .subheadline)
        }
        
        public static func boldFootnote() -> UIFont {
            return preferredBoldFont(withTextStyle: .footnote)
        }
        
        public static func boldCallout() -> UIFont {
            return preferredBoldFont(withTextStyle: .callout)
        }
        
        public static func boldTitleLarge() -> UIFont {
            return preferredBoldFont(withTextStyle: .largeTitle)
        }
        
        public static func boldCaption1() -> UIFont {
            return preferredBoldFont(withTextStyle: .caption1)
        }
        
        public static func boldCaption2() -> UIFont {
            return preferredBoldFont(withTextStyle: .caption2)
        }
        
        public static func boldTitle3() -> UIFont {
            return preferredBoldFont(withTextStyle: .title3)
        }
        
        public static func tableSectionHeaderFont() -> UIFont {
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2)
            guard let boldDescriptor = fontDescriptor.withSymbolicTraits([.traitBold, .traitTightLeading]) else {
                fatalError("Error adding symbolic traits to preferredFontDescriptor")
            }
            
            return UIFont(descriptor: boldDescriptor, size: 0)
        }
        
        public static func tableSectionHeaderSubtitleFont() -> UIFont {
            let fontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .subheadline)
            
            return UIFont(descriptor: fontDescriptor, size: 0)
        }
    }
    
    public enum Symbols {
        public static let filledCheckmark = "checkmark.circle.fill"
        
        public static var sensorImage: UIImage {
            if let image = UIImage(systemName: "gauge") {
                return image.withRenderingMode(.alwaysTemplate)
            }
            
            return UIImage()
        }
    }
}
#endif
