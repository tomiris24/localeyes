# -*- coding: utf-8 -*-
"""Generates the Figma artboards for the five "meet a local" screens.

Same contract as the artboards from Milestone 1: a 390x844 frame, real text,
rounded rectangles, inline icon paths, and <g id> groups that land in Figma
as named layers.
"""
import html, os

W, H = 390, 844
FONT = "Inter, SF Pro Text, Helvetica, Arial, sans-serif"

BRAND = "#193151"
DEEP = "#112137"
SOFT = "#9EBDE2"
INK = "#141F2F"
MUTED = "#687586"
CANVAS = "#F5F8FD"
LINE = "#E2EBF6"
SUCCESS = "#17A673"
WHITE = "#FFFFFF"

# 24px-grid icon paths, drawn with the same scale trick as the M1 artboards.
ICON = {
    "search": ("M15.5 14h-.79l-.28-.27a6.5 6.5 0 1 0-.7.7l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0a4.5 4.5 0 1 1 0-9 4.5 4.5 0 0 1 0 9z", "fill"),
    "place": ("M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7zm0 9.5A2.5 2.5 0 1 1 12 6.5a2.5 2.5 0 0 1 0 5z", "fill"),
    "heart": ("M12 21.35l-1.45-1.32C5.4 15.36 2 12.28 2 8.5 2 5.42 4.42 3 7.5 3c1.74 0 3.41.81 4.5 2.09C13.09 3.81 14.76 3 16.5 3 19.58 3 22 5.42 22 8.5c0 3.78-3.4 6.86-8.55 11.54L12 21.35z", "fill"),
    "spark": ("M12 2l2.2 5.8L20 10l-5.8 2.2L12 18l-2.2-5.8L4 10l5.8-2.2z", "fill"),
    "shield": ("M12 2l8 3v6c0 5-3.4 9.4-8 11-4.6-1.6-8-6-8-11V5l8-3z", "fill"),
    "bookmark": ("M6 2h12v20l-6-4-6 4z", "fill"),
    "arrow": ("M5 12h14M13 6l6 6-6 6", "stroke"),
    "back": ("M19 12H5M11 18l-6-6 6-6", "stroke"),
    "check": ("M20 6L9 17l-5-5", "stroke"),
    "send": ("M2 21l21-9L2 3v7l15 2-15 2z", "fill"),
    "clock": ("M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM12 7v5l3.5 2", "stroke"),
    "cup": ("M4 8h12v6a5 5 0 0 1-5 5H9a5 5 0 0 1-5-5zM16 9h2a3 3 0 0 1 0 6h-2", "stroke"),
    "walk": ("M13 5a2 2 0 1 0 0-4 2 2 0 0 0 0 4zM11 21l2-6-3-3 1-5 4 3 3 1M9 21l2-5", "stroke"),
    "camera": ("M4 8h3l2-2h6l2 2h3v11H4zM12 16a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7z", "stroke"),
    "globe": ("M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM3 12h18M12 3c2.5 2.5 2.5 15 0 18M12 3C9.5 5.5 9.5 18.5 12 21", "stroke"),
    "money": ("M3 7h18v10H3zM12 15a3 3 0 1 0 0-6 3 3 0 0 0 0 6z", "stroke"),
    "people": ("M9 11a3.5 3.5 0 1 0 0-7 3.5 3.5 0 0 0 0 7zM2 20a7 7 0 0 1 14 0M17 11a3 3 0 1 0 0-6M17 14a5 5 0 0 1 5 6", "stroke"),
    "compass": ("M12 3a9 9 0 1 0 0 18 9 9 0 0 0 0-18zM15.5 8.5l-2 5-5 2 2-5z", "stroke"),
    "person": ("M12 12a4 4 0 1 0 0-8 4 4 0 0 0 0 8zM4 21a8 8 0 0 1 16 0", "stroke"),
    "wave": ("M7 11V6.5a1.5 1.5 0 0 1 3 0V11M10 11V5a1.5 1.5 0 0 1 3 0v6M13 11V6.5a1.5 1.5 0 0 1 3 0V13c0 4-2.5 7-6 7s-6-3-6-6v-2a1.5 1.5 0 0 1 3 0", "stroke"),
    "pin": ("M12 2C8.7 2 6 4.7 6 8c0 4.5 6 13 6 13s6-8.5 6-13c0-3.3-2.7-6-6-6zM12 10.5A2.5 2.5 0 1 1 12 5.5a2.5 2.5 0 0 1 0 5z", "fill"),
    "tag": ("M3 12V4h8l9 9-8 8z M7.5 8.5h.01", "stroke"),
    "note": ("M5 4h14v16H5zM8 9h8M8 13h8M8 17h5", "stroke"),
}


def esc(s):
    return html.escape(s, quote=False)


def t(x, y, s, size=13.5, weight=400, fill=INK, anchor=None, extra=""):
    a = f' text-anchor="{anchor}"' if anchor else ""
    return (f'<text x="{x}" y="{y}" font-family="{FONT}" font-size="{size}" '
            f'font-weight="{weight}" fill="{fill}"{a}{extra} id="{esc(s)[:40]}">{esc(s)}</text>')


def rect(x, y, w, h, rx=0, fill=WHITE, stroke=None, sw=1, opacity=None, idn=None):
    s = f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}"'
    if opacity is not None:
        s += f' fill-opacity="{opacity}"'
    if stroke:
        s += f' stroke="{stroke}" stroke-width="{sw}"'
    if idn:
        s += f' id="{esc(idn)}"'
    return s + "/>"


def icon(name, x, y, size=18, color=MUTED, sw=2):
    """Places a 24px icon so that its top-left corner sits at (x, y)."""
    d, mode = ICON[name]
    k = size / 24.0
    if mode == "fill":
        return (f'<path d="{d}" transform="translate({x},{y}) scale({k:.4f})" '
                f'fill="{color}"/>')
    return (f'<path d="{d}" transform="translate({x},{y}) scale({k:.4f})" fill="none" '
            f'stroke="{color}" stroke-width="{sw}" stroke-linecap="round" '
            f'stroke-linejoin="round"/>')


def chip(x, y, label, selected=False, h=32, size=13, pad=14):
    """A pill chip. Returns (svg, width) so a row can be laid out left to right."""
    w = int(len(label) * size * 0.56) + pad * 2
    fill = BRAND if selected else WHITE
    stroke = BRAND if selected else LINE
    color = WHITE if selected else INK
    svg = rect(x, y, w, h, h // 2, fill, stroke)
    svg += t(x + pad, y + h / 2 + 4.5, label, size, 600, color)
    return svg, w


def chip_row(x, y, items, h=32, size=13, gap=8, limit=W - 16):
    """Lays chips out in a row and clips whatever runs past the frame edge."""
    out, cx = "", x
    for label, sel in items:
        if cx > limit:
            break
        s, w = chip(cx, y, label, sel, h, size)
        out += s
        cx += w + gap
    return out


def avatar(cx, cy, r, initials, verified=True, gid=1):
    s = f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="url(#av{gid})"/>'
    s += t(cx, cy + r * 0.36 * 0.95, initials, r * 0.72, 700, WHITE, anchor="middle")
    if verified:
        bx, by = cx + r * 0.7, cy + r * 0.7
        s += f'<circle cx="{bx}" cy="{by}" r="{r * 0.34 + 2}" fill="{WHITE}"/>'
        s += f'<circle cx="{bx}" cy="{by}" r="{r * 0.34}" fill="{SUCCESS}"/>'
        s += icon("check", bx - r * 0.24, by - r * 0.24, r * 0.48, WHITE, 3.5)
    return s


def card(x, y, w, h, fill=WHITE, stroke=LINE, rx=20):
    return rect(x, y, w, h, rx, fill, stroke)


def status_bar():
    return (
        '<g id="Status bar">'
        + t(26, 24, "16:18", 15, 600, INK)
        + rect(140, 4, 110, 30, 15, "#000000")
        + rect(336, 13, 22, 11, 3, INK)
        + rect(359, 16, 2, 5, 1, INK)
        + f'<path d="M312 22 a 10 10 0 0 1 14 0" fill="none" stroke="{INK}" stroke-width="2.2" stroke-linecap="round"/>'
        + f'<circle cx="319" cy="25" r="1.8" fill="{INK}"/>'
        + "</g>"
    )


def bottom_nav(active=0):
    tabs = [("people", "Locals"), ("compass", "Explore"),
            ("bookmark", "Saved"), ("person", "Profile")]
    s = f'<g id="Bottom navigation">' + rect(0, 776, W, 68, 0, WHITE)
    s += f'<line x1="0" y1="776" x2="{W}" y2="776" stroke="{LINE}" stroke-width="1"/>'
    for i, (ic, label) in enumerate(tabs):
        cx = W / 8 * (i * 2 + 1)
        color = BRAND if i == active else MUTED
        s += icon(ic, cx - 11, 792, 22, color, 1.9)
        s += t(cx, 831, label, 12, 700 if i == active else 500, color, anchor="middle")
    return s + "</g>"


def app_bar(title, action=None):
    s = f'<g id="App bar">' + t(16, 86, title, 19, 700, INK)
    if action:
        s += icon(action, 348, 70, 22, INK, 1.9)
    return s + "</g>"


def back_bar(title):
    s = f'<g id="App bar">' + icon("back", 16, 70, 22, INK, 2)
    s += t(50, 86, title, 19, 700, INK)
    return s + "</g>"


def defs():
    return (
        "<defs>"
        f'<linearGradient id="av1" x1="0" y1="0" x2="1" y2="1">'
        f'<stop offset="0" stop-color="{BRAND}"/><stop offset="1" stop-color="{DEEP}"/>'
        "</linearGradient>"
        "</defs>"
    )


def frame(idn, body):
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{W}" height="{H}" '
            f'viewBox="0 0 {W} {H}" id="{idn}">\n  ' + defs() + "\n  "
            + rect(0, 0, W, H, 0, CANVAS, idn="Background") + "\n  "
            + status_bar() + "\n  " + body + "\n</svg>\n")


def pill_availability(x, y, label, soon=True, w=96):
    s = rect(x, y, w, 23, 11.5, SUCCESS if soon else WHITE,
             None if soon else LINE, opacity=0.12 if soon else None)
    color = SUCCESS if soon else MUTED
    s += f'<circle cx="{x + 12}" cy="{y + 11.5}" r="3" fill="{color}"/>'
    s += t(x + 21, y + 16, label, 12, 700, color)
    return s


def mini_tag(x, y, label, ic=None, size=11.5):
    w = int(len(label) * size * 0.55) + (26 if ic else 18)
    s = rect(x, y, w, 22, 11, CANVAS)
    if ic:
        s += icon(ic, x + 8, y + 5, 12, MUTED, 1.8)
    s += t(x + (24 if ic else 9), y + 15, label, size, 600, DEEP)
    return s, w


# ----------------------------------------------------------------- screens

def screen_locals():
    b = app_bar("Meet a local", "wave")
    b += '<g id="Intro">' + t(16, 110, "2 people are free today in Almaty.", 13.5, 400, MUTED) + "</g>"

    b += '<g id="Search">'
    b += rect(16, 124, 358, 48, 24, WHITE, LINE)
    b += icon("search", 32, 139, 20, MUTED)
    b += t(62, 154, "Coffee, mountains, a name…", 14, 400, MUTED)
    b += "</g>"

    b += '<g id="Availability filter">'
    b += chip_row(16, 186, [("Anyone", False), ("Today", True),
                            ("Tomorrow", False), ("Weekend", False)])
    b += "</g>"

    b += '<g id="Interest filter">'
    b += chip_row(16, 228, [("Any interest", False), ("Coffee", False),
                            ("Mountains", False), ("Photo", False)])
    b += "</g>"

    b += '<g id="Spots banner">'
    b += rect(16, 276, 358, 72, 20, BRAND)
    b += icon("pin", 34, 300, 26, SOFT)
    b += t(74, 306, "The city through their eyes", 15.5, 700, WHITE)
    b += t(74, 326, "Places locals added themselves, and why", 12.5, 400, SOFT)
    b += icon("arrow", 338, 302, 20, WHITE, 2)
    b += "</g>"

    # --- first card
    b += '<g id="Local card — Aizhan">'
    b += card(16, 362, 358, 202)
    b += avatar(58, 404, 26, "AK")
    b += t(96, 398, "Aizhan K., 27", 16, 600, INK)
    b += icon("place", 95, 406, 13, MUTED)
    b += t(112, 417, "Medeu", 12, 400, MUTED)
    b += pill_availability(96, 428, "Free today")
    b += icon("heart", 338, 378, 20, MUTED)
    b += t(32, 476, "Barista. I can tell you which of the forty new", 13.5, 400, MUTED)
    b += t(32, 494, "coffee places is actually worth your morning.", 13.5, 400, MUTED)
    s1, w1 = mini_tag(32, 506, "Coffee and a chat", "cup")
    b += s1
    s2, _ = mini_tag(32 + w1 + 8, 506, "EN · B2", "globe")
    b += s2
    b += f'<line x1="32" y1="540" x2="358" y2="540" stroke="{LINE}" stroke-width="1"/>'
    b += icon("spark", 32, 550, 15, BRAND)
    b += t(52, 562, "You both like coffee and photography", 12.5, 600, BRAND)
    b += t(358, 562, "Buy me a coffee", 13.5, 600, INK, anchor="end")
    b += "</g>"

    # --- second card
    b += '<g id="Local card — Aruzhan">'
    b += card(16, 576, 358, 184)
    b += avatar(58, 618, 26, "AT")
    b += t(96, 612, "Aruzhan T., 22", 16, 600, INK)
    b += icon("place", 95, 620, 13, MUTED)
    b += t(112, 631, "Auezov", 12, 400, MUTED)
    b += pill_availability(96, 642, "Free today")
    b += icon("heart", 338, 592, 20, MUTED)
    b += t(32, 690, "Design student. I want to practise my English", 13.5, 400, MUTED)
    b += t(32, 708, "and I will show you the murals nobody shows.", 13.5, 400, MUTED)
    s3, w3 = mini_tag(32, 720, "Language exchange", "globe")
    b += s3
    b += f'<line x1="32" y1="752" x2="358" y2="752" stroke="{LINE}" stroke-width="1"/>'
    b += "</g>"

    b += bottom_nav(0)
    return frame("04 Locals", b)


def screen_profile():
    b = back_bar("Aizhan K.")
    b += icon("heart", 348, 70, 22, BRAND)

    b += '<g id="Header card">'
    b += card(16, 108, 358, 206)
    b += avatar(66, 158, 32, "AK")
    b += t(114, 152, "Aizhan K., 27", 22, 700, INK)
    b += t(114, 172, "Lives in Medeu", 12, 400, MUTED)
    b += pill_availability(114, 182, "Free today")
    b += t(32, 232, "Barista. I can tell you which of the forty new coffee", 13.5, 400, MUTED)
    b += t(32, 250, "places is actually worth your morning.", 13.5, 400, MUTED)
    b += f'<line x1="32" y1="264" x2="358" y2="264" stroke="{LINE}" stroke-width="1"/>'
    for i, (val, lab) in enumerate([("31", "people met"), ("4.9", "out of 5"),
                                    ("March 2025", "here since")]):
        x = 32 + i * 112
        b += t(x, 286, val, 15.5, 700, INK)
        b += t(x, 300, lab, 11.5, 400, MUTED)
    b += "</g>"

    b += '<g id="Bio">'
    b += t(16, 342, "I grew up two streets from Gorky Park and I pull", 15, 400, INK)
    b += t(16, 362, "espresso for a living, so I spend my days listening", 15, 400, INK)
    b += t(16, 382, "to people talk about this city.", 15, 400, INK)
    b += "</g>"

    b += '<g id="Languages">'
    b += t(16, 418, "Languages", 19, 700, INK)
    b += chip_row(16, 432, [("Kazakh · Native", False), ("Russian · Native", False)], h=30)
    b += chip_row(16, 470, [("English · B2", False)], h=30)
    b += "</g>"

    b += '<g id="What we could do">'
    b += t(16, 528, "What we could do", 19, 700, INK)
    b += t(16, 546, "Their suggestions, not a fixed route", 12, 400, MUTED)
    for i, (ic, title, note) in enumerate([
        ("cup", "Coffee and a chat", "Three places in one morning, all walkable."),
        ("walk", "Walk around my neighbourhood", "The courtyards behind Panfilov."),
    ]):
        y = 566 + i * 56
        b += f'<circle cx="35" cy="{y + 19}" r="19" fill="{CANVAS}"/>'
        b += icon(ic, 25, y + 9, 20, BRAND, 1.9)
        b += t(66, y + 15, title, 13.5, 600, INK)
        b += t(66, y + 32, note, 12, 400, MUTED)
    b += "</g>"

    b += '<g id="Cost card">'
    b += rect(16, 686, 358, 66, 20, SOFT, opacity=0.35)
    b += icon("money", 34, 704, 20, DEEP, 1.9)
    b += t(66, 712, "Buy me a coffee", 16, 600, DEEP)
    b += t(66, 732, "No fee. Get the coffee and we are even.", 12, 400, DEEP)
    b += "</g>"

    b += '<g id="Say hi bar">'
    b += rect(0, 764, W, 80, 0, WHITE)
    b += f'<line x1="0" y1="764" x2="{W}" y2="764" stroke="{LINE}" stroke-width="1"/>'
    b += t(16, 796, "Buy me a coffee", 16, 600, INK)
    b += t(16, 814, "Free today", 12, 400, MUTED)
    b += rect(176, 778, 198, 52, 26, BRAND)
    b += icon("wave", 206, 793, 20, WHITE, 2)
    b += t(234, 810, "Say hi", 15.5, 700, WHITE)
    b += "</g>"
    return frame("05 Local profile", b)


def screen_request():
    b = back_bar("Meet Aizhan")
    b += '<g id="Intro">'
    b += t(16, 118, "Aizhan K. is free today and usually replies", 13.5, 400, MUTED)
    b += t(16, 136, "within an hour.", 13.5, 400, MUTED)
    b += "</g>"

    b += '<g id="When">'
    b += t(16, 172, "When", 19, 700, INK)
    b += chip_row(16, 186, [("Today", True), ("Tomorrow", False), ("Sat 25 Oct", False)])
    b += rect(16, 230, 358, 44, 12, WHITE, LINE)
    for i, label in enumerate(["Morning", "Afternoon", "Evening"]):
        x = 16 + i * 119.33
        sel = i == 2
        if sel:
            b += rect(x, 230, 119.33, 44, 12, BRAND)
        b += t(x + 59.6, 258, label, 13.5, 600, WHITE if sel else INK, anchor="middle")
    b += "</g>"

    b += '<g id="What you fancy">'
    b += t(16, 312, "What you fancy", 19, 700, INK)
    b += t(16, 330, "Pick one of their ideas — it can change on the day", 12, 400, MUTED)
    b += rect(16, 344, 358, 60, 20, SOFT, BRAND, 1.5, opacity=0.35)
    b += icon("cup", 32, 364, 20, BRAND, 1.9)
    b += t(64, 372, "Coffee and a chat", 13.5, 600, INK)
    b += t(64, 390, "Three places in one morning, all walkable.", 12, 400, MUTED)
    b += icon("check", 338, 366, 18, BRAND, 2.4)
    b += rect(16, 412, 358, 60, 20, WHITE, LINE)
    b += icon("walk", 32, 432, 20, MUTED, 1.9)
    b += t(64, 440, "Walk around my neighbourhood", 13.5, 600, INK)
    b += t(64, 458, "The courtyards behind Panfilov.", 12, 400, MUTED)
    b += "</g>"

    b += '<g id="Where">'
    b += t(16, 510, "Where you meet first", 19, 700, INK)
    b += t(16, 528, "Public places only, for a first meetup", 12, 400, MUTED)
    b += rect(16, 542, 358, 52, 20, WHITE, LINE)
    b += t(34, 574, "Green Bazaar main entrance", 14, 400, INK)
    b += f'<path d="M346 566 l6 7 6-7" fill="none" stroke="{MUTED}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
    b += "</g>"

    b += '<g id="Message">'
    b += t(16, 634, "Say something", 19, 700, INK)
    b += rect(16, 648, 358, 92, 20, WHITE, LINE)
    b += t(34, 676, "Who you are, how long you are in town,", 14, 400, MUTED)
    b += t(34, 696, "what you are curious about…", 14, 400, MUTED)
    b += "</g>"

    b += '<g id="Tell a friend">'
    b += rect(16, 756, 22, 22, 6, BRAND)
    b += icon("check", 20, 760, 14, WHITE, 3)
    b += t(48, 772, "Send my plan to a friend", 14, 600, INK)
    b += "</g>"

    b += '<g id="Send">'
    b += rect(16, 790, 358, 52, 26, BRAND)
    b += icon("send", 142, 805, 20, WHITE)
    b += t(172, 822, "Send the request", 15.5, 700, WHITE)
    b += "</g>"
    return frame("06 Meetup request", b)


def screen_spots():
    b = back_bar("Through their eyes")
    b += '<g id="Intro">'
    b += t(16, 118, "Places nobody puts on a tour, added by the", 13.5, 400, MUTED)
    b += t(16, 136, "people who go there anyway.", 13.5, 400, MUTED)
    b += "</g>"

    b += '<g id="Area filter">'
    b += chip_row(16, 158, [("All areas", True), ("Medeu", False),
                            ("Almaly", False), ("Bostandyk", False)])
    b += "</g>"

    spots = [
        ("Green Bazaar, upstairs", "184", "Almaly", "Bazaar", "Before 10am",
         ["Everyone photographs the ground floor. Upstairs is",
          "where the dried fruit sellers are, and they make you",
          "taste nine things before you buy one."], "Gulnara S."),
        ("The dam steps at Medeu", "206", "Medeu", "Viewpoint", "Dusk",
         ["842 steps. Everybody counts them and everybody",
          "gets a different number. Go up when the rink lights",
          "come on."], "Timur B."),
    ]
    for i, (name, saves, area, kind, best, quote, who) in enumerate(spots):
        y = 212 + i * 238
        b += f'<g id="Spot — {esc(name)}">'
        b += card(16, y, 358, 222)
        b += t(32, y + 32, name, 16, 600, INK)
        b += icon("heart", 318, y + 18, 14, MUTED)
        b += t(358, y + 31, saves, 12, 400, MUTED, anchor="end")
        mx = 32
        for ic, label in [("place", area), ("tag", kind), ("clock", best)]:
            b += icon(ic, mx, y + 42, 13, MUTED, 1.8)
            b += t(mx + 18, y + 53, label, 12, 400, MUTED)
            mx += 18 + int(len(label) * 6.1) + 14
        b += rect(32, y + 70, 3, 72, 1.5, SOFT)
        for j, ln in enumerate(quote):
            b += t(48, y + 88 + j * 21, ln, 14, 400, INK)
        b += icon("person", 32, y + 184, 14, MUTED, 1.9)
        b += t(52, y + 196, f"Added by {who}", 12.5, 600, BRAND)
        b += "</g>"

    b += '<g id="Back button">'
    b += rect(16, 700, 110, 48, 24, CANVAS, LINE)
    b += icon("back", 36, 712, 19, BRAND, 2)
    b += t(64, 730, "Back", 14.5, 600, BRAND)
    b += "</g>"
    return frame("07 Spots", b)


def screen_become():
    b = back_bar("Become a local")

    b += '<g id="Promise">'
    b += rect(16, 108, 358, 86, 20, SOFT, opacity=0.35)
    b += t(32, 134, "You do not need a licence, a route or any", 13.5, 400, DEEP)
    b += t(32, 152, "experience. If you like this city and you like", 13.5, 400, DEEP)
    b += t(32, 170, "talking to people, that is the requirement.", 13.5, 400, DEEP)
    b += "</g>"

    b += '<g id="About you">'
    b += t(16, 226, "About you", 19, 700, INK)
    b += t(16, 250, "Name", 13, 600, INK)
    b += rect(16, 258, 358, 50, 20, WHITE, LINE)
    b += t(34, 288, "Aizhan K.", 14, 400, INK)
    b += t(16, 332, "Age", 13, 600, INK)
    b += rect(16, 340, 104, 50, 20, WHITE, LINE)
    b += t(34, 370, "27", 14, 400, INK)
    b += t(132, 332, "Your area", 13, 600, INK)
    b += rect(132, 340, 242, 50, 20, WHITE, LINE)
    b += t(150, 370, "Medeu", 14, 400, INK)
    b += f'<path d="M346 362 l6 7 6-7" fill="none" stroke="{MUTED}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
    b += "</g>"

    b += '<g id="Languages">'
    b += t(16, 428, "Languages", 19, 700, INK)
    b += t(16, 446, "Be honest about the level — it is the whole point", 12, 400, MUTED)
    b += chip_row(16, 460, [("Kazakh", True), ("Russian", True), ("English", True)], h=30)
    b += t(16, 518, "English", 13.5, 600, INK)
    b += rect(246, 500, 128, 38, 12, WHITE, LINE)
    b += t(262, 524, "B2", 13.5, 400, INK)
    b += f'<path d="M348 516 l5 6 5-6" fill="none" stroke="{MUTED}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
    b += "</g>"

    b += '<g id="What you are into">'
    b += t(16, 580, "What you are into", 19, 700, INK)
    b += chip_row(16, 594, [("Coffee", True), ("Street art", True), ("Books", False)], h=30)
    b += "</g>"

    b += '<g id="What you would do">'
    b += t(16, 664, "What you would happily do", 19, 700, INK)
    for i, (ic, label, on) in enumerate([
            ("cup", "Coffee and a chat", True),
            ("walk", "Walk around my neighbourhood", False)]):
        y = 682 + i * 38
        b += rect(16, y, 20, 20, 5, BRAND if on else WHITE, None if on else LINE, 1.5)
        if on:
            b += icon("check", 19, y + 3, 14, WHITE, 3)
        b += icon(ic, 46, y + 1, 18, BRAND if on else MUTED, 1.9)
        b += t(74, y + 15, label, 14, 600, INK)
    b += "</g>"

    b += '<g id="Money">'
    b += t(16, 782, "Money", 19, 700, INK)
    b += rect(16, 794, 358, 40, 12, WHITE, LINE)
    for i, label in enumerate(["Free", "Coffee", "Hourly"]):
        x = 16 + i * 119.33
        sel = i == 1
        if sel:
            b += rect(x, 794, 119.33, 40, 12, BRAND)
        b += t(x + 59.6, 820, label, 13.5, 600, WHITE if sel else INK, anchor="middle")
    b += "</g>"
    return frame("08 Become a local", b)


if __name__ == "__main__":
    out = os.path.join(os.path.dirname(os.path.abspath(__file__)))
    files = {
        "04-locals.svg": screen_locals(),
        "05-local-profile.svg": screen_profile(),
        "06-meetup-request.svg": screen_request(),
        "07-spots.svg": screen_spots(),
        "08-become-local.svg": screen_become(),
    }
    target = os.path.join(os.path.dirname(os.path.abspath(__file__)), "figma")
    for name, body in files.items():
        with open(os.path.join(target, name), "w", encoding="utf-8") as f:
            f.write(body)
        print(name, len(body), "bytes")
