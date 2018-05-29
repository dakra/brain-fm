# brain-fm - Play music from brain.fm

*Author:* Daniel Kraus <daniel@kraus.my><br>
*Version:* 0.1<br>
*URL:* [https://github.com/dakra/brain-fm](https://github.com/dakra/brain-fm)<br>

Play music from brain.fm (https://brain.fm/)
This library needs a playback function that can stream music from URLs.
If you have `mpv` installed and use `emms` you can require emms-player-mpv
to add `mpv` as an external player capable of streaming.
Otherwise set `brain-fm-play-url` to whatever player you prefer.

You have to set `brain-fm-email` and `brain-fm-password` to your
brain-fm credentials either by setting those variables directly
or by adding a line like the following to your `.authinfo` / `.authinfo.gpg`
"machine brain.fm login brainfm@example.com password brainfm-pass"


---
Converted from `brain-fm.el` by [*el2markdown*](https://github.com/Lindydancer/el2markdown).
