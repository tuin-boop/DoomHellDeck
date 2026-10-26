Hellatro card backs
==================
Edit catalogue.json to add artwork later. Each entry needs a unique id, name,
texture (res:// path to your PNG), tint, accent, unlock, and description.
Use white tint (ffffff) to keep original artwork colours.
Unlock values: default, win, score (1000 match points), families (5 in one match), rest (5 draw/pass turns), extensions (10 extensions).
All backs are cosmetic. The existing variants reuse the original art with
colour and border treatments until replacement artwork is supplied.
Godot imports new PNGs when the project opens. Re-export the EXE afterwards.
