/*
 Copyright (c) 2020, Apple Inc. All rights reserved.
 
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

#ifndef ORKTinnitusPredefinedTaskConstants_h
#define ORKTinnitusPredefinedTaskConstants_h

// Survey answer values
static NSString *const ORKTinnitusSurveyAnswerYes = @"YES";
static NSString *const ORKTinnitusSurveyAnswerNo = @"NO";
static NSString *const ORKTinnitusSurveyAnswerPNTA = @"PNTA";
static NSString *const ORKTinnitusSurveyAnswerOther = @"OTHER";

static NSString *const ORKTinnitusSurveyAnswerNever = @"NEVER";
static NSString *const ORKTinnitusSurveyAnswerRarely = @"RARELY";
static NSString *const ORKTinnitusSurveyAnswerSometimes = @"SOMETIMES";
static NSString *const ORKTinnitusSurveyAnswerOften = @"OFTEN";
static NSString *const ORKTinnitusSurveyAnswerAlways = @"ALWAYS";

static NSString *const ORKTinnitusSurveyAnswerLeft = @"LEFT";
static NSString *const ORKTinnitusSurveyAnswerRight = @"RIGHT";
static NSString *const ORKTinnitusSurveyAnswerBoth = @"BOTH";

static NSString *const ORKTinnitusSurveyAnswerExtremely = @"EXTREMELY";
static NSString *const ORKTinnitusSurveyAnswerVery = @"VERY";
static NSString *const ORKTinnitusSurveyAnswerModerately = @"MODERATELY";
static NSString *const ORKTinnitusSurveyAnswerNotVery = @"NOTVERY";
static NSString *const ORKTinnitusSurveyAnswerBarely = @"BARELY";

static NSString *const ORKTinnitusSurveyAnswerApp = @"APP";
static NSString *const ORKTinnitusSurveyAnswerFan = @"FAN";
static NSString *const ORKTinnitusSurveyAnswerNoise = @"NOISE";
static NSString *const ORKTinnitusSurveyAnswerHearingAid = @"HEARING_AID";

static NSString *const ORKTinnitusSurveyAnswerBlog = @"BLOG";
static NSString *const ORKTinnitusSurveyAnswerResearch = @"RESEARCH";
static NSString *const ORKTinnitusSurveyAnswerAudiologist = @"AUDIOLOGIST";
static NSString *const ORKTinnitusSurveyAnswerWord = @"WORD_OF_MOUTH";

static NSString *const ORKTinnitusSurveyAnswerDidNotKnow = @"DID_NOT_KNOW";
static NSString *const ORKTinnitusSurveyAnswerDoNotNeed = @"DO_NOT_NEED";
static NSString *const ORKTinnitusSurveyAnswerDoctorAgainst = @"DOCTOR_AGAINST";

static NSString *const ORKTinnitusSurveyAnswerMusic = @"MUSIC";
static NSString *const ORKTinnitusSurveyAnswerSpeech = @"SPEECH";
static NSString *const ORKTinnitusSurveyAnswerNature = @"NATURE";
static NSString *const ORKTinnitusSurveyAnswerModulatedTones = @"MODULATED_TONES";

static NSString *const ORKTinnitusSurveyAnswerFocus = @"FOCUS";
static NSString *const ORKTinnitusSurveyAnswerAsleep = @"ASLEEP";
static NSString *const ORKTinnitusSurveyAnswerExercising = @"EXERCISING";
static NSString *const ORKTinnitusSurveyAnswerRelax = @"RELAX";
// Masking matching sounds
static NSString *const ORKTinnitusFilenameFire = @"camp_fire_5s";
static NSString *const ORKTinnitusFilenameRain = @"rain_5s";
static NSString *const ORKTinnitusFilenameForest = @"forest_5s";
static NSString *const ORKTinnitusFilenameOcean = @"ocean_5s";
// White noise matching sounds
static NSString *const ORKTinnitusFilenameWhitenoise = @"white_noise_5s";
static NSString *const ORKTinnitusFilenameCicadas = @"cicadas_5s";
static NSString *const ORKTinnitusFilenameCrickets = @"crickets_5s";
static NSString *const ORKTinnitusFilenameTeakettle = @"tea_kettle_5s";
static NSString *const ORKTinnitusFilenameCrowd = @"crowd_noise_5s";
static NSString *const ORKTinnitusFilenameAudiobook = @"audiobook_6s";

static NSString *const ORKTinnitusDefaultFilenameExtension = @"wav";

#endif /* ORKTinnitusTaskConstants_h */
