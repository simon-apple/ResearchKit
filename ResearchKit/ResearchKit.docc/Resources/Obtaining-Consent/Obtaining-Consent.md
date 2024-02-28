# Obtaining Consent

Use the ResearchKit framework to guide your participants through Informed Consent 

## Overview

Research studies that involve human subjects typically require some form of ethics review. Depending on the country, this may be review by an institutional review board (IRB) or by an ethics committee (EC). For some studies, informed consent may be required to conduct a research study, which means that the researcher must ensure that each participant is fully informed about the nature of the study, and must obtain a signed consent from each participant.  Additionally, consent may be required as a condition of app review.

The ResearchKit™ framework makes it easy to display your consent document and to obtain a participant's signature. Note that the ResearchKit framework does not include digital signature support. If the signature needs to be verifiable and irrevocable, you are responsible for producing a digital signature or for generating a PDF that can be used to attest to the identity of the participant and the time at which the form was signed.

The ResearchKit framework makes obtaining consent easier by providing APIs to help with:

- **Informing Participants** - `ORKInstructionStep`
- **Reviewing Consent + Signature** - `ORKWebViewStep`
- **Consent Sharing** - `ORKFormStep`


## 1. Informing Participants with the ORKInstructionStep

When providing informed consent to prospective study participants, it is important to cover the necessary topics pertaining to your study. Common topics usually addressed during informed consent are: 

* **Overview** - A brief but concise description of the purpose & goal of the study.
* **Data gathering** - The types of data gathered, where it will be stored, and who will have access to it.
* **Privacy** -  How your study has ensured privacy will be maintained while participating.
* **Data use** - How the data collected during this study is intended to be used. 
* **Time commitment** - Estimated amount of time a participant should expect to dedicate to your study.
* **Surveys** - The types of surveys/questions participants will be presented with.
* **Tasks** - The tasks the participant will have to complete for the study.
* **Withdrawal** - Information about withdrawal from the study and what happens to their data.  


Create two instruction steps to present both a 'Welcome' & 'Before You Join' page.

```swift
// Welcome page
let welcomeStep = ORKInstructionStep(identifier: String(describing: Identifier.consentWelcomeInstructionStep))
instructionStep.iconImage = UIImage(systemName: "hand.wave")
instructionStep.title = "Welcome!"
instructionStep.detailText = "Thank you for joining our study. Tap Next to learn more before signing up."
        
// Before You Join page
let beforeYouJoinStep = ORKInstructionStep(identifier: String(describing: Identifier.informedConsentInstructionStep))
instructionStep.iconImage = UIImage(systemName: "doc.text.magnifyingglass")
instructionStep.title = "Before You Join"
        
let sharingHealthDataBodyItem = ORKBodyItem(text: "The study will ask you to share some of your Health data.",
                                            detailText: nil,
                                            image: UIImage(systemName: "heart.fill"),
                                            learnMoreItem: nil,
                                            bodyItemStyle: .image)
        
let completingTasksBodyItem = ORKBodyItem(text: "You will be asked to complete various tasks over the duration of the study.",
                                          detailText: nil,
                                          image: UIImage(systemName: "checkmark.circle.fill"),
                                          learnMoreItem: nil,
                                          bodyItemStyle: .image)
        
let signatureBodyItem = ORKBodyItem(text: "Before joining, we will ask you to sign an informed consent document.",
                                    detailText: nil,
                                    image: UIImage(systemName: "signature"),
                                    learnMoreItem: nil,
                                    bodyItemStyle: .image)
        
let secureDataBodyItem = ORKBodyItem(text: "Your data is kept private and secure.",
                                     detailText: nil,
                                     image: UIImage(systemName: "lock.fill"),
                                     learnMoreItem: nil,
                                     bodyItemStyle: .image)
        
instructionStep.bodyItems = [
    sharingHealthDataBodyItem,
    completingTasksBodyItem,
    signatureBodyItem,
    secureDataBodyItem
]
```

The instruction step are presented as shown in Figure 1.

// todo: add images here


## 2. Review consent with the ORKWebViewStep

Users can review the consent content in the ORKWebViewStep as HTML. Depending on your signature requirements, users can also be asked to write a signature on the same screen.

The content for consent review can either be produced by converting the previous instructions steps to HTML, or you can provide entirely separate review content as custom HTML in the web view step's html property.

```swift


```



