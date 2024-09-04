# Family History Step

Use the Family History Step to collect insightful health trends.

## Overview

Obtaining accurate family health history is an extremely valueable data set to possibly prepare or avoid common health conditions a patient might face in the future. However, obtaining this information has always been a struggle when collected manually and even digitally. Now with ResearchKit, developers and researchers have the ability to quickly construct a ``ORKFamilyHistoryStep`` 
and present a family health history survey tailored to their specific needs. 

With the ``ORKFamilyHistoryStep`` you can specify:

- **Relative Types** - Determine the exact type of family members the survey asks about. 
- **Survey Questions** - Use the same questions for each relative group or create a different survey for each.
- **Health Conditions** - Include a list of health conditions that can be the same or different for each relative group.
- **Displayed Results** - Determine what results are displayed back to the user after they complete the survey for each relative.

## Understanding the Family History Step classes

Before initializing a ``ORKFamilyHistoryStep`` you should familiarize yourself with the classes required. 

- **ORKHealthCondition** - Represents a single health condition presented in your survey.
- **ORKConditionStepConfiguration** - This object provides the information needed for the health conditions list presented to the user. 
- **ORKRelativeGroup** - This represents a specific relative group such as Grandparents, Children, or Siblings.
- **ORKRelatedPerson** - Represents a family member who has been added during the survey. These objects are retrieved from the result of the ``ORKFamilyHistoryStep``.


In the next section we will walk through constructing a ``ORKFamilyHistoryStep`` using the classes above. 

## Constructing a Family History Step

Following the example below, we will walk through recreating the same Family History Step, but only for the parent group.

// TODO: ADD EXAMPLE IMAGES

### Creating Health Condition Objects

First, create the ``ORKHealthCondition`` objects necessary to display the health conditions specific to your survey.

```swift
 let healthConditions = [
        ORKHealthCondition(identifier: "healthConditionIdentifier1", displayName: "Diabetes", value: "Diabetes" as NSString),
        ORKHealthCondition(identifier: "healthConditionIdentifier2", displayName: "Heart Attack", value: "Heart Attack" as NSString),
        ORKHealthCondition(identifier: "healthConditionIdentifier3", displayName: "Stroke", value: "Stroke" as NSString)
        ]
```

### Create Condition Step Configuration

Next, initialize a ``ORKConditionStepConfiguration`` and add the necessary information which includes the health conditions array created before this.


```swift
let conditionStepConfiguration = ORKConditionStepConfiguration(stepIdentifier: "FamilyHistoryConditionStepIdentifier", 
                                                               conditionsFormItemIdentifier: "HealthConditionsFormItemIdentifier",
                                                               conditions: healthConditions,
                                                               formItems: [])
```

- **stepIdentifier** - When the user is presented with the health conditions to select they are technically looking at a ``ORKFormStep`` that was initialized by the ``ORKFamilyHistoryStep`` itself. The value you set for this property will be used as the step identifier for the health conditions form step.
- **conditionsFormItemIdentifier** - The string used as the identifier for the health conditions text choice question. Use this identifier to locate the health conditions selected in the ORKResult for each family member.
- **conditions** - Each ``ORKHealthCondition`` in this list will be presented as individual text choice to the user.
- **formItems** - Optionally provide more form items in order to present additional questions under the health conditions text choices.

### Create Relative Group

The last object needed for the family history step is the ``ORKRelativeGroup``. 

```swift
let parentFormStep = ORKFormStep(identifier: "ParentSurveyIdentifier")
parentFormStep.isOptional = false
parentFormStep.title = "Parent"
parentFormStep.detailText = "Answer these questions to the best of your ability."
parentFormStep.formItems = parentFormStepFormItems()

let parentRelativeGroup = ORKRelativeGroup(identifier: "ParentGroupIdentifier",
                                           name: "Biological Parent",
                                           sectionTitle: "Biological Parents",
                                           sectionDetailText: "Incude your blood-related parents.",
                                           identifierForCellTitle: "ParentNameIdentifier",
                                           maxAllowed: 2,
                                           formSteps: [parentFormStep],
                                           detailTextIdentifiers: ["ParentSexAtBirthIdentifier", "ParentVitalStatusIdentifier", "ParentAgeFormItemIdentifier"])
```

### Create Family History Step

For the last step, we will construct the ``ORKFamilyHistoryStep`` and pass in the initialized objects from above.
        
```swift
let familyHistoryStep = ORKFamilyHistoryStep(identifier: "FamilyHistoryStepIdentifier)
familyHistoryStep.title = "Family Health History"
familyHistoryStep.detailText = "The overview of your biological family members can inform health risks and lifestyle."
familyHistoryStep.conditionStepConfiguration = conditionStepConfiguration
familyHistoryStep.relativeGroups = relativeGroups
```

### Parsing Family History Step Result

After presenting the task, parse the ``ORKTaskResult`` to access the ``ORKFamilyHistoryResult``.


```swift
 guard let stepResult = (taskViewController.result.results?[1] as? ORKStepResult) else { return }
        
if let familyHistoryResult = stepResult.results?.first as? ORKFamilyHistoryResult {
	let relatedPersons = familyHistoryResult.relatedPersons
}
```