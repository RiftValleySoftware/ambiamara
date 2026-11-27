# Timer model and countdowns

Trace a timer preset from the editor to the running display.

## Overview

``TimerModel`` organizes the timers into ordered ``TimerGroup`` values and tracks the current selection. The group editor manages group order, display style, and alarm behavior. The timer editor sets each preset's starting duration and warning and final thresholds. The **Start in Warning** and **Start in Final** shortcuts adjust those thresholds to enter the chosen phase at the beginning of the countdown.

Each timer wraps a ``TimerEngine``. The engine keeps the remaining time and the phase for that preset. The running screen reads the engine for display and coordinates the transition to the next timer in the group.

## Combined countdowns

With **Combine Timers** enabled, ``TimerCountdown`` supplies the running display and slider with a timeline for the group. The displayed time adds the active timer's remaining seconds to the configured durations of later timers. The active timer still supplies its own warning and final phases.

For example, a 30-second timer followed by a 45-second timer starts with 75 seconds on the combined display. At 30 seconds elapsed, the timeline position is the second timer with 45 seconds remaining. Zero-duration presets are omitted from this timeline.

The **TimerEngineTests** scheme covers engine transitions. **TimerModelTests** covers group operations, combined timer behavior, and the serialized timer model.
