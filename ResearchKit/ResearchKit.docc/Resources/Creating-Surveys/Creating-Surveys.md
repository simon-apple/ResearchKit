# 
<sub>These materials are for informational purposes only and do not constitute legal advice. You should contact an attorney to obtain advice with respect to the development of a research app and any applicable laws.</sub>

# Creating Surveys

A survey is a sequence of questions that you use to collect data from your users.  In a ResearchKit app, a survey is composed of a <i>survey task</i> that has a collection of step objects (`ORKStep`). Each step object handles a specific question in the survey, such as "What medications are you taking?" or "How many hours did you sleep last night?".

You can collect results for the individual steps or for the task as a whole. There are two types of survey tasks: an ordered task (`ORKOrderedTask`) and a navigable ordered task (`ORKNavigableOrderedTask`).

In an ordered task, the order that the steps appear are always the same. 
<center>
<figure>
<img src="SurveyImages/OrderedTasks.png" style="width: 100%;"><figcaption><center>An example of a survey that uses ordered tasks.</center></figcaption>
</figure>
</center>

In a navigable ordered task, the order of the tasks can change, or branch out, depending on how the user answered a question in a previous task.

<center>
<figure>
<img src="SurveyImages/NavigableOrderedTasks.png" style="width: 100%;"><figcaption><center>An example of a survey that uses navigable ordered tasks.</center></figcaption>
</figure>
</center>

The steps for creating a task to present a survey are:

1. <a href="#create">Create one or more steps</a>
2. <a href="#task">Create a task</a>
3. <a href="#results">Collect results</a>

## 1. Create Steps<a name="create"></a>

The survey module provides a form step that can contain one or more questions
(`ORKFormStep`). You can also use an instruction step
(`ORKInstructionStep`) or a video instruction step (`ORKVideoInstructionStep`) to introduce the survey or provide instructions.

### Instruction Step

An instruction step explains the purpose of a task and provides
instructions for the user. An `ORKInstructionStep` object includes an
identifier, title, text, detail text, and an image. An
instruction step does not collect any data and yields an empty
`ORKStepResult` that nonetheless records how long the instruction was
on screen.

```swift
let instructionStep = ORKInstructionStep(identifier: "identifier")
instructionStep.title = "Selection Survey"
instructionStep.text = "This survey helps us understand your eligibility for the fitness study"
```

Creating a step as shown in the code above, including it in a task, and presenting with a task view controller, yields something like this:

<center>
<figure>
<img src="SurveyImages/InstructionStep.png" width="25%" alt="Instruction step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Example of an instruction step.</center></figcaption>
</figure>
</center>

### Form Step

Whether your survey has one question or several related questions, you can use a form step ([ORKFormStep](#)) to present them on one page. Each question in a form step is represented as a form item ([ORKFormItem](#)), each with its
own answer format.

The result of a form step contains one question result for each form
item. The results are matched to their corresponding form items using
their identifier property.

For example, the following code shows how to create a form that requests some basic details:


```swift
let sectionHeaderFormItem = ORKFormItem(sectionTitle: "Basic Information")
let nameFormItem = ORKFormItem(identifier: "NameIdentifier", text: "What is your name?", answerFormat: ORKTextAnswerFormat())
let emailFormItem = ORKFormItem(identifier: "EmailIdentifier", text: "What is your email?", answerFormat: ORKEmailAnswerFormat())
let headacheFormItem = ORKFormItem(identifier: "HeadacheIdentifier", text: "Do you have a headache?", answerFormat: ORKBooleanAnswerFormat())
 
let formStep = ORKFormStep(identifier: "FormStepIdenitifer")
formStep.title = "Basic Information"
formStep.detailText = "please answer the questions below"
formStep.formItems = [sectionHeaderFormItem, nameFormItem, emailFormItem, headacheFormItem]
```

The code above creates this form step:
<center>
<figure>
<img src="SurveyImages/FormStep.png" width="25%" alt="Form step"  style="border: solid black 1px;"  align="middle"/>
  <figcaption> <center>Example of a form step.</center></figcaption>
</figure>
</center>

### Answer Formats

In the ResearchKit™ framework, an answer format defines how the user should be asked to
answer a question or an item in a form.  For example, consider a
survey question such as "On a scale of 1 to 10, how much pain do you
feel?" The answer format for this question would naturally be a
discrete scale on that range, so you can use scale answer format ([ORKScaleAnswerFormat](#)), 
and set its [minimum]([ORKScaleAnswerFormat minimum]) and [maximum]([ORKScaleAnswerFormat maximum]) 
properties to reflect the desired range.  

The screenshots below show the standard answer formats that the ResearchKit framework provides.

<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/ScaleAnswerFormat.png" style="width: 100%;border: solid black 1px; ">Scale answer format</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/BooleanAnswerFormat.png" style="width: 100%;border: solid black 1px;">Boolean answer format</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SurveyImages/ValuePickerAnswerFormat.png" style="width: 100%;border: solid black 1px;">Value picker answer format  </p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/ImageChoiceAnswerFormat.png" style="width: 100%;border: solid black 1px; ">Image choice answer format  </p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextChoiceAnswerFormat_1.png" style="width: 100%;border: solid black 1px;">Text choice answer format (single text choice answer) </p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SurveyImages/TextChoiceAnswerFormat_2.png" style="width: 100%;border: solid black 1px;">Text choice answer format (multiple text choice answer) </p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/NumericAnswerFormat.png" style="width: 100%;border: solid black 1px; ">Numeric answer format</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TimeOfTheDayAnswerFormat.png" style="width: 100%;border: solid black 1px;">TimeOfTheDay answer format</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 3%; margin-bottom: 0.5em;"><img src="SurveyImages/DateAnswerFormat.png" style="width: 100%;border: solid black 1px;">Date answer format</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextAnswerFormat_1.png" style="width: 100%;border: solid black 1px; ">Text answer format (unlimited text entry)</p><p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/TextAnswerFormat_2.png" style="width: 100%;border: solid black 1px;">Text answer format (limited text entry) </p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/ValidatedTextAnswerFormat.png" style="width: 100%;border: solid black 1px;"> Validated text answer format</p>
<p style="clear: both;">
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/VerticalSliderAnswerFormat.png" style="width: 100%;border: solid black 1px;"> Scale answer format (vertical)</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/EmailAnswerFormat.png" style="width: 100%;border: solid black 1px;"> Email answer format</p>
<p style="float: left; font-size: 9pt; text-align: center; width: 25%; margin-right: 5%; margin-bottom: 0.5em;"><img src="SurveyImages/LocationAnswerFormat.png" style="width: 100%;border: solid black 1px;"> Location answer format</p>
<p style="clear: both;">

## 2. Create a Survey Task<a name="task"></a>

Once you create one or more steps, create an `ORKOrderedTask` object to
contain the steps. The code below shows the steps created above being added to a task.

```swift
// Create a task wrapping the instruction and form steps created earlier.
let orderedTask = ORKOrderedTask(identifier: "OrderedTaskIdentifier", steps: [instructionStep, formStep])
```


You must assign a string identifier to each step. The step identifier must be unique within the task, because it is the key that connects a step in the task hierarchy with the step result in the result hierarchy.

To present the task, attach it to a task view controller and present
it. The code below shows how to create a task view controller and present it modally.
        
```swift
let taskViewController = ORKTaskViewController(task: task, taskRun: nil)
taskViewController.delegate = self

present(taskViewController, animated: true)
```

*Note: `ORKOrderedTask` assumes that you will always present all the questions,
and will never decide what question to show based on previous answers.
To introduce conditional logic, you must either subclass
`ORKOrderedTask` or implement the `ORKTask` protocol yourself.*

## 3. Collect Results<a name="results"></a>

The [result]([ORKTaskViewController result]) property of the task view controller gives you the results of the task.
Each step view controller that the user views produces a step result
([ORKStepResult](#)). The task view controller collates these results as
the user navigates through the task, in order to produce an
[ORKTaskResult](#).

Both the task result and step result are collection results, in that
they can contain other result objects. For example, a task result contains an array of step results.

The results contained in a step result vary depending on the type of
step. For example, a form step produces one question result for
every form item; and an active task with recorders generally produces
one result for each recorder. 

The hierarchy of results corresponds closely to the input
model hierarchy of task and steps, as you can see here:

<center>
<figure>
<img src="SurveyImages/ResultsHierarchy.png" width="50%" alt="Completion step" align="middle" style="border: solid black 1px;">
  <figcaption> <center>Example of a result hierarchy</center>
  </figcaption>
</figure>
</center>

Among other properties, every result has an identifier. This
identifier is what connects the result to the model object (task,
step, form item, or recorder) that produced it. Every result also
includes start and end times, using the [startDate]([ORKResult startDate]) and [endDate]([ORKResult endDate])
properties respectively. These properties can be used to infer how long the user
spent on the step.
 

#### Saving Results on Task Completion

After a task is completed, you can save or upload the results. This approach 
will likely include serializing the result hierarchy in some form,
either using the built-in `NSSecureCoding` support, or another
format appropriate for your application.

If your task can produce file output, the files are generally referenced by an `ORKFileResult` object and they are placed in the output directory that you set on the task view controller. After you complete a task, one implementation might be to serialize the result hierarchy into the output directory, zip up the entire output
directory, and share it.

In the following example, the result is archived with
`NSKeyedArchiver` on successful completion.  If you choose to support
saving and restoring tasks, the user may save the task, so this
example also demonstrates how to obtain the restoration data that
would later be needed to restore the task.

```swift
 func taskViewController(_ taskViewController: ORKTaskViewController, 
 			             didFinishWith reason: ORKTaskFinishReason, 
 			             error: Error?) {
	switch reason {
	case .completed:
	    // Archive the result object first
	    do {
	        let data = try NSKeyedArchiver.archivedData(withRootObject: taskViewController.result, 
	                                                    requiringSecureCoding: true)
			 // Save the data to disk with file protection
	   	 	 // or upload to a remote server securely.
	    
	    	 // If any file results are expected, also zip up the outputDirectory.
	    } catch {
	        print("error archiving result data: \(error.localizedDescription)")
	    }
	    
	    break;
	case .failed, .discarded, .earlyTermination:
	    // Generally, discard the result.
	    // Consider clearing the contents of the output directory.
	    break;
	case .saved:
	    let data = taskViewController.restorationData
	    // Store the restoration data persistently for later use.
	    // Normally, keep the output directory for when you will restore.
	    break;
	}
	    
	taskViewController.dismiss(animated: true, completion: nil)
}
```

