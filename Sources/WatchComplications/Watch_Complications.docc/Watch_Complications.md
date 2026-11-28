# ``Watch_Complications``

Show the selected RVT timer on the watch face.

@Metadata {
    @DisplayName("RVT Watch Complication")
}

## Overview

``RiValT_Complications`` provides inline, corner, circular, and rectangular accessory layouts on watchOS 10 or later. Each layout shows the remaining time and identifies warning and final phases with a symbol and, when the watch face permits it, color.

The Watch app writes the selected host's latest timer sample to ``RiValT_ComplicationState`` in the app group. ``Rift_Valley_Timer_Watch_App_Provider`` builds a WidgetKit timeline from that sample. Entries mark phase transitions, the displayed deadline, and the point when an unconfirmed countdown should return to its preset duration. WidgetKit updates the time between entries.

Changing the selected device clears the previous host's sample. A disconnected host can fall back to its ready duration until a newer sample confirms the live countdown. The Watch app and complication share the timing model so the displayed state follows the same countdown rules.

## Topics

### Widget timeline and display

- ``RiValT_Complications``
- ``Rift_Valley_Timer_Watch_App_Provider``
- ``Rift_Valley_Timer_Watch_App_Entry``
- ``Rift_Valley_Timer_ComplicationsEntryView``

### Shared timer data

- ``RiValT_ComplicationState``
- ``RiValT_RemoteState``
