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


