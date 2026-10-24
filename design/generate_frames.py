# -*- coding: utf-8 -*-
"""Detailed Figma frames: every state of every new feature.

One SVG per state, because a state is what a designer actually has to draw —
the empty list, the validation error, the confirmation. All of them follow the
Flutter code in lib/screens/.
"""
import os, sys
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from generate_svg import *  # noqa: F403

ERROR = "#B3261E"
TARGET = os.path.join(os.path.dirname(os.path.abspath(__file__)), "figma")


# ------------------------------------------------------------------ helpers

def empty_state(y, ic, title, lines, action):
    s = f'<g id="Empty state">'
    s += f'<circle cx="195" cy="{y + 38}" r="38" fill="{SOFT}"/>'
    s += icon(ic, 178, y + 21, 34, BRAND, 2)
    s += t(195, y + 110, title, 19, 700, INK, anchor="middle")
    for i, ln in enumerate(lines):
        s += t(195, y + 136 + i * 20, ln, 13.5, 400, MUTED, anchor="middle")
    bw = int(len(action) * 8.2) + 56
    s += rect(195 - bw / 2, y + 180, bw, 48, 24, CANVAS, LINE)
    s += t(195, y + 210, action, 14.5, 600, BRAND, anchor="middle")
    return s + "</g>"


def error_line(x, y, msg):
    s = f'<circle cx="{x + 7}" cy="{y - 4}" r="7" fill="none" stroke="{ERROR}" stroke-width="1.6"/>'
    s += t(x + 5.6, y, "!", 10, 700, ERROR)
    s += t(x + 20, y, msg, 12.5, 400, ERROR)
    return s


def snackbar(y, msg_lines):
    s = f'<g id="Snackbar">'
    h = 34 + len(msg_lines) * 20
    s += rect(16, y, 358, h, 12, INK)
    for i, ln in enumerate(msg_lines):
        s += t(32, y + 30 + i * 20, ln, 14, 400, WHITE)
    return s + "</g>"


def scrim():
    return rect(0, 0, W, H, 0, "#000000", opacity=0.45, idn="Scrim")


def field(x, y, w, label, value, placeholder=False, error=None, h=50):
    s = t(x, y - 8, label, 13, 600, INK)
    s += rect(x, y, w, h, 20, WHITE, ERROR if error else LINE, 1.5 if error else 1)
    s += t(x + 18, y + h / 2 + 5, value, 14, 400, MUTED if placeholder else INK)
    if error:
        s += error_line(x + 2, y + h + 18, error)
    return s


def segmented(x, y, w, labels, selected, h=44):
    cw = w / len(labels)
    s = rect(x, y, w, h, 12, WHITE, LINE)
    for i, label in enumerate(labels):
        if i == selected:
            s += rect(x + i * cw, y, cw, h, 12, BRAND)
        s += t(x + i * cw + cw / 2, y + h / 2 + 5, label, 13.5, 600,
               WHITE if i == selected else INK, anchor="middle")
    return s


def local_card(y, initials, name, area, when, soon, lines, tags, match, cost):
    s = f'<g id="Local card — {esc(name)}">'
    s += card(16, y, 358, 216)
    s += avatar(58, y + 42, 26, initials)
    s += t(96, y + 36, name, 16, 600, INK)
    s += icon("place", 95, y + 44, 13, MUTED)
    s += t(112, y + 55, area, 12, 400, MUTED)
    s += pill_availability(96, y + 66, when, soon, 112 if not soon else 96)
    s += icon("heart", 338, y + 16, 20, MUTED)
    for i, ln in enumerate(lines):
        s += t(32, y + 114 + i * 18, ln, 13.5, 400, MUTED)
    tx = 32
    for label, ic in tags:
        sv, tw = mini_tag(tx, y + 144, label, ic)
        s += sv
        tx += tw + 8
    s += f'<line x1="32" y1="{y + 172}" x2="358" y2="{y + 172}" stroke="{LINE}" stroke-width="1"/>'
    s += icon("spark", 32, y + 184, 15, BRAND)
    s += t(52, y + 196, match, 12.5, 600, BRAND)
    s += t(358, y + 196, cost, 13.5, 600, INK, anchor="end")
    return s + "</g>"


AIZHAN = dict(initials="AK", name="Aizhan K., 27", area="Medeu", when="Free today",
              soon=True,
              lines=["Barista. I can tell you which of the forty new",
                     "coffee places is actually worth your morning."],
              tags=[("Coffee and a chat", "cup"), ("EN · B2", "globe")],
              match="You both like coffee and…",
              cost="Buy me a coffee")
ARUZHAN = dict(initials="AT", name="Aruzhan T., 22", area="Auezov", when="Free today",
               soon=True,
               lines=["Design student. I want to practise my English",
                      "and I will show you the murals nobody shows."],
               tags=[("Language exchange", "globe")],
               match="You both like coffee",
               cost="Free")
DIAS = dict(initials="DM", name="Dias M., 24", area="Bostandyk", when="Free tomorrow",
            soon=True,
            lines=["Engineering student who photographs the city",
                   "at night. Bring a jacket, we will be out late."],
            tags=[("Night out", "camera"), ("EN · C1", "globe")],
            match="You both like photography",
            cost="$8 / hour")


# ------------------------------------------------------------------ feature 1

def f_locals(state):
    note = {"default": "6 locals in Almaty, 2 of them free today.",
            "filtered": "Showing people free tomorrow.",
            "empty": "Showing people free tomorrow, into books.",
            "search": "1 person matches “coffee”."}[state]
    b = app_bar("Meet a local", "wave")
    b += '<g id="Intro">' + t(16, 110, note, 13.5, 400, MUTED) + "</g>"

    b += '<g id="Search">'
    focused = state == "search"
    b += rect(16, 124, 358, 48, 24, WHITE, BRAND if focused else LINE, 1.6 if focused else 1)
    b += icon("search", 32, 139, 20, BRAND if focused else MUTED)
    b += t(62, 154, "coffee" if focused else "Coffee, mountains, a name…", 14,
           400, INK if focused else MUTED)
    if focused:
        b += rect(104, 142, 1.5, 15, 0.7, BRAND)
    b += "</g>"

    sel = {"default": 0, "filtered": 2, "empty": 2, "search": 0}[state]
    b += '<g id="Availability filter">'
    b += chip_row(16, 186, [(l, i == sel) for i, l in
                            enumerate(["Anyone", "Today", "Tomorrow", "Weekend"])])
    b += "</g>"
    b += '<g id="Interest filter">'
    isel = 3 if state == "empty" else 0
    b += chip_row(16, 228, [(l, i == isel) for i, l in
                            enumerate(["Any interest", "Coffee", "Mountains", "Books"])])
    b += "</g>"

    b += '<g id="Spots banner">'
    b += rect(16, 276, 358, 72, 20, BRAND)
    b += icon("pin", 34, 300, 26, SOFT)
    b += t(74, 306, "The city through their eyes", 15.5, 700, WHITE)
    b += t(74, 326, "Places locals added themselves, and why", 12.5, 400, SOFT)
    b += icon("arrow", 338, 302, 20, WHITE, 2)
    b += "</g>"

    if state == "empty":
        b += empty_state(380, "search", "Nobody matches that yet",
                         ["Only six people are signed up in this demo.",
                          "Clear the filters to see all of them."],
                         "Clear filters")
    elif state == "filtered":
        b += local_card(362, **DIAS)
    elif state == "search":
        b += local_card(362, **AIZHAN)
    else:
        b += local_card(362, **AIZHAN)
        b += local_card(590, **ARUZHAN)

    if state == "search":
        b += '<g id="Keyboard">' + rect(0, 600, W, 244, 0, "#D4D8DF")
        for row, keys in enumerate(["QWERTYUIOP", "ASDFGHJKL", "ZXCVBNM"]):
            n = len(keys)
            kw, gap = 32, 4
            total = n * kw + (n - 1) * gap
            x0 = (W - total) / 2
            for i, ch in enumerate(keys):
                x = x0 + i * (kw + gap)
                b += rect(x, 624 + row * 52, kw, 44, 6, WHITE)
                b += t(x + kw / 2, 624 + row * 52 + 29, ch, 16, 400, INK, anchor="middle")
        b += rect(100, 780, 190, 44, 6, WHITE)
        b += "</g>"
    else:
        b += bottom_nav(0)
    return frame(f"04 Locals — {state}", b)


# ------------------------------------------------------------------ feature 2

def f_profile(section):
    saved = section in ("pending",)
    b = back_bar("Aizhan K.")
    b += icon("heart", 348, 70, 22, BRAND if saved else INK)

    if section in ("top", "pending"):
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
        b += '<g id="Response time">'
        b += icon("clock", 32, 322, 14, MUTED, 1.9)
        b += t(52, 334, "Usually replies within an hour", 12, 400, MUTED)
        b += "</g>"
        b += '<g id="Bio">'
        for i, ln in enumerate([
                "I grew up two streets from Gorky Park and I pull",
                "espresso for a living, so I spend my days listening",
                "to people talk about this city. I am not a guide and",
                "I do not have a route — we just walk and I answer",
                "whatever you are curious about."]):
            b += t(16, 376 + i * 22, ln, 15, 400, INK)
        b += "</g>"
        b += '<g id="Languages">'
        b += t(16, 520, "Languages", 19, 700, INK)
        b += chip_row(16, 534, [("Kazakh · Native", False), ("Russian · Native", False)], h=30)
        b += chip_row(16, 572, [("English · B2", False)], h=30)
        b += "</g>"
        b += '<g id="Into">'
        b += t(16, 644, "Into", 19, 700, INK)
        b += chip_row(16, 658, [("Coffee", True), ("Street art", False), ("Books", False)], h=30)
        b += "</g>"

    elif section == "hangouts":
        b += '<g id="What we could do">'
        b += t(16, 134, "What we could do", 19, 700, INK)
        b += t(16, 152, "Their suggestions, not a fixed route", 12, 400, MUTED)
        for i, (ic, title, note) in enumerate([
                ("cup", "Coffee and a chat",
                 "Three places in one morning, all within walking distance."),
                ("walk", "Walk around my neighbourhood",
                 "The courtyards behind Panfilov, where nobody takes tourists.")]):
            y = 172 + i * 62
            b += f'<circle cx="35" cy="{y + 19}" r="19" fill="{CANVAS}"/>'
            b += icon(ic, 25, y + 9, 20, BRAND, 1.9)
            b += t(66, y + 15, title, 13.5, 600, INK)
            b += t(66, y + 33, note, 12, 400, MUTED)
        b += "</g>"
        b += '<g id="Into">'
        b += t(16, 322, "Into", 19, 700, INK)
        b += t(16, 340, "Highlighted ones are also yours", 12, 400, MUTED)
        b += chip_row(16, 354, [("Coffee", True), ("Street art", False), ("Books", False)], h=30)
        b += chip_row(16, 392, [("Photography", True)], h=30)
        b += "</g>"
        b += '<g id="Cost card">'
        b += rect(16, 452, 358, 84, 20, SOFT, opacity=0.35)
        b += icon("money", 34, 472, 20, DEEP, 1.9)
        b += t(66, 480, "Buy me a coffee", 16, 600, DEEP)
        b += t(66, 502, "No fee. Get the coffee or the lunch and we are", 12, 400, DEEP)
        b += t(66, 518, "even.", 12, 400, DEEP)
        b += "</g>"
        b += '<g id="Safety card">'
        b += card(16, 556, 358, 100)
        b += icon("shield", 34, 576, 20, SUCCESS)
        b += t(66, 586, "First meetings are in public", 13.5, 600, INK)
        for i, ln in enumerate(["The app only offers public meeting points for a",
                                "first meetup, and you can share your plan with a",
                                "friend from the request screen."]):
            b += t(66, 608 + i * 16, ln, 12, 400, MUTED)
        b += "</g>"

    else:  # places
        b += '<g id="Their places">'
        b += t(16, 134, "Aizhan's places", 19, 700, INK)
        b += "</g>"
        for i, (name, saves, area, kind, best, quote) in enumerate([
                ("Green Bazaar, upstairs", "184", "Almaly", "Bazaar", "Before 10am",
                 ["Everyone photographs the ground floor. Upstairs",
                  "is where the dried fruit sellers are."]),
                ("The courtyard behind Panfilov", "63", "Almaly", "Courtyard", "Evening",
                 ["Old apartment blocks with apple trees in the",
                  "middle. Grandmothers will talk to you anyway."])]):
            y = 152 + i * 190
            b += f'<g id="Spot — {esc(name)}">'
            b += card(16, y, 358, 174)
            b += t(32, y + 32, name, 16, 600, INK)
            b += icon("heart", 318, y + 18, 14, MUTED)
            b += t(358, y + 31, saves, 12, 400, MUTED, anchor="end")
            mx = 32
            for ic, label in [("place", area), ("tag", kind), ("clock", best)]:
                b += icon(ic, mx, y + 42, 13, MUTED, 1.8)
                b += t(mx + 18, y + 53, label, 12, 400, MUTED)
                mx += 18 + int(len(label) * 6.1) + 14
            b += rect(32, y + 70, 3, 50, 1.5, SOFT)
            for j, ln in enumerate(quote):
                b += t(48, y + 88 + j * 21, ln, 14, 400, INK)
            b += icon("person", 32, y + 138, 14, MUTED, 1.9)
            b += t(52, y + 150, "Added by Aizhan K.", 12.5, 600, BRAND)
            b += "</g>"
        b += '<g id="Back button">'
        b += rect(16, 548, 180, 48, 24, CANVAS, LINE)
        b += icon("back", 36, 560, 19, BRAND, 2)
        b += t(64, 578, "Back to people", 14.5, 600, BRAND)
        b += "</g>"

    b += '<g id="Say hi bar">'
    b += rect(0, 764, W, 80, 0, WHITE)
    b += f'<line x1="0" y1="764" x2="{W}" y2="764" stroke="{LINE}" stroke-width="1"/>'
    b += t(16, 796, "Buy me a coffee", 16, 600, INK)
    b += t(16, 814, "Free today", 12, 400, MUTED)
    if section == "pending":
        b += rect(146, 778, 228, 52, 26, MUTED)
        b += icon("clock", 170, 793, 20, WHITE, 2)
        b += t(198, 810, "Waiting for reply", 15.5, 700, WHITE)
    else:
        b += rect(176, 778, 198, 52, 26, BRAND)
        b += icon("wave", 206, 793, 20, WHITE, 2)
        b += t(234, 810, "Say hi", 15.5, 700, WHITE)
    b += "</g>"
    return frame(f"05 Local profile — {section}", b)


# ------------------------------------------------------------------ feature 3

def f_request(state):
    b = back_bar("Meet Aizhan")
    b += '<g id="Intro">'
    b += t(16, 118, "Aizhan K. is free today and usually replies", 13.5, 400, MUTED)
    b += t(16, 136, "within an hour.", 13.5, 400, MUTED)
    b += "</g>"

    b += '<g id="When">'
    b += t(16, 172, "When", 19, 700, INK)
    b += chip_row(16, 186, [("Today", True), ("Tomorrow", False), ("Sat 25 Oct", False)])
    b += segmented(16, 230, 358, ["Morning", "Afternoon", "Evening"], 2)
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
    err = state == "error"
    b += rect(16, 648, 358, 92, 20, WHITE, ERROR if err else LINE, 1.6 if err else 1)
    if state in ("filled", "sent"):
        b += t(34, 676, "Hi! I am in Almaty for four days and I would", 14, 400, INK)
        b += t(34, 696, "love a coffee and a chat about the city.", 14, 400, INK)
    else:
        b += t(34, 676, "Who you are, how long you are in town,", 14, 400, MUTED)
        b += t(34, 696, "what you are curious about…", 14, 400, MUTED)
    if err:
        b += error_line(18, 760, "Write a line about yourself — this is a")
        b += t(38, 778, "person, not a booking form", 12.5, 400, ERROR)
    b += "</g>"

    if state in ("filled", "sent"):
        b += '<g id="Summary">'
        b += card(16, 756, 358, 70)
        for i, (lab, val) in enumerate([("Who", "Aizhan K."), ("When", "Today, Evening")]):
            b += t(32, 782 + i * 22, lab, 12.5, 400, MUTED)
            b += t(94, 782 + i * 22, val, 13.5, 600, INK)
        b += "</g>"
    elif state == "empty":
        b += '<g id="Tell a friend">'
        b += rect(16, 756, 22, 22, 6, BRAND)
        b += icon("check", 20, 760, 14, WHITE, 3)
        b += t(48, 772, "Send my plan to a friend", 14, 600, INK)
        b += "</g>"
        b += rect(16, 790, 358, 52, 26, BRAND)
        b += icon("send", 142, 805, 20, WHITE)
        b += t(172, 822, "Send the request", 15.5, 700, WHITE)

    if state == "error":
        b += rect(16, 790, 358, 52, 26, BRAND)
        b += icon("send", 142, 805, 20, WHITE)
        b += t(172, 822, "Send the request", 15.5, 700, WHITE)

    if state == "sent":
        b += snackbar(756, ["Sent to Aizhan K. They usually reply",
                            "within an hour."])
    return frame(f"06 Meetup request — {state}", b)


# ------------------------------------------------------------------ feature 4

def f_spots(state):
    b = back_bar("Through their eyes")
    b += '<g id="Intro">'
    b += t(16, 118, "Places nobody puts on a tour, added by the", 13.5, 400, MUTED)
    b += t(16, 136, "people who go there anyway.", 13.5, 400, MUTED)
    b += "</g>"

    sel = {"all": 0, "filtered": 1, "empty": 4}[state]
    b += '<g id="Area filter">'
    b += chip_row(16, 158, [(l, i == sel) for i, l in
                            enumerate(["All areas", "Medeu", "Almaly", "Zhetysu"])])
    b += "</g>"

    data = [
        ("Green Bazaar, upstairs", "184", "Almaly", "Bazaar", "Before 10am",
         ["Everyone photographs the ground floor. Upstairs is",
          "where the dried fruit sellers are, and they will make",
          "you taste nine things before you buy one."], "Gulnara S."),
        ("The dam steps at Medeu", "206", "Medeu", "Viewpoint", "Dusk",
         ["842 steps. Everybody counts them and everybody",
          "gets a different number. Go up at dusk when the",
          "skating rink lights come on."], "Timur B."),
    ]
    if state == "filtered":
        data = [data[1]]
    if state == "empty":
        b += empty_state(260, "pin", "Nothing here yet",
                         ["No one has added a place in Zhetysu so far."],
                         "Show all areas")
        data = []

    for i, (name, saves, area, kind, best, quote, who) in enumerate(data):
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

    by = 700 if state == "all" else (462 if state == "filtered" else 560)
    b += '<g id="Back button">'
    b += rect(16, by, 110, 48, 24, CANVAS, LINE)
    b += icon("back", 36, by + 12, 19, BRAND, 2)
    b += t(64, by + 30, "Back", 14.5, 600, BRAND)
    b += "</g>"
    return frame(f"07 Spots — {state}", b)


# ------------------------------------------------------------------ feature 5

def f_become(section):
    b = back_bar("Become a local")
    err = section == "errors"

    if section in ("about", "errors", "done"):
        b += '<g id="Promise">'
        b += rect(16, 108, 358, 86, 20, SOFT, opacity=0.35)
        for i, ln in enumerate(["You do not need a licence, a route or any",
                                "experience. If you like this city and you like",
                                "talking to people, that is the requirement."]):
            b += t(32, 134 + i * 18, ln, 13.5, 400, DEEP)
        b += "</g>"
        b += '<g id="About you">'
        b += t(16, 226, "About you", 19, 700, INK)
        b += field(16, 258, 358, "Name",
                   "" if err else "Aizhan K.", placeholder=err,
                   error="Please enter your name" if err else None)
        ay = 352 if err else 340
        b += field(16, ay, 104, "Age", "16" if err else "27",
                   error="18 or over" if err else None)
        b += t(132, ay - 8, "Your area", 13, 600, INK)
        b += rect(132, ay, 242, 50, 20, WHITE, LINE)
        b += t(150, ay + 30, "Medeu", 14, 400, INK)
        b += f'<path d="M346 {ay + 22} l6 7 6-7" fill="none" stroke="{MUTED}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
        oy = ay + 96
        b += field(16, oy, 358, "One line about you",
                   "Barista. I can tell you which coffee place is", h=76,
                   placeholder=err)
        b += t(34, oy + 50, "actually worth your morning." if not err else "", 14, 400, INK)
        b += "</g>"
        if err:
            b += '<g id="Interests error">'
            b += t(16, 600, "What you are into", 19, 700, INK)
            b += chip_row(16, 614, [("Coffee", False), ("Street art", False),
                                    ("Books", False)], h=30)
            b += error_line(18, 668, "Pick at least one")
            b += "</g>"
            b += '<g id="Rules error">'
            b += rect(16, 696, 22, 22, 6, WHITE, LINE, 1.5)
            b += t(48, 712, "I will meet first-timers in a public place", 14, 600, INK)
            b += error_line(18, 744, "You have to agree to this one")
            b += "</g>"
            b += rect(16, 772, 358, 52, 26, BRAND)
            b += t(195, 804, "Put me on the map", 15.5, 700, WHITE, anchor="middle")

    elif section == "interests":
        b += '<g id="Languages">'
        b += t(16, 134, "Languages", 19, 700, INK)
        b += t(16, 152, "Be honest about the level — it is the whole point", 12, 400, MUTED)
        b += chip_row(16, 166, [("Kazakh", True), ("Russian", True), ("English", True)], h=30)
        for i, (lang, lvl) in enumerate([("Kazakh", "Native"), ("Russian", "Native"),
                                         ("English", "B2")]):
            y = 212 + i * 50
            b += t(16, y + 24, lang, 13.5, 600, INK)
            b += rect(246, y, 128, 38, 12, WHITE, LINE)
            b += t(262, y + 24, lvl, 13.5, 400, INK)
            b += f'<path d="M348 {y + 16} l5 6 5-6" fill="none" stroke="{MUTED}" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>'
        b += "</g>"
        b += '<g id="What you are into">'
        b += t(16, 404, "What you are into", 19, 700, INK)
        b += t(16, 422, "This is how travellers are matched to you", 12, 400, MUTED)
        b += chip_row(16, 436, [("Coffee", True), ("Street art", True), ("Books", False)], h=30)
        b += chip_row(16, 474, [("Photography", True), ("Live music", False)], h=30)
        b += "</g>"
        b += '<g id="What you would do">'
        b += t(16, 546, "What you would happily do", 19, 700, INK)
        b += t(16, 564, "No route to write — just tick what sounds like you", 12, 400, MUTED)
        for i, (ic, label, on) in enumerate([
                ("cup", "Coffee and a chat", True),
                ("walk", "Walk around my neighbourhood", True),
                ("camera", "Show you the good photo spots", False),
                ("globe", "Language exchange", False)]):
            y = 584 + i * 44
            b += rect(16, y, 20, 20, 5, BRAND if on else WHITE, None if on else LINE, 1.5)
            if on:
                b += icon("check", 19, y + 3, 14, WHITE, 3)
            b += icon(ic, 46, y + 1, 18, BRAND if on else MUTED, 1.9)
            b += t(74, y + 15, label, 14, 600, INK)
        b += "</g>"

    elif section == "money":
        b += '<g id="When you are around">'
        b += t(16, 134, "When you are usually around", 19, 700, INK)
        b += segmented(16, 152, 358, ["Today", "Tomorrow", "Weekend", "Later"], 2, h=40)
        b += field(16, 226, 358, "In your words", "Most evenings after 6, weekends all day")
        b += "</g>"
        b += '<g id="Money">'
        b += t(16, 318, "Money", 19, 700, INK)
        b += t(16, 336, "Most people here charge nothing. That is fine.", 12, 400, MUTED)
        b += segmented(16, 350, 358, ["Free", "Coffee", "Hourly"], 2, h=40)
        b += field(16, 426, 358, "Your rate, $ per hour", "8")
        b += "</g>"
        b += '<g id="Rules">'
        b += rect(16, 514, 22, 22, 6, BRAND)
        b += icon("check", 20, 518, 14, WHITE, 3)
        b += t(48, 530, "I will meet first-timers in a public place", 14, 600, INK)
        b += t(48, 552, "Both sides agree to this. It is what makes meeting", 12.5, 400, MUTED)
        b += t(48, 570, "a stranger reasonable.", 12.5, 400, MUTED)
        b += "</g>"
        b += '<g id="Publish">'
        b += rect(16, 610, 358, 52, 26, BRAND)
        b += icon("wave", 102, 625, 20, WHITE, 2)
        b += t(130, 642, "Put me on the map", 15.5, 700, WHITE)
        b += rect(16, 674, 358, 48, 24, CANVAS, LINE)
        b += icon("back", 140, 686, 19, BRAND, 2)
        b += t(168, 704, "Not now", 14.5, 600, BRAND)
        b += "</g>"

    if section == "done":
        b += scrim()
        b += '<g id="Dialog">'
        b += rect(32, 300, 326, 232, 20, WHITE)
        b += t(56, 348, "You are on the map", 19, 700, INK)
        for i, ln in enumerate(["Aizhan K., your profile is live.",
                                "Travellers who are into coffee and",
                                "street art will see you first."]):
            b += t(56, 386 + i * 24, ln, 14, 400, MUTED)
        b += t(330, 496, "Done", 15, 700, BRAND, anchor="end")
        b += "</g>"
    return frame(f"08 Become a local — {section}", b)


# ------------------------------------------------------------------ output

FILES = {}
for s in ["default", "filtered", "search", "empty"]:
    FILES[f"04{'abcd'[['default','filtered','search','empty'].index(s)]}-locals-{s}.svg"] = f_locals(s)
for i, s in enumerate(["top", "hangouts", "places", "pending"]):
    FILES[f"05{'abcd'[i]}-profile-{s}.svg"] = f_profile(s)
for i, s in enumerate(["empty", "error", "filled", "sent"]):
    FILES[f"06{'abcd'[i]}-request-{s}.svg"] = f_request(s)
for i, s in enumerate(["all", "filtered", "empty"]):
    FILES[f"07{'abc'[i]}-spots-{s}.svg"] = f_spots(s)
for i, s in enumerate(["about", "interests", "money", "errors", "done"]):
    FILES[f"08{'abcde'[i]}-become-{s}.svg"] = f_become(s)

for name, body in sorted(FILES.items()):
    with open(os.path.join(TARGET, name), "w", encoding="utf-8") as f:
        f.write(body)
print(f"{len(FILES)} frames written")
