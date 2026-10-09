# Design files

Four artboards that match the Flutter app one to one. They are plain SVG, so
Figma imports them as editable layers — frames, text, shapes and image fills,
not flat pictures.

| File | Frame | What it is |
| --- | --- | --- |
| `figma/00-ui-kit.svg` | 760 × 1040 | Colours, type scale and components |
| `figma/01-explore.svg` | 390 × 844 | Discovery feed |
| `figma/02-tour-detail.svg` | 390 × 844 | Tour detail with the sticky bar |
| `figma/03-profile.svg` | 390 × 844 | Traveller profile |

## How to open them in Figma

1. Open a new Figma file.
2. Drag all four `.svg` files from `design/figma/` straight onto the canvas,
   or use **File → Import**.
3. Each file lands as its own frame. Rename them if you like and place them
   side by side.
4. Set the text font to **Inter** if Figma asks — the files use Inter first and
   fall back to the system font.

Everything stays editable: text is real text, chips and cards are rounded
rectangles, the cover photos come in as image fills, and the gradients are real
gradients.

## Keeping design and code in sync

Colours, spacing and the type scale come from `lib/core/app_theme.dart`. If you
change a token there, change it in `00-ui-kit.svg` too, so the design file and
the app never drift apart.

Screen sizes follow the app: 390 × 844 is the iPhone 14 frame the app was
tested on, and the layout switches to two columns above 840 px.
