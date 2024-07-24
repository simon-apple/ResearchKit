# Conditional Tasks and Forms

Use conditional logic for ResearchKit steps and forms.

## Overview

When presenting a survey or task it can be helpful to condtionally show specific content based on the participants responses. ResearchKit provides two solutions for conditional logic.

- **Step Navigation Rules**: Conditionally navigate to a specific step based on the participant's response.
- **Form Item Visibility Rules** - Conditionally hide or show specific form questions based on results from the same form or a form within another step.



### Step Navigation Rules

In order to conditionally navigate to or skip specific steps during a ORKTask you will need to be familiar with the following classes. 

- `ORKResultSelector` - A class that identifies a result within a set of task results.
- `ORKResultPredicate` - Creates a predicate by accepting a `ORKResultSelector` and the expected result.
- `ORKPredicateStepNavigationRule` - A object that determines what step to navigate to if a given `ORKResultPredicate` is true.
- `ORKNavigableOrderedTask` - A subclass of the `ORKOrderedTask` that can accept one or more `ORKPredicateStepNavigationRule` objects and applies the expected conditional navigation.


The task for this example will include the steps seen below.

TODO: ADD IMAGES

The conditional logic will be based on answering Yes or No for the first question (Do you like Apples?):

- **Answering Yes**: navigate to the second screen to select your favorite apple.
- **Answering No**: skips the second screen and navigates directly to the completion step.

```swift

// Construct Steps
let boolFormStep = ORKFormStep(identifier: "FormStep1")
boolFormStep.title = "Apple Task"
boolFormStep.text = "Please answer the following question."
        
let boolAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
let boolFormItem = ORKFormItem(identifier: "BooleanFormItemIdentifier", 
							   text: "Do you like Apples?", 
							   answerFormat: boolAnswerFormat)
        
boolFormStep.formItems = [boolFormItem]

let appleTextChoiceFormStep = appleTextChoiceFormStepExample()
let completionStep = completionStepExample()

// Conditional Logic
let boolResultSelector = ORKResultSelector(stepIdentifier: boolFormStep.identifier, resultIdentifier: boolFormItem.identifier)
let boolResultPredicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: boolResultSelector, expectedAnswer: false)
let navigationRule = ORKPredicateStepNavigationRule(resultPredicatesAndDestinationStepIdentifiers: [ (boolResultPredicate, completionStep.identifier) ])

// Construct Navigable Task + Set Navigation Rule
let navigableTask = ORKNavigableOrderedTask(identifier: "NavigableTaskIdentifier", steps: [formStep1, appleTextChoiceFormStep, completionStep])
navigableTask.setNavigationRule(navigationRule, forTriggerStepIdentifier: formStep1.identifier)
```

Selecting Yes:

TODO: add gif


Selecting No:

TODO: add gif

### Form Item Visibility Rules

To conditionally hide or show a question based on results from questions within the same form you will need to be familiar with the following classes.

- `ORKResultSelector` - Same as the section above.
- `ORKResultPredicate` - Same as the section above.
- `ORKPredicateFormItemVisibilityRule` - A object that determines if the formItem it's attached to is hidden or visible if a given `ORKResultPredicate` is true.

Following the previous example, we will use the same questions as before but now they will both reside on the same page. 


- **Answering Yes**: makes the apple choice question visible.
- **Answering No**: hides the apple choice question if visible.


```swift
// Construct FormStep
let formStep = ORKFormStep(identifier: "FormStep1")
formStep.title = "Apple Task"
formStep.text = "Please answer the following question."
        
let boolAnswerFormat = ORKAnswerFormat.booleanAnswerFormat()
let boolFormItem = ORKFormItem(identifier: "BooleanFormItemIdentifier", 
							   text: "Do you like Apples?", 
							   answerFormat: boolAnswerFormat)
							   
							   
let appleChoiceFormItem = appleChoiceFormItem()
        
formStep.formItems = [boolFormItem, appleChoiceFormItem]

let completionStep = completionStepExample()

// Conditional Logic
let resultSelector: ORKResultSelector = .init(stepIdentifier: formStep.identifier, resultIdentifier: boolFormItem.identifier)
let predicate = ORKResultPredicate.predicateForBooleanQuestionResult(with: resultSelector, expectedAnswer: true)
let visibilityRule = ORKPredicateFormItemVisibilityRule(predicate: predicate)
        
appleChoiceFormItem.visibilityRule = visibilityRule

// Construct Navigable Task
 let navigableTask = ORKNavigableOrderedTask(identifier: "NavigableTaskIdentifier", steps: [formStep, completionStep])
```

