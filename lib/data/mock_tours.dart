import '../models/guide.dart';
import '../models/review.dart';
import '../models/tour.dart';

/// Demo data for Milestone 1. In the next milestones this comes from a REST API.
class MockData {
  MockData._();

  static const List<String> categories = <String>[
    'All',
    'Mountains',
    'City walk',
    'Food',
    'Culture',
    'Ski',
  ];

  static const Guide _aizhan = Guide(
    id: 'g1',
    name: 'Aizhan K.',
    yearsOfExperience: 5,
    languages: <String>['EN', 'RU', 'KZ'],
    rating: 4.9,
    tourCount: 214,
    responseTime: 'replies in ~15 min',
    bio:
        'Born in Almaty, hiking in the Zailiysky Alatau since school. I keep groups '
        'small so everybody can walk at their own pace and still make it to the lake.',
  );

  static const Guide _dias = Guide(
    id: 'g2',
    name: 'Dias M.',
    yearsOfExperience: 3,
    languages: <String>['EN', 'RU'],
    rating: 4.8,
    tourCount: 96,
    responseTime: 'replies in ~1 h',
    bio:
        'Photographer and driver. I know where the light is good at every hour, '
        'and I never rush people through a viewpoint.',
  );

  static const Guide _madina = Guide(
    id: 'g3',
    name: 'Madina S.',
    yearsOfExperience: 7,
    languages: <String>['EN', 'RU', 'KZ', 'TR'],
    rating: 5.0,
    tourCount: 331,
    responseTime: 'replies in ~10 min',
    bio:
        'Former museum guide. I tell the city through food, families and small '
        'courtyards that tourists usually walk past.',
  );

  static const Guide _ruslan = Guide(
    id: 'g4',
    name: 'Ruslan T.',
    yearsOfExperience: 6,
    languages: <String>['EN', 'RU'],
    rating: 4.7,
    tourCount: 158,
    responseTime: 'replies in ~30 min',
    bio:
        'Certified ski instructor. I match the slope to your real level, not to '
        'the level you wish you had.',
  );

  static const TourFacts _easyFacts = TourFacts(
    difficulty: 'Easy',
    walkingTime: '2–3 h walking',
    groupSize: 'Max 6 people',
    languageLevel: 'Fluent English',
    meetingPoint: 'Abay metro, exit 2',
  );

  static final List<Tour> tours = <Tour>[
    Tour(
      id: 't1',
      title: 'Kolsai Lakes: slow hike to the second lake',
      area: 'Kolsai, 300 km from Almaty',
      image: 'assets/images/kolsai.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC BY-SA 4.0',
      category: 'Mountains',
      pricePerPerson: 85,
      rating: 4.9,
      reviewCount: 128,
      duration: 'Full day · 11 h',
      tags: <String>['Moderate', 'Small group', 'EN / RU / KZ', 'Photo spots', 'Transport included'],
      summary:
          'A full day in the Kolsai valley with a calm, honest pace. We stop when you '
          'want to stop. The hike to the second lake takes about four hours up and back, '
          'and we keep the group under six people so nobody is left behind.',
      included: <String>[
        'Transport from Almaty and back',
        'National park entrance fee',
        'Tea and snacks at the first lake',
        'Photos from the trail, sent the same evening',
      ],
      route: <RouteStop>[
        RouteStop(time: '06:30', title: 'Pick-up in Almaty', note: 'Your hotel or Abay metro.'),
        RouteStop(time: '10:00', title: 'First lake', note: 'Short break, tea, photos.'),
        RouteStop(time: '11:00', title: 'Trail to the second lake', note: '4 h up and back, 450 m climb.'),
        RouteStop(time: '15:00', title: 'Lunch in Saty village', note: 'Home kitchen, not a restaurant.'),
        RouteStop(time: '19:30', title: 'Back in Almaty', note: 'Drop-off at the same point.'),
      ],
      facts: TourFacts(
        difficulty: 'Moderate',
        walkingTime: '4 h walking',
        groupSize: 'Max 6 people',
        languageLevel: 'Fluent English',
        meetingPoint: 'Your hotel or Abay metro',
      ),
      guide: _aizhan,
      reviews: <Review>[
        Review(
          author: 'Lena',
          country: 'Germany',
          rating: 5,
          timeAgo: '2 weeks ago',
          text:
              'I travelled alone and felt safe the whole day. Aizhan wrote the plan in '
              'the chat before the tour, so I knew exactly what to expect.',
        ),
        Review(
          author: 'Marco',
          country: 'Italy',
          rating: 5,
          timeAgo: '1 month ago',
          text: 'Group was really six people, not twenty. The pace was honest.',
        ),
        Review(
          author: 'Dana',
          country: 'Kazakhstan',
          rating: 4,
          timeAgo: '1 month ago',
          text: 'Long day, but worth it. Bring warm clothes, the lake is cold.',
        ),
      ],
      availableDates: <String>['Tue, 7 Oct', 'Thu, 9 Oct', 'Sat, 11 Oct', 'Sun, 12 Oct'],
      maxGuests: 6,
    ),
    Tour(
      id: 't2',
      title: 'Charyn Canyon sunset photo trip',
      area: 'Charyn, 215 km from Almaty',
      image: 'assets/images/charyn.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC0',
      category: 'Mountains',
      pricePerPerson: 70,
      rating: 4.8,
      reviewCount: 94,
      duration: 'Full day · 10 h',
      tags: <String>['Easy', 'Photo tour', 'EN / RU', 'Max 4 people', 'Car trip'],
      summary:
          'We leave late so you see the canyon in the best light instead of at noon '
          'with every bus in the region. Four people maximum, so everyone gets a '
          'window seat and time at each viewpoint.',
      included: <String>[
        'Car and fuel',
        'Park entrance fee',
        'Edited photos within 48 hours',
        'Water and fruit',
      ],
      route: <RouteStop>[
        RouteStop(time: '11:00', title: 'Leave Almaty', note: 'Coffee stop on the way.'),
        RouteStop(time: '14:30', title: 'Valley of Castles', note: '3 km walk down and back.'),
        RouteStop(time: '17:30', title: 'Sunset viewpoint', note: 'The quiet side of the canyon.'),
        RouteStop(time: '22:00', title: 'Back in Almaty', note: ''),
      ],
      facts: TourFacts(
        difficulty: 'Easy',
        walkingTime: '2 h walking',
        groupSize: 'Max 4 people',
        languageLevel: 'Good English',
        meetingPoint: 'Dostyk / Al-Farabi crossing',
      ),
      guide: _dias,
      reviews: <Review>[
        Review(
          author: 'Sofia',
          country: 'Poland',
          rating: 5,
          timeAgo: '3 weeks ago',
          text: 'The photos arrived two days later, exactly as promised.',
        ),
        Review(
          author: 'Aidar',
          country: 'Kazakhstan',
          rating: 5,
          timeAgo: '2 months ago',
          text: 'Nice that it is a small car and not a tourist bus.',
        ),
      ],
      availableDates: <String>['Wed, 8 Oct', 'Fri, 10 Oct', 'Sat, 11 Oct'],
      maxGuests: 4,
    ),
    Tour(
      id: 't3',
      title: 'Green Bazaar food walk and home lunch',
      area: 'Almaty city centre',
      image: 'assets/images/zenkov.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC0',
      category: 'Food',
      pricePerPerson: 45,
      rating: 5.0,
      reviewCount: 212,
      duration: 'Half day · 4 h',
      tags: <String>['Easy', 'Food', 'EN / RU / KZ / TR', 'Small group', 'Vegetarian option'],
      summary:
          'We start at the Green Bazaar, taste horse meat, kurt and dried fruit, walk '
          'through Panfilov Park and the wooden cathedral, and finish with lunch at '
          'my aunt’s flat. Yes, a real flat, not a restaurant.',
      included: <String>[
        'All tastings at the bazaar',
        'Home-cooked lunch',
        'Tea ceremony',
        'A list of places to eat later on your own',
      ],
      route: <RouteStop>[
        RouteStop(time: '10:00', title: 'Green Bazaar', note: 'Tasting six things you cannot name yet.'),
        RouteStop(time: '11:30', title: 'Panfilov Park', note: 'Short, shaded walk.'),
        RouteStop(time: '12:00', title: 'Zenkov Cathedral', note: 'Wooden, built without nails.'),
        RouteStop(time: '13:00', title: 'Home lunch', note: 'Beshbarmak and conversation.'),
      ],
      facts: _easyFacts,
      guide: _madina,
      reviews: <Review>[
        Review(
          author: 'Emma',
          country: 'UK',
          rating: 5,
          timeAgo: '1 week ago',
          text: 'The best thing I did in Kazakhstan. Felt like visiting a family.',
        ),
        Review(
          author: 'Yusuf',
          country: 'Turkey',
          rating: 5,
          timeAgo: '3 weeks ago',
          text: 'Madina speaks Turkish, which made my parents very happy.',
        ),
      ],
      availableDates: <String>['Tue, 7 Oct', 'Wed, 8 Oct', 'Thu, 9 Oct', 'Fri, 10 Oct'],
      maxGuests: 6,
    ),
    Tour(
      id: 't4',
      title: 'Shymbulak: first day on skis',
      area: 'Shymbulak resort',
      image: 'assets/images/shymbulak.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC BY-SA 4.0',
      category: 'Ski',
      pricePerPerson: 110,
      rating: 4.7,
      reviewCount: 61,
      duration: 'Half day · 5 h',
      tags: <String>['Beginner', 'Equipment included', 'EN / RU', '1-on-1', 'Winter'],
      summary:
          'A calm first day on the slope for people who have never skied. We start on '
          'the training line, and we only move up when you actually feel ready.',
      included: <String>[
        'Skis, boots and helmet',
        'Lift pass for the beginner line',
        'Instructor for 4 hours',
        'Hot tea break',
      ],
      route: <RouteStop>[
        RouteStop(time: '09:00', title: 'Meet at the gondola', note: 'Equipment fitting.'),
        RouteStop(time: '10:00', title: 'Training slope', note: 'Balance, stopping, turning.'),
        RouteStop(time: '12:30', title: 'Break', note: 'Tea with a view.'),
        RouteStop(time: '13:00', title: 'First real run', note: 'Only if you want to.'),
      ],
      facts: TourFacts(
        difficulty: 'Beginner',
        walkingTime: '4 h on the slope',
        groupSize: '1–2 people',
        languageLevel: 'Good English',
        meetingPoint: 'Shymbulak gondola station',
      ),
      guide: _ruslan,
      reviews: <Review>[
        Review(
          author: 'Hiroshi',
          country: 'Japan',
          rating: 5,
          timeAgo: '5 months ago',
          text: 'Patient instructor. I was skiing by the afternoon.',
        ),
      ],
      availableDates: <String>['Sat, 11 Oct', 'Sun, 12 Oct'],
      maxGuests: 2,
    ),
    Tour(
      id: 't5',
      title: 'Big Almaty Lake at golden hour',
      area: 'Ile-Alatau National Park',
      image: 'assets/images/bigalmaty.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC BY-SA 4.0',
      category: 'Mountains',
      pricePerPerson: 55,
      rating: 4.8,
      reviewCount: 143,
      duration: 'Half day · 6 h',
      tags: <String>['Easy', 'Car trip', 'EN / RU / KZ', 'Max 5 people', 'Altitude 2500 m'],
      summary:
          'Short drive, big view. Almost no walking, so this one works for families '
          'and for anyone who landed this morning and is still tired.',
      included: <String>['Transport', 'Park fee', 'Blanket and thermos', 'Photos'],
      route: <RouteStop>[
        RouteStop(time: '14:00', title: 'Pick-up', note: 'City centre.'),
        RouteStop(time: '15:30', title: 'Lake viewpoint', note: '1 h at the water.'),
        RouteStop(time: '17:00', title: 'Observatory road', note: 'Optional short walk.'),
        RouteStop(time: '20:00', title: 'Back in the city', note: ''),
      ],
      facts: TourFacts(
        difficulty: 'Easy',
        walkingTime: '40 min walking',
        groupSize: 'Max 5 people',
        languageLevel: 'Fluent English',
        meetingPoint: 'Republic Square',
      ),
      guide: _aizhan,
      reviews: <Review>[
        Review(
          author: 'Noor',
          country: 'UAE',
          rating: 5,
          timeAgo: '2 weeks ago',
          text: 'Perfect for my parents, very little walking and a huge view.',
        ),
      ],
      availableDates: <String>['Tue, 7 Oct', 'Thu, 9 Oct', 'Sun, 12 Oct'],
      maxGuests: 5,
    ),
    Tour(
      id: 't6',
      title: 'Medeu and the 842 steps',
      area: 'Medeu, 15 km from the centre',
      image: 'assets/images/medeu.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC BY-SA 4.0',
      category: 'City walk',
      pricePerPerson: 30,
      rating: 4.6,
      reviewCount: 88,
      duration: 'Half day · 4 h',
      tags: <String>['Moderate', 'Budget', 'EN / RU', 'Max 8 people', 'Public transport'],
      summary:
          'The classic half-day out of the city: the skating rink, the dam, and the '
          '842 steps for those who want them. We take the bus like locals do.',
      included: <String>['Bus tickets', 'Skating rink entrance', 'Tea at the top'],
      route: <RouteStop>[
        RouteStop(time: '10:00', title: 'Bus from the city', note: '40 min ride.'),
        RouteStop(time: '11:00', title: 'Medeu rink', note: 'History of the valley.'),
        RouteStop(time: '12:00', title: 'The 842 steps', note: 'Optional, at your pace.'),
        RouteStop(time: '13:30', title: 'Back down', note: ''),
      ],
      facts: TourFacts(
        difficulty: 'Moderate',
        walkingTime: '2 h walking',
        groupSize: 'Max 8 people',
        languageLevel: 'Good English',
        meetingPoint: 'Dostyk avenue bus stop',
      ),
      guide: _dias,
      reviews: <Review>[
        Review(
          author: 'Clara',
          country: 'France',
          rating: 5,
          timeAgo: '1 month ago',
          text: 'Cheap, friendly and no tourist bus feeling.',
        ),
      ],
      availableDates: <String>['Wed, 8 Oct', 'Fri, 10 Oct', 'Sat, 11 Oct'],
      maxGuests: 8,
    ),
    Tour(
      id: 't7',
      title: 'Kok Tobe evening: the city from above',
      area: 'Kok Tobe hill',
      image: 'assets/images/koktobe.jpg',
      imageCredit: 'Photo: Wikimedia Commons, CC BY-SA 3.0',
      category: 'Culture',
      pricePerPerson: 35,
      rating: 4.9,
      reviewCount: 167,
      duration: 'Evening · 3 h',
      tags: <String>['Easy', 'Sunset', 'EN / RU / KZ', 'Small group', 'Cable car'],
      summary:
          'Cable car up, sunset over the city, and the stories behind the buildings '
          'you can see from the top. A good first evening in Almaty.',
      included: <String>['Cable car ticket both ways', 'Coffee at the top', 'City map with local spots'],
      route: <RouteStop>[
        RouteStop(time: '18:00', title: 'Meet at the cable car', note: 'Dostyk avenue.'),
        RouteStop(time: '18:20', title: 'Ride up', note: 'Best seats on the right.'),
        RouteStop(time: '19:00', title: 'Sunset viewpoint', note: 'City stories.'),
        RouteStop(time: '20:30', title: 'Back down', note: 'Dinner recommendations.'),
      ],
      facts: _easyFacts,
      guide: _madina,
      reviews: <Review>[
        Review(
          author: 'Tom',
          country: 'Netherlands',
          rating: 5,
          timeAgo: '4 days ago',
          text: 'Did this on my first evening. Everything after made more sense.',
        ),
      ],
      availableDates: <String>['Tue, 7 Oct', 'Wed, 8 Oct', 'Thu, 9 Oct', 'Fri, 10 Oct', 'Sat, 11 Oct'],
      maxGuests: 6,
    ),
  ];

  static Tour byId(String id) => tours.firstWhere((Tour t) => t.id == id);
}
