/*
 Copyright (c) 2022, Apple Inc. All rights reserved.
 
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

//apple-internal

import Foundation

struct PIIScrubberDefinition: Codable {
    let patterns: [String]
    let description: String
}

@objcMembers
@objc public class PIIScrubber: NSObject {
    
    /**
     Public constants that are available scrubber `path`.
     Included in ResearchKit by Default
     Full path is org.researchkit.ResearchKit/Resources/Scrubber/
    */
    public static let emailScrubberName = "emailScrubber"
    public static let phoneScrubberName = "phoneScrubber"
    
    /**
        Private vars
    */
    /**
     Warning only Plist Files are supported,
     Using JSON will need to be escaped to not cause any JSON parsing issues
    */
    private static let scrubberExtensionType = "plist"
    private static let scrubbersFolderName = "Scrubbers"
    private static let researchKitBundle = Bundle(identifier: "org.researchkit.ResearchKit")!
    
    private let PIIReplacementTemplate = #""#
    
    /**
     Scrubber bookkeeping vars
    */
    let scrubberName: String
    let scrubberDefinition: PIIScrubberDefinition

    /**
     Returns a url of PIIScrubberDefinition that is loaded from
     the Main Bundle's Resources/Scrubbers or
     org.researchkit.ResearchKit's bundle if none are found
     under the PIIScrubber.scrubberExtensionType
     
     @param scrubberName: String   The filename of the scrubber to initialize,
     does not need to include the extension
     
     @return An url of the scrubber name
     */
    class func scrubberDefinitionURL(scrubberName: String) -> URL {
        let scrubberDefinitionURL =
            PIIScrubber.allScrubberFileURLs()
            .first { scrubberURL in
                let fileName = scrubberURL.deletingPathExtension().lastPathComponent
                return fileName == scrubberName
            }
        
        return scrubberDefinitionURL!
    }
    
    /**
     Returns an array of PIIScrubber URLS that are found from
     the provided bundle
     
     @param bundle: Bundle   The bundle used to lookup the files. Can be the
     main app Bundle or Researchkit's Bundle
     
     @return An array of discovered scrubber file urls
     */
    class func scrubberFilerURLs(in bundle: Bundle) -> [URL] {
           let URLs = bundle.urls(forResourcesWithExtension: scrubberExtensionType,
                                  subdirectory: scrubbersFolderName)
           return URLs ?? []
    }
    
    /**
     Returns an array of PIIScrubber names that are loaded from
     the Main Bundle's Resources/Scrubbers or
     org.researchkit.ResearchKit's bundle if none are found
     under the PIIScrubber.scrubberExtensionType
     
     @return An array of discovered scrubber names
     */
    public class func allScrubberNames() -> [String] {
        let scrubberNames: Set<String> =
            PIIScrubber.allScrubberFileURLs()
            .compactMap { eachURL -> String? in
                return eachURL.deletingPathExtension().lastPathComponent
                //[URL] -> [String]
            }
            .reduce(into: Set()) { partialResult, eachFileName in
                partialResult.insert(eachFileName)
                // [String] -> Set(String)
            }
        
        return Array(scrubberNames)
    }
    
    /**
     Returns an array of PIIScrubber URLS that are loaded from
     the Main Bundle's Resources/Scrubbers or
     org.researchkit.ResearchKit's bundle if none are found
     under the PIIScrubber.scrubberExtensionType
     
     @return An array of discovered scrubber URLS
     */
    private class func allScrubberFileURLs() -> [URL] {
        let bundles = [
            Bundle.main,
            PIIScrubber.researchKitBundle
        ]
        
        let scrubberURLS: Array<URL> = bundles
            .flatMap { eachBundle in
                scrubberFilerURLs(in: eachBundle)
                //[Bundles] -> [URL]
            }
        
        return scrubberURLS
    }
    
    /**
     Returns an initialized PIIScrubber using the specified scrubber name
     
     This method is the designated initializer.
     
     @param scrubberName   The filename of the scrubber to initialize,
     does not need to include the extension
     
     @return an initialized PIIScrubber using the specified scrubber name
     */
    public init(scrubberName: String) {
        self.scrubberName = scrubberName
        do {
            let data = try Data(contentsOf:
                                    PIIScrubber.scrubberDefinitionURL(scrubberName:
                                                                        scrubberName))
            let piiScrubberDefinition = try PropertyListDecoder().decode(
                                    PIIScrubberDefinition.self,
                                    from: data)
            self.scrubberDefinition = piiScrubberDefinition
        } catch {
            fatalError("PIIScrubber file not found")
        }
        super.init()
    }
    
    /**
     Will scrub and remove all text that matches any of the scrubber regex definitions
          
     @param text  The string to scrub
     
     @return a string that has been scrubbed out of the PII defined
     */
    public func scrub(_ text: String) -> String {
        var scrubbedText = text
        for pattern in scrubberDefinition.patterns {
            if let regex = try? NSRegularExpression(pattern: pattern,
                                                    options: [.caseInsensitive]) {
                let range = NSRange(location: 0, length: text.utf16.count)
                scrubbedText = regex.stringByReplacingMatches(in: scrubbedText,
                                                              range: range,
                                                              withTemplate: PIIReplacementTemplate)
            }
        }
        return scrubbedText
    }
}
