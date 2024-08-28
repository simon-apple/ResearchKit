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

## Constructing a Family History Step

Before initializing a ``ORKFamilyHistoryStep`` you should familiarize yourself with the classes required. 

- **ORKHealthCondition** - Represents a single health condition presented in your survey.
- **ORKConditionStepConfiguration** - Use the same questions for each relative group or create a different survey for each.