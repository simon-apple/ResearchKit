/*
 Copyright (c) 20202415, Apple Inc. All rights reserved.
 
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

import Foundation

final class DateFormatterManager {
    static let shared = DateFormatterManager()
    
    private init() {}
    
    private let hourMinutesFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        
        return dateFormatter
    }()
    
    private let amPmFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a"
        
        return dateFormatter
    }()
    
    private let hour12Formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "h"
        
        return dateFormatter
    }()
    
    private let hour24Formatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH"
        
        return dateFormatter
    }()
    
    private let minutesFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "mm"
        
        return dateFormatter
    }()
    
    private let monthDayFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d"
        
        return dateFormatter
    }()
    
    private let gmtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        return dateFormatter
    }()
    
    private let gmtDateTimeFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: "GMT")
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        return dateFormatter
    }()
    
    private let dateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d yyyy"
        
        return dateFormatter
    }()
    
    func hourMinutesString(from timeString: String) -> (String, String)? {
        guard let date = hourMinutesFormatter.date(from: timeString) else {
            return nil
        }
        let hourString = hour12Formatter.string(from: date)
        let amPmString = amPmFormatter.string(from: date)
        
        return (hourString, amPmString)
    }
    
    func amPmString(from date: Date) -> String {
        return amPmFormatter.string(from: date)
    }
    
    func hour12String(from date: Date) -> String {
        return hour12Formatter.string(from: date)
    }
    
    func gmtDateString(from date: Date) -> String {
        return gmtDateFormatter.string(from: date)
    }
    
    func gmtDateAndTimeString(from date: Date) -> String {
        return gmtDateTimeFormatter.string(from: date)
    }
    
    func monthDayString(from date: Date) -> String {
        return monthDayFormatter.string(from: date)
    }
    
    func hour24String(from date: Date) -> String {
        return hour24Formatter.string(from: date)
    }
    
    func minutesString(from date: Date) -> String {
        return minutesFormatter.string(from: date)
    }
    
    func dateStrings(from date: Date) -> (month: String, day: String, year: String) {
        let dateComponents = dateFormatter.string(from: date).components(separatedBy: " ")
        return (dateComponents[0], dateComponents[1], dateComponents[2])
    }
}
