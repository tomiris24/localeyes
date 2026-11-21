import { Router } from 'express';

import { LocalPerson } from '../models/local_person.js';
import { MeetupRequest } from '../models/meetup_request.js';

export const localsRouter = Router();

// GET /api/locals?availability=today&area=Medeu&interest=Coffee
localsRouter.get('/', async (req, res) => {
  const { availability, area, interest } = req.query;
  const filter = {};
  if (availability) filter.availability = availability;
  if (area && area !== 'All areas') filter.neighbourhood = area;
  if (interest) filter.interests = interest;
  const people = await LocalPerson.find(filter).sort({ id: 1 }).lean();
  res.json(people);
});

localsRouter.get('/:id', async (req, res) => {
  const person = await LocalPerson.findOne({ id: req.params.id }).lean();
  if (!person) return res.status(404).json({ error: 'Local not found' });
  res.json(person);
});

// The meetup form posts here; the local answers it in a later milestone.
localsRouter.post('/:id/meetups', async (req, res) => {
  const person = await LocalPerson.findOne({ id: req.params.id }).lean();
  if (!person) return res.status(404).json({ error: 'Local not found' });

  const { travellerName, when, meetingPlace, message } = req.body ?? {};
  if (!travellerName) {
    return res.status(400).json({ error: 'travellerName is required' });
  }

  const request = await MeetupRequest.create({
    localId: person.id,
    travellerName,
    when,
    meetingPlace,
    message,
  });
  res.status(201).json(request.toObject());
});

localsRouter.get('/:id/meetups', async (req, res) => {
  const requests = await MeetupRequest.find({ localId: req.params.id })
    .sort({ createdAt: -1 })
    .lean();
  res.json(requests);
});
