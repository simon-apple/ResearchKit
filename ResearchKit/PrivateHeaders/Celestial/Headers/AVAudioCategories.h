#include <CoreMedia/CMBasePrivate.h>
#if __has_include(<MediaExperience/AVAudioCategories.h>)
	#include <MediaExperience/AVAudioCategories.h>
	#warning "AVAudioCategories.h will be moving out of Celestial.framework soon. It will move to MediaExperience.framework. Please change your sources to add this from MediaExperience.framework ASAP."
#endif
