# blaseball-scorecard

A ruby script that draws a scorecard for a game of Blaseball (http://blaseball.com).

Thanks to SIBR for hosting the data.

## Outstanding Questions

Chronicler::GameEvent has a `terminology` field. What is that for? 

Chronicler is more-raw data, captured straight from the live feed. Dealing with it will require
parsing strings and generating events by hand.

The Datablase is an event-parsed version of the Chronicler data. It is generally gathered into a
series of events, plus all pitches that led up to that event. Possibly, it will be easier to parse
the many typed data fields than to recreate them ourselves.
