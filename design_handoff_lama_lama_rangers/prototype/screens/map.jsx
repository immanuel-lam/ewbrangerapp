// Map view — Lama Lama Rangers
// Satellite-look placeholder, sighting pins, zone polygons, layer toggle, FAB

function SatelliteBackdrop({ w = 375, h = 700 }) {
  // Procedural "satellite" feel — earth tones, stylized blobs, no real imagery
  return (
    <svg width="100%" height="100%" viewBox={`0 0 ${w} ${h}`} preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0 }}>
      <defs>
        <radialGradient id="land" cx="0.5" cy="0.4" r="0.9">
          <stop offset="0" stopColor="#6F6338"/>
          <stop offset="0.5" stopColor="#5B5028"/>
          <stop offset="1" stopColor="#3E3818"/>
        </radialGradient>
        <radialGradient id="canopy" cx="0.5" cy="0.5" r="0.5">
          <stop offset="0" stopColor="#3E5A33" stopOpacity="0.75"/>
          <stop offset="1" stopColor="#3E5A33" stopOpacity="0"/>
        </radialGradient>
        <linearGradient id="water" x1="0" y1="0" x2="1" y2="1">
          <stop offset="0" stopColor="#1F3A3E"/>
          <stop offset="1" stopColor="#2B4F50"/>
        </linearGradient>
        <pattern id="grain" width="3" height="3" patternUnits="userSpaceOnUse">
          <rect width="3" height="3" fill="transparent"/>
          <circle cx="1" cy="1" r="0.35" fill="#fff" opacity="0.04"/>
        </pattern>
      </defs>

      <rect width={w} height={h} fill="url(#land)"/>
      {/* river / water */}
      <path d={`M -10 ${h*0.65} C ${w*0.2} ${h*0.55}, ${w*0.35} ${h*0.7}, ${w*0.55} ${h*0.6} S ${w*0.9} ${h*0.78}, ${w+10} ${h*0.72} L ${w+10} ${h*0.85} C ${w*0.8} ${h*0.92}, ${w*0.4} ${h*0.82}, -10 ${h*0.9} Z`} fill="url(#water)"/>
      {/* coastline water strip bottom */}
      <path d={`M -10 ${h*0.94} L ${w+10} ${h*0.88} L ${w+10} ${h+10} L -10 ${h+10} Z`} fill="url(#water)"/>
      {/* canopy blobs */}
      {[[60,120,90],[220,90,70],[310,220,110],[80,340,130],[250,380,95],[180,510,100],[330,480,85],[40,600,80]].map(([cx,cy,r],i)=>(
        <circle key={i} cx={cx} cy={cy} r={r} fill="url(#canopy)"/>
      ))}
      {/* tracks */}
      <path d="M 0 200 C 80 210, 120 260, 200 250 S 360 240, 400 280" fill="none" stroke="#8A7A50" strokeWidth="1.2" opacity="0.4" strokeDasharray="3 4"/>
      <path d="M 40 430 C 100 410, 160 450, 220 430 S 320 470, 380 440" fill="none" stroke="#8A7A50" strokeWidth="1.2" opacity="0.4" strokeDasharray="3 4"/>
      <rect width={w} height={h} fill="url(#grain)"/>
    </svg>
  );
}

function MapPin({ x, y, variant, onClick, active }) {
  const v = T.variants.find(z => z.id === variant);
  return (
    <button onClick={onClick} style={{
      position: 'absolute', left: x, top: y, transform: 'translate(-50%, -100%)',
      background: 'none', border: 'none', padding: 0, cursor: 'pointer',
      filter: active ? 'drop-shadow(0 0 6px rgba(255,255,255,0.8))' : 'drop-shadow(0 2px 3px rgba(0,0,0,0.35))',
    }}>
      <svg width="26" height="34" viewBox="0 0 26 34">
        <path d="M13 33s-11-11-11-20a11 11 0 0122 0c0 9-11 20-11 20z" fill={v.hex} stroke="#FFF8EE" strokeWidth="2"/>
        <circle cx="13" cy="12" r="4" fill="rgba(255,255,255,0.95)"/>
      </svg>
    </button>
  );
}

function MapScreen({ onLogSighting, onOpenSighting }) {
  const [layers, setLayers] = React.useState({ sightings: true, zones: true, patrols: false });
  const [showLayerPanel, setShowLayerPanel] = React.useState(false);
  const [mapType, setMapType] = React.useState('satellite'); // satellite | standard
  const [selected, setSelected] = React.useState(null);

  // Fake pin positions
  const pins = [
    { id: 's01', x: 120, y: 230, variant: 'pink'   },
    { id: 's02', x: 220, y: 310, variant: 'red'    },
    { id: 's03', x: 280, y: 180, variant: 'orange' },
    { id: 's04', x: 90,  y: 420, variant: 'yellow' },
    { id: 's05', x: 310, y: 460, variant: 'pale'   },
    { id: 's06', x: 170, y: 360, variant: 'white'  },
    { id: 's07', x: 240, y: 420, variant: 'pink'   },
  ];

  const zones = [
    { d: 'M 80 200 L 160 210 L 180 270 L 120 290 L 70 260 Z', status: 'active' },
    { d: 'M 230 160 L 320 180 L 310 250 L 240 240 Z',          status: 'treat'  },
    { d: 'M 200 380 L 290 400 L 300 470 L 220 490 L 180 440 Z', status: 'active' },
    { d: 'M 60 400 L 130 410 L 140 470 L 80 480 Z',            status: 'cleared' },
    { d: 'M 300 440 L 360 450 L 360 500 L 310 505 Z',          status: 'treat'  },
  ];
  const zoneColor = { active: T.active, treat: T.treat, cleared: T.cleared };

  const baseColor = mapType === 'standard' ? '#E8DEC7' : '#2B2818';

  return (
    <div style={{ position: 'relative', height: '100%', overflow: 'hidden', background: baseColor }}>
      {mapType === 'satellite' ? <SatelliteBackdrop/> : (
        <svg width="100%" height="100%" viewBox="0 0 375 700" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0 }}>
          <rect width="375" height="700" fill="#E8DEC7"/>
          {/* roads / grid */}
          {Array.from({length: 8}).map((_, i) => (
            <line key={'h'+i} x1="0" x2="375" y1={i*90+40} y2={i*90+40} stroke="#D5C6A3" strokeWidth="1"/>
          ))}
          <path d="M 0 300 Q 190 280 375 340" fill="none" stroke="#C4B07C" strokeWidth="3"/>
          <path d="M 0 500 Q 200 480 375 520" fill="none" stroke="#C4B07C" strokeWidth="3"/>
          <path d="M 180 0 Q 200 350 150 700" fill="none" stroke="#C4B07C" strokeWidth="2"/>
        </svg>
      )}

      {/* Zone polygons */}
      {layers.zones && (
        <svg width="100%" height="100%" viewBox="0 0 375 700" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          {zones.map((z, i) => (
            <path key={i} d={z.d} fill={zoneColor[z.status]} fillOpacity="0.32" stroke={zoneColor[z.status]} strokeWidth="1.6" strokeDasharray="4 3"/>
          ))}
        </svg>
      )}

      {/* Patrols (dashed track) */}
      {layers.patrols && (
        <svg width="100%" height="100%" viewBox="0 0 375 700" preserveAspectRatio="xMidYMid slice" style={{ position: 'absolute', inset: 0, pointerEvents: 'none' }}>
          <path d="M 60 600 Q 140 540, 180 460 T 260 300 T 330 200" fill="none" stroke="#FFF8EE" strokeWidth="2.5" strokeDasharray="2 6" strokeLinecap="round" opacity="0.85"/>
          <circle cx="60" cy="600" r="5" fill={T.ochre} stroke="#FFF8EE" strokeWidth="2"/>
          <circle cx="330" cy="200" r="5" fill={T.euc} stroke="#FFF8EE" strokeWidth="2"/>
        </svg>
      )}

      {/* Pins */}
      {layers.sightings && pins.map(p => (
        <MapPin key={p.id} x={p.x} y={p.y} variant={p.variant} active={selected === p.id}
          onClick={() => setSelected(p.id)}/>
      ))}

      {/* Top chrome */}
      <div style={{ position: 'absolute', top: 54, left: 12, right: 12, display: 'flex', justifyContent: 'space-between', gap: 8, zIndex: 10 }}>
        <div style={{
          background: 'rgba(244,239,228,0.94)', backdropFilter: 'blur(6px)',
          border: `1px solid ${T.line}`, borderRadius: 12, padding: '8px 12px',
          fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink,
          boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
        }}>
          <div style={{ fontFamily: LLFONT, fontSize: 10, color: T.ink3, fontWeight: 600, letterSpacing: 0.6, textTransform: 'uppercase' }}>Port Stewart</div>
          14.49°S · 143.72°E
        </div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 6 }}>
          <button onClick={() => setMapType(m => m === 'satellite' ? 'standard' : 'satellite')} style={mapBtn}>
            <Icon name="layers" size={18} color={T.ink} strokeWidth={2}/>
          </button>
          <button onClick={() => setShowLayerPanel(s => !s)} style={{ ...mapBtn, background: showLayerPanel ? T.euc : 'rgba(244,239,228,0.94)', color: showLayerPanel ? '#FFF8EE' : T.ink }}>
            <Icon name="filter" size={18} color={showLayerPanel ? '#FFF8EE' : T.ink} strokeWidth={2}/>
          </button>
        </div>
      </div>

      {/* Layer panel */}
      {showLayerPanel && (
        <div style={{
          position: 'absolute', top: 104, right: 12, zIndex: 11,
          background: T.card, borderRadius: 14, padding: 10, minWidth: 178,
          border: `1px solid ${T.line}`, boxShadow: '0 6px 18px rgba(0,0,0,0.18)',
        }}>
          <div style={{ fontFamily: LLFONT, fontSize: 10, color: T.ink3, fontWeight: 600, letterSpacing: 0.6, textTransform: 'uppercase', padding: '2px 4px 8px' }}>Layers</div>
          {[
            { id: 'sightings', label: 'Sightings' },
            { id: 'zones',     label: 'Zones' },
            { id: 'patrols',   label: 'Patrol routes' },
          ].map(l => (
            <button key={l.id} onClick={() => setLayers(s => ({ ...s, [l.id]: !s[l.id] }))} style={{
              display: 'flex', alignItems: 'center', gap: 10, padding: '8px 4px',
              width: '100%', background: 'none', border: 'none', cursor: 'pointer',
            }}>
              <div style={{
                width: 20, height: 20, borderRadius: 6,
                background: layers[l.id] ? T.euc : 'transparent',
                border: `1.5px solid ${layers[l.id] ? T.euc : T.lineStrong}`,
                display: 'flex', alignItems: 'center', justifyContent: 'center',
              }}>
                {layers[l.id] && <Icon name="check" size={14} color="#FFF8EE" strokeWidth={3}/>}
              </div>
              <span style={{ fontFamily: LLFONT, fontSize: 14, color: T.ink }}>{l.label}</span>
            </button>
          ))}
        </div>
      )}

      {/* Selected pin card */}
      {selected && (() => {
        const s = SEED_SIGHTINGS.find(x => x.id === selected);
        if (!s) return null;
        const v = T.variants.find(x => x.id === s.variant);
        const r = RANGERS.find(x => x.id === s.ranger);
        return (
          <div style={{ position: 'absolute', left: 12, right: 12, bottom: 100, zIndex: 12 }}>
            <Card pad={14} style={{ boxShadow: '0 8px 24px rgba(0,0,0,0.24)' }}>
              <div style={{ display: 'flex', alignItems: 'flex-start', gap: 10 }}>
                <div style={{ width: 40, height: 40, borderRadius: 12, background: v.hex, flexShrink: 0, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                  <Icon name="leaf" size={20} color="#FFF" strokeWidth={2}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 15, color: T.ink }}>{v.name}</div>
                  <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3, marginTop: 1 }}>{s.zone} · {s.size} · {r.name}</div>
                </div>
                <button onClick={() => setSelected(null)} style={{ background: 'none', border: 'none', cursor: 'pointer', padding: 4, marginTop: -2, marginRight: -4 }}>
                  <Icon name="x" size={18} color={T.ink3}/>
                </button>
              </div>
              <button onClick={() => onOpenSighting(s.id)} style={{ marginTop: 10, width: '100%', background: T.eucSoft, color: T.euc, border: 'none', borderRadius: 10, padding: '10px 12px', fontFamily: LLFONTD, fontWeight: 600, fontSize: 14, cursor: 'pointer' }}>Open details</button>
            </Card>
          </div>
        );
      })()}

      {/* FAB */}
      <button onClick={onLogSighting} style={{
        position: 'absolute', right: 16, bottom: 100, zIndex: 10,
        width: 60, height: 60, borderRadius: 60,
        background: T.ochre, color: '#FFF8EE',
        border: `1.5px solid ${T.ochreDeep}`,
        display: 'flex', alignItems: 'center', justifyContent: 'center',
        boxShadow: '0 6px 20px rgba(155,79,28,0.45), 0 2px 4px rgba(0,0,0,0.12)',
        cursor: 'pointer',
      }}>
        <Icon name="plus" size={30} color="#FFF8EE" strokeWidth={2.4}/>
      </button>

      {/* Legend strip */}
      <div style={{ position: 'absolute', bottom: 100, left: 16, zIndex: 9, display: 'flex', gap: 6, flexDirection: 'column' }}>
        {['active','treat','cleared'].map(k => (
          <div key={k} style={{ background: 'rgba(244,239,228,0.94)', padding: '3px 7px', borderRadius: 999, fontFamily: LLFONT, fontSize: 10, fontWeight: 600, color: T.ink, display: 'flex', alignItems: 'center', gap: 5, border: `1px solid ${T.line}` }}>
            <span style={{ width: 7, height: 7, borderRadius: 7, background: zoneColor[k] }}/>
            {k === 'active' ? 'Active' : k === 'treat' ? 'Treating' : 'Cleared'}
          </div>
        ))}
      </div>
    </div>
  );
}

const mapBtn = {
  width: 38, height: 38, borderRadius: 10,
  background: 'rgba(244,239,228,0.94)', backdropFilter: 'blur(6px)',
  border: `1px solid rgba(58,50,32,0.12)`,
  display: 'flex', alignItems: 'center', justifyContent: 'center',
  cursor: 'pointer', boxShadow: '0 2px 6px rgba(0,0,0,0.15)',
};

window.MapScreen = MapScreen;
