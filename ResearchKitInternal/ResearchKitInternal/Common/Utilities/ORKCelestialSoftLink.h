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

#import "ORKSoftLinking.h"

#import "Celestial_Private.h"


ORK_SOFT_LINK_FRAMEWORK(PrivateFrameworks, Celestial);
ORK_SOFT_LINK_CLASS(Celestial, AVSystemController);
#define AVSystemControllerSoft getAVSystemControllerClass()

ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_PickableRoutesAttribute)
#define AVSystemController_PickableRoutesAttribute getAVSystemController_PickableRoutesAttribute()

ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_RouteDescriptionKey_RouteCurrentlyPicked)
#define AVSystemController_RouteDescriptionKey_RouteCurrentlyPicked getAVSystemController_RouteDescriptionKey_RouteCurrentlyPicked()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_RouteDescriptionKey_RouteSubtype)
#define AVSystemController_RouteDescriptionKey_RouteSubtype getAVSystemController_RouteDescriptionKey_RouteSubtype()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_RouteDescriptionKey_BTDetails_ProductID)
#define AVSystemController_RouteDescriptionKey_BTDetails_ProductID getAVSystemController_RouteDescriptionKey_BTDetails_ProductID()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_RouteDescriptionKey_AVAudioRouteName)
#define AVSystemController_RouteDescriptionKey_AVAudioRouteName getAVOutputDeviceBluetoothListeningModeActiveNoiseCancellation()

<<<<<<< HEAD:ResearchKitInternal/ResearchKitInternal/Common/Utilities/ORKCelestialSoftLink.h
ORK_SOFT_LINK_CONSTANT(Celestial, AVSystemController_HeadphoneJackIsConnectedDidChangeNotification, NSString *)
ORK_SOFT_LINK_CONSTANT(Celestial, AVSystemController_ActiveAudioRouteDidChangeNotification, NSString *)
ORK_SOFT_LINK_CONSTANT(Celestial, AVSystemController_ServerConnectionDiedNotification, NSString *)
=======
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_SubscribeToNotificationsAttribute)
#define AVSystemController_SubscribeToNotificationsAttribute getAVSystemController_SubscribeToNotificationsAttribute()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_SystemVolumeDidChangeNotification)
#define AVSystemController_SystemVolumeDidChangeNotification getAVSystemController_SystemVolumeDidChangeNotification()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_AudioVolumeChangeReasonNotificationParameter)
#define AVSystemController_AudioVolumeChangeReasonNotificationParameter getAVSystemController_AudioVolumeChangeReasonNotificationParameter()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_AudioVolumeNotificationParameter)
#define AVSystemController_AudioVolumeNotificationParameter getAVSystemController_AudioVolumeNotificationParameter()

ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_HeadphoneJackIsConnectedDidChangeNotification)
#define AVSystemController_HeadphoneJackIsConnectedDidChangeNotification getAVSystemController_HeadphoneJackIsConnectedDidChangeNotification()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_ActiveAudioRouteDidChangeNotification)
#define AVSystemController_ActiveAudioRouteDidChangeNotification getAVSystemController_ActiveAudioRouteDidChangeNotification()
ORK_SOFT_LINK_NSSTRING_CONSTANT(Celestial, AVSystemController_ServerConnectionDiedNotification)
#define AVSystemController_ServerConnectionDiedNotification getAVSystemController_ServerConnectionDiedNotification()

#endif
>>>>>>> release/Peach:ResearchKit/Common/ORKCelestialSoftLink.h
