# ``/ResearchKit/ORKNewAudiometry``

<!-- The content below this line is auto-generated and is redundant. You should either incorporate it into your content above this line or delete it. -->

## Topics

### Initializers

- ``init(channel:)``
- ``init(channel:initialLevel:minLevel:maxLevel:frequencies:)``
- ``init(channel:initialLevel:minLevel:maxLevel:frequencies:kernelLenght:stoppingCriteria:)``

### Instance Properties

- ``allFrequencies``
- ``fitMatrix``
- ``initialSampleEnded``
- ``initialSamples``
- ``previousAudiogram``
- ``progress``
- ``testEnded``
- ``timestampProvider``
- ``xSample``
- ``ySample``

### Instance Methods

- ``createNewUnit()``
- ``nextStimulus()``
- ``registerPreStimulusDelay(_:)``
- ``registerResponse(_:)``
- ``registerStimulusPlayback()``
- ``resultSamples()``
- ``resultUnits()``
- ``signalClipped()``
- ``updateUnit(with:)``

### Type Methods

- ``nllFn(_:_:_:_:)``