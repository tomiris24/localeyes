# Design files

Twenty-four artboards that match the Flutter app one to one. They are plain
SVG, so Figma imports them as editable layers — frames, text, shapes and image
fills, not flat pictures.

| File | Frame | What it is |
| --- | --- | --- |
| `figma/00-ui-kit.svg` | 760 × 1040 | Colours, type scale and components |
| `figma/01-explore.svg` | 390 × 844 | Tour discovery feed |
| `figma/02-tour-detail.svg` | 390 × 844 | Tour detail with the sticky bar |
| `figma/03-profile.svg` | 390 × 844 | Traveller profile |

### Meet a local — every state of every feature

Each feature gets one frame per state, because a state is what actually has to
be drawn: the empty list, the validation error, the confirmation. All of them
follow `lib/screens/`.

| Feature | Frames |
| --- | --- |
| Locals feed | `04a-locals-default` · `04b-locals-filtered` · `04c-locals-search` · `04d-locals-empty` |
| Local profile | `05a-profile-top` · `05b-profile-hangouts` · `05c-profile-places` · `05d-profile-pending` |
| Meetup request | `06a-request-empty` · `06b-request-error` · `06c-request-filled` · `06d-request-sent` |
| Spots | `07a-spots-all` · `07b-spots-filtered` · `07c-spots-empty` |
| Become a local | `08a-become-about` · `08b-become-interests` · `08c-become-money` · `08d-become-errors` · `08e-become-done` |

Letters are the reading order inside one feature, so dropping a whole group on
the canvas already lays the flow out left to right.

## How to open them in Figma

1. Open a new Figma file.
2. Drag the `.svg` files from `design/figma/` straight onto the canvas, or
   use **File → Import**. Dropping one feature's group at a time keeps the
   flow readable.
3. Each file lands as its own frame, named after the screen and its state
   (`04 Locals — filtered`). Place a feature's states side by side.
4. Set the text font to **Inter** if Figma asks — the files use Inter first and
   fall back to the system font.

Everything stays editable: text is real text, chips and cards are rounded
rectangles, the cover photos come in as image fills, and the gradients are real
gradients.

## Keeping design and code in sync

Colours, spacing and the type scale come from `lib/core/app_theme.dart`. If you
change a token there, change it in `00-ui-kit.svg` too, so the design file and
the app never drift apart.

The `04*`–`08*` frames are generated, so a token change does not have to be
repeated twenty times by hand:

```bash
python3 design/generate_frames.py
```

The palette sits at the top of `design/generate_svg.py` — edit it there and
re-run, and every frame picks the new value up.

Screen sizes follow the app: 390 × 844 is the iPhone 14 frame the app was
tested on, and the layout switches to two columns above 840 px.
