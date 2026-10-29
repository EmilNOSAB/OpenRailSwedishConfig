The Item Types for this workspace are defined in the same dgnlib as the Feature Definitions.
Having the Item Types and Feature Defintions in the same file is recommended but not required.
When a Feature Definition uses an Item Type it is copied to the local file just like levels, element templates, etc. 
If Item Types and Feature Definitions that use those Item Types are in two separate dgnlib you will need to maintain that the Item Types in the Feature Definition dgnlib are in sync with the Item Types dgnlib.