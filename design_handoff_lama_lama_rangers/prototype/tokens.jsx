// Design tokens — Lama Lama Rangers
// Earthy field-ops palette, SF Pro system type

const T = {
  // surfaces
  paper: '#F4EFE4',          // sunbleached parchment
  paperDeep: '#EAE1D0',      // shaded parchment
  card: '#FFFBF2',           // elevated card
  line: 'rgba(58, 50, 32, 0.12)',
  lineStrong: 'rgba(58, 50, 32, 0.22)',

  // primary: deep eucalyptus
  euc: '#2E4634',
  eucDark: '#1E2F22',
  eucLight: '#4A6951',
  eucSoft: '#DCE3D8',

  // ochre accent
  ochre: '#C26A2A',          // burnt ochre, used for CTAs
  ochreDeep: '#9B4F1C',
  ochreSoft: '#F3DEC5',

  // bark
  bark: '#5A4632',
  barkSoft: '#A89178',

  // status
  active: '#B8322A',         // infestation red (muted, not alarm)
  activeSoft: '#F2D7D3',
  treat: '#C89231',          // amber
  treatSoft: '#F5E2BE',
  cleared: '#4A7A4A',        // cleared green
  clearedSoft: '#D6E4CF',

  // sync
  synced: '#4A7A4A',
  pending: '#C89231',
  conflict: '#B8322A',

  // ink
  ink: '#1F1A10',
  ink2: '#3A3220',
  ink3: '#6B5F4A',
  inkMute: '#8F8471',

  // variants (Lantana) — name + dot color
  variants: [
    { id: 'pink',   name: 'Common Pink',   hex: '#D46E8E' },
    { id: 'orange', name: 'Common Orange', hex: '#E08A3C' },
    { id: 'red',    name: 'Common Red',    hex: '#B8322A' },
    { id: 'yellow', name: 'Common Yellow', hex: '#D9B03A' },
    { id: 'white',  name: 'White Sage',    hex: '#E8DFCE' },
    { id: 'pale',   name: 'Pale Pink',     hex: '#E8B6B9' },
  ],
};

const font = '-apple-system, "SF Pro Text", "SF Pro", system-ui, sans-serif';
const fontD = '-apple-system, "SF Pro Display", "SF Pro", system-ui, sans-serif';
const fontR = '-apple-system, "SF Pro Rounded", "SF Pro", system-ui, sans-serif';

window.T = T;
window.LLFONT = font;
window.LLFONTD = fontD;
window.LLFONTR = fontR;

// Seeded demo data — stable across renders
const RANGERS = [
  { id: 'r1', name: 'Aunty Maureen', role: 'Senior Ranger', initials: 'AM', tone: '#9B4F1C' },
  { id: 'r2', name: 'Jarrah T.',     role: 'Ranger',        initials: 'JT', tone: '#2E4634' },
  { id: 'r3', name: 'Kiri M.',       role: 'Ranger',        initials: 'KM', tone: '#C26A2A' },
  { id: 'r4', name: 'Daniel B.',     role: 'Ranger',        initials: 'DB', tone: '#5A4632' },
  { id: 'r5', name: 'Yindi L.',      role: 'Trainee',       initials: 'YL', tone: '#4A7A4A' },
];

const ZONES = [
  { id: 'z1', name: 'Running Creek',    status: 'active',   area: '3.2 ha', variant: 'pink' },
  { id: 'z2', name: 'Port Stewart N.',  status: 'treat',    area: '1.8 ha', variant: 'orange' },
  { id: 'z3', name: 'Bromley Rd',       status: 'active',   area: '5.4 ha', variant: 'red' },
  { id: 'z4', name: 'Marina Plains',    status: 'cleared',  area: '2.1 ha', variant: 'yellow' },
  { id: 'z5', name: 'Coen River bend',  status: 'treat',    area: '0.9 ha', variant: 'pale' },
];

const SEED_SIGHTINGS = [
  { id: 's01', variant: 'pink',   ranger: 'r1', when: '2h ago',  zone: 'Running Creek',   size: 'Medium', sync: 'synced',   lat: -14.4912, lng: 143.7204, notes: 'Thick patch near the crossing, flowering.' },
  { id: 's02', variant: 'red',    ranger: 'r2', when: '5h ago',  zone: 'Bromley Rd',      size: 'Large',  sync: 'pending',  lat: -14.5018, lng: 143.7112, notes: 'Spread along the fence line.' },
  { id: 's03', variant: 'orange', ranger: 'r3', when: '1d ago',  zone: 'Port Stewart N.', size: 'Small',  sync: 'synced',   lat: -14.4836, lng: 143.7289, notes: 'Small clump, three plants.' },
  { id: 's04', variant: 'yellow', ranger: 'r1', when: '2d ago',  zone: 'Marina Plains',   size: 'Medium', sync: 'conflict', lat: -14.5101, lng: 143.7015, notes: 'Re-emergence in cleared zone — flag for review.' },
  { id: 's05', variant: 'pale',   ranger: 'r4', when: '3d ago',  zone: 'Coen River bend', size: 'Small',  sync: 'synced',   lat: -14.4788, lng: 143.6947, notes: '' },
  { id: 's06', variant: 'white',  ranger: 'r2', when: '4d ago',  zone: 'Running Creek',   size: 'Medium', sync: 'synced',   lat: -14.4925, lng: 143.7241, notes: 'Near old camp.' },
  { id: 's07', variant: 'pink',   ranger: 'r5', when: '6d ago',  zone: 'Bromley Rd',      size: 'Small',  sync: 'synced',   lat: -14.5033, lng: 143.7132, notes: '' },
];

const TASKS = [
  { id: 't1', title: 'Spray Running Creek west bank',     priority: 'high',   due: 'Today',    assigned: 'r2', done: false },
  { id: 't2', title: 'Re-survey Marina Plains zone',      priority: 'high',   due: 'Tomorrow', assigned: 'r1', done: false },
  { id: 't3', title: 'Refill tanks at the shed',          priority: 'med',    due: 'Wed',      assigned: 'r3', done: false },
  { id: 't4', title: 'Photograph flowering at Coen bend', priority: 'low',    due: 'Fri',      assigned: 'r5', done: false },
  { id: 't5', title: 'Check quad bike oil',               priority: 'med',    due: 'Mon',      assigned: 'r4', done: true  },
];

const HERBS = [
  { id: 'h1', name: 'Grazon Extra',      kind: 'Selective',     stock: 0.72, unit: 'L', total: 20 },
  { id: 'h2', name: 'Glyphosate 360',    kind: 'Non-selective', stock: 0.18, unit: 'L', total: 25 },
  { id: 'h3', name: 'Access',            kind: 'Basal bark',    stock: 0.41, unit: 'L', total: 10 },
  { id: 'h4', name: 'Brush-Off',         kind: 'Selective',     stock: 0.88, unit: 'kg', total: 2  },
  { id: 'h5', name: 'Dye marker blue',   kind: 'Additive',      stock: 0.09, unit: 'L', total: 5  },
];

const PEERS = [
  { id: 'p1', name: "Aunty Maureen's iPad", initials: 'AM', records: 14 },
  { id: 'p2', name: "Jarrah's phone",       initials: 'JT', records: 7  },
  { id: 'p3', name: "Ranger Ute tablet",    initials: 'UT', records: 3  },
];

window.RANGERS = RANGERS;
window.ZONES = ZONES;
window.SEED_SIGHTINGS = SEED_SIGHTINGS;
window.TASKS = TASKS;
window.HERBS = HERBS;
window.PEERS = PEERS;
