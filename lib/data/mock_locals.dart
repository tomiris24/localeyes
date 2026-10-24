import '../models/local_person.dart';
import '../models/spot.dart';

/// Demo data for the "meet a local" side of the app.
///
/// These are ordinary residents, not tour operators: a barista, a student, a
/// retired teacher. In the next milestone the list comes from a REST API.
class MockLocals {
  MockLocals._();

  /// Interests are a fixed list so that a traveller's picks and a local's
  /// picks can actually be compared.
  static const List<String> interests = <String>[
    'Coffee',
    'Food markets',
    'Mountains',
    'Photography',
    'Live music',
    'Architecture',
    'Street art',
    'Books',
    'Football',
    'Cycling',
    'History',
    'Night out',
  ];

  static const List<String> areas = <String>[
    'All areas',
    'Medeu',
    'Almaly',
    'Bostandyk',
    'Zhetysu',
    'Auezov',
  ];

  /// Public places the app suggests for a first meetup. Safety by default:
  /// the first meeting is always somewhere with other people around.
  static const List<String> publicMeetingPlaces = <String>[
    'Green Bazaar main entrance',
    'Arbat, by the fountain',
    'Panfilov Park, east gate',
    'Abai metro station, surface exit',
    'Republic Square steps',
  ];

  static const List<LocalPerson> people = <LocalPerson>[
    LocalPerson(
      id: 'l1',
      name: 'Aizhan K.',
      age: 27,
      neighbourhood: 'Medeu',
      oneLiner:
          'Barista. I can tell you which of the forty new coffee places is '
          'actually worth your morning.',
      bio:
          'I grew up two streets from Gorky Park and I pull espresso for a '
          'living, so I spend my days listening to people talk about this city. '
          'I am not a guide and I do not have a route — we just walk and I '
          'answer whatever you are curious about.',
      languages: <LanguageSkill>[
        LanguageSkill(language: 'Kazakh', level: 'Native'),
        LanguageSkill(language: 'Russian', level: 'Native'),
        LanguageSkill(language: 'English', level: 'B2'),
      ],
      interests: <String>['Coffee', 'Street art', 'Books', 'Photography'],
      hangouts: <HangoutIdea>[
        HangoutIdea(
          kind: HangoutKind.coffee,
          note: 'Three places in one morning, all within walking distance.',
        ),
        HangoutIdea(
          kind: HangoutKind.walk,
          note: 'The courtyards behind Panfilov, where nobody takes tourists.',
        ),
      ],
      availability: Availability.today,
      usualTimes: 'Most evenings after 6, weekends all day',
      cost: MeetupCost.coffee,
      meetCount: 31,
      rating: 4.9,
      responseTime: 'usually replies within an hour',
      memberSince: 'March 2025',
      favouriteSpotIds: <String>['s1', 's4', 's6'],
    ),
    LocalPerson(
      id: 'l2',
      name: 'Dias M.',
      age: 24,
      neighbourhood: 'Bostandyk',
      oneLiner:
          'Engineering student who photographs the city at night. Bring a '
          'jacket, we will be out late.',
      bio:
          'I have been shooting Almaty after dark for four years. I know which '
          'rooftops let you up, which bus gets you to Koktobe before the light '
          'goes, and where to eat at midnight afterwards.',
      languages: <LanguageSkill>[
        LanguageSkill(language: 'Russian', level: 'Native'),
        LanguageSkill(language: 'Kazakh', level: 'B1'),
        LanguageSkill(language: 'English', level: 'C1'),
      ],
      interests: <String>['Photography', 'Night out', 'Architecture', 'Live music'],
      hangouts: <HangoutIdea>[
        HangoutIdea(
          kind: HangoutKind.photo,
          note: 'Sunset at Koktobe, then the Soviet mosaics lit up.',
        ),
        HangoutIdea(
          kind: HangoutKind.nightOut,
          note: 'Small bars in Almaly where the crowd is local, not expat.',
        ),
      ],
      availability: Availability.tomorrow,
      usualTimes: 'Thursday to Sunday, from 7pm',
      cost: MeetupCost.hourly,
      hourlyRate: 8,
      meetCount: 18,
      rating: 4.8,
      responseTime: 'usually replies in a few hours',
      memberSince: 'July 2025',
      favouriteSpotIds: <String>['s2', 's5'],
    ),
    LocalPerson(
      id: 'l3',
      name: 'Gulnara S.',
      age: 58,
      neighbourhood: 'Almaly',
      oneLiner:
          'Retired school teacher. I cook, I talk a lot, and I have lived on '
          'the same street since 1979.',
      bio:
          'I taught history for thirty-one years, so you will get more context '
          'than you asked for. We can go through the Green Bazaar and I will '
          'show you what the vendors are actually selling and how to haggle '
          'without being rude.',
      languages: <LanguageSkill>[
        LanguageSkill(language: 'Russian', level: 'Native'),
        LanguageSkill(language: 'Kazakh', level: 'Native'),
        LanguageSkill(language: 'English', level: 'A2'),
      ],
      interests: <String>['Food markets', 'History', 'Books'],
      hangouts: <HangoutIdea>[
        HangoutIdea(
          kind: HangoutKind.food,
          note: 'The bazaar before ten, then lunch at a canteen with no menu.',
        ),
        HangoutIdea(
          kind: HangoutKind.walk,
          note: 'The old streets, and what used to be where.',
        ),
      ],
      availability: Availability.weekend,
      usualTimes: 'Weekday mornings, Saturdays',
      cost: MeetupCost.free,
      meetCount: 44,
      rating: 5.0,
      responseTime: 'usually replies the same day',
      memberSince: 'January 2025',
      favouriteSpotIds: <String>['s1', 's3'],
    ),
    LocalPerson(
      id: 'l4',
      name: 'Timur B.',
      age: 31,
      neighbourhood: 'Medeu',
      oneLiner:
          'I hike every weekend. Happy to take you somewhere green that is '
          'still inside the bus network.',
      bio:
          'Weekday job in logistics, weekends in the Zailiysky Alatau. I am '
          'not taking anyone up a glacier — think three or four hours, a '
          'thermos, and a view most visitors never get to because they only '
          'hear about Medeu and Shymbulak.',
      languages: <LanguageSkill>[
        LanguageSkill(language: 'Kazakh', level: 'Native'),
        LanguageSkill(language: 'Russian', level: 'Native'),
        LanguageSkill(language: 'English', level: 'B1'),
      ],
      interests: <String>['Mountains', 'Cycling', 'Photography', 'Football'],
      hangouts: <HangoutIdea>[
        HangoutIdea(
          kind: HangoutKind.sport,
          note: 'Butakovka waterfall, easy pace, back by late afternoon.',
        ),
        HangoutIdea(
          kind: HangoutKind.coffee,
          note: 'Or just a coffee if the weather turns.',
        ),
      ],
      availability: Availability.weekend,
      usualTimes: 'Saturdays and Sundays',
      cost: MeetupCost.coffee,
      meetCount: 22,
      rating: 4.9,
      responseTime: 'usually replies within an hour',
      memberSince: 'May 2025',
      favouriteSpotIds: <String>['s5', 's7'],
    ),
    LocalPerson(
      id: 'l5',
      name: 'Aruzhan T.',
      age: 22,
      neighbourhood: 'Auezov',
      oneLiner:
          'Design student. I want to practise my English and I will show you '
          'the murals nobody puts on a postcard.',
      bio:
          'I am doing this mostly to talk to people from somewhere else. I '
          'know the street art in the western districts because half of it was '
          'painted by people from my faculty.',
      languages: <LanguageSkill>[
        LanguageSkill(language: 'Russian', level: 'Native'),
        LanguageSkill(language: 'Kazakh', level: 'Native'),
        LanguageSkill(language: 'English', level: 'B1'),
        LanguageSkill(language: 'Turkish', level: 'A2'),
      ],
      interests: <String>['Street art', 'Architecture', 'Live music', 'Coffee'],
      hangouts: <HangoutIdea>[
        HangoutIdea(
          kind: HangoutKind.language,
          note: 'You speak English with me, I answer anything about the city.',
        ),
        HangoutIdea(
          kind: HangoutKind.walk,
          note: 'Murals in Auezov district, about two hours.',
        ),
      ],
      availability: Availability.today,
      usualTimes: 'Weekday afternoons between classes',
      cost: MeetupCost.free,
      meetCount: 9,
      rating: 4.7,
      responseTime: 'usually replies within minutes',
      memberSince: 'September 2025',
      favouriteSpotIds: <String>['s6', 's8'],
    ),
    LocalPerson(
      id: 'l6',
      name: 'Yerlan A.',
      age: 36,
      neighbourhood: 'Zhetysu',
      oneLiner:
          'Sound engineer. If there is a gig worth going to this week, I know '
          'about it.',
      bio:
          'I mix live sound at three venues in town. Come on a night when '
          'something is on and I will get you in with the regulars instead of '
          'standing at the back on your own.',
      languages: <LanguageSkill>[
        LanguageSkill(language: 'Russian', level: 'Native'),
        LanguageSkill(language: 'English', level: 'B2'),
      ],
      interests: <String>['Live music', 'Night out', 'Food markets'],
      hangouts: <HangoutIdea>[
        HangoutIdea(
          kind: HangoutKind.music,
          note: 'Whatever is playing — I will tell you if it is any good.',
        ),
        HangoutIdea(
          kind: HangoutKind.food,
          note: 'Late food after, the places that stay open for musicians.',
        ),
      ],
      availability: Availability.laterOn,
      usualTimes: 'Gig nights, usually Friday and Saturday',
      cost: MeetupCost.coffee,
      meetCount: 27,
      rating: 4.8,
      responseTime: 'usually replies the same day',
      memberSince: 'February 2025',
      favouriteSpotIds: <String>['s2', 's8'],
    ),
  ];

  static const List<Spot> spots = <Spot>[
    Spot(
      id: 's1',
      name: 'Green Bazaar, upstairs',
      area: 'Almaly',
      kind: 'Bazaar',
      why:
          'Everyone photographs the ground floor. Upstairs is where the dried '
          'fruit sellers are, and they will make you taste nine things before '
          'you buy one.',
      addedById: 'l3',
      addedByName: 'Gulnara S.',
      saveCount: 184,
      bestTime: 'Before 10am',
    ),
    Spot(
      id: 's2',
      name: 'The mosaic bus stops on Abai',
      area: 'Bostandyk',
      kind: 'Architecture',
      why:
          'Soviet mosaics still sitting at ordinary bus stops. People wait for '
          'the 63 in front of them every day without looking up.',
      addedById: 'l2',
      addedByName: 'Dias M.',
      saveCount: 97,
      bestTime: 'Late afternoon light',
    ),
    Spot(
      id: 's3',
      name: 'Canteen on Zhibek Zholy',
      area: 'Almaly',
      kind: 'Canteen',
      why:
          'No menu, no English, no sign. You point at what looks good. Lunch '
          'costs less than a coffee in the centre.',
      addedById: 'l3',
      addedByName: 'Gulnara S.',
      saveCount: 142,
      bestTime: '12:30 to 2pm',
    ),
    Spot(
      id: 's4',
      name: 'The courtyard behind Panfilov',
      area: 'Almaly',
      kind: 'Courtyard',
      why:
          'Old apartment blocks with apple trees in the middle. Grandmothers '
          'on the benches will talk to you whether or not you share a language.',
      addedById: 'l1',
      addedByName: 'Aizhan K.',
      saveCount: 63,
      bestTime: 'Early evening',
    ),
    Spot(
      id: 's5',
      name: 'Butakovka, the lower trail',
      area: 'Medeu',
      kind: 'Trail',
      why:
          'A bus and then three hours of walking. Not the famous one, which is '
          'exactly why there is nobody on it.',
      addedById: 'l4',
      addedByName: 'Timur B.',
      saveCount: 118,
      bestTime: 'Saturday morning',
    ),
    Spot(
      id: 's6',
      name: 'Book market at Baraholka',
      area: 'Zhetysu',
      kind: 'Market',
      why:
          'Second-hand Russian paperbacks stacked on car bonnets. I found my '
          'grandmother\'s school textbook there.',
      addedById: 'l1',
      addedByName: 'Aizhan K.',
      saveCount: 51,
      bestTime: 'Sunday',
    ),
    Spot(
      id: 's7',
      name: 'The dam steps at Medeu',
      area: 'Medeu',
      kind: 'Viewpoint',
      why:
          '842 steps. Everybody counts them and everybody gets a different '
          'number. Go up at dusk when the skating rink lights come on.',
      addedById: 'l4',
      addedByName: 'Timur B.',
      saveCount: 206,
      bestTime: 'Dusk',
    ),
    Spot(
      id: 's8',
      name: 'Mural wall, 11th microdistrict',
      area: 'Auezov',
      kind: 'Street art',
      why:
          'Two blocks of walls repainted every spring by students. It looks '
          'different every year, so no guidebook can keep up with it.',
      addedById: 'l5',
      addedByName: 'Aruzhan T.',
      saveCount: 44,
      bestTime: 'Daylight',
    ),
  ];

  static LocalPerson byId(String id) =>
      people.firstWhere((LocalPerson p) => p.id == id);

  static Spot spotById(String id) => spots.firstWhere((Spot s) => s.id == id);

  static List<Spot> spotsBy(String localId) =>
      spots.where((Spot s) => s.addedById == localId).toList();
}
