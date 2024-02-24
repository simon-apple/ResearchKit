# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# Obtaining Consent

Research studies that involve human subjects typically require some form of ethics review. Depending on the country, this may be review by an institutional review board (IRB) or by an ethics committee (EC). For some studies, informed consent may be required to conduct a research study, which means that the researcher must ensure that each participant is fully informed about the nature of the study, and must obtain a signed consent from each participant.  Additionally, consent may be required as a condition of app review.

The ResearchKit™ framework makes it easy to display your consent document and to obtain a participant's signature. Note that the ResearchKit framework does not include digital signature support. If the signature needs to be verifiable and irrevocable, you are responsible for producing a digital signature or for generating a PDF that can be used to attest to the identity of the participant and the time at which the form was signed.

The ResearchKit framework makes obtaining consent easier by providing APIs to help with:

- **Informing Participants** - (ORKInstructionStep)

- **Reviewing Consent + Signature** - (ORKWebViewStep)

- **Consent Sharing** - (ORKFormStep)


## 1. Informing Participants with the ORKInstructionStep

When providing informed consent to prospective study participants, it is important to cover the necessary topics pertaining to your study specifically. Common topics usually addressed during informed consent are: 

* **Overview** - A brief but concise description of the purpose & goal of the study.
* **Data gathering** - The types of data gathered, where it will be stored, and who will have access to it.
* **Privacy** -  How your study has ensured privacy will be maintained while participating.
* **Data use** - How the data collected during this study is intended to be used. 
* **Time commitment** - Estimated amount of time a participant should expect to dedicate to your study.
* **Surveys** - The types of surveys/questions participants will be presented with.
* **Tasks** - The tasks the participant will have to complete for the study.
* **Withdrawal** - Information about withdrawal from the study and what happens to their data.  
