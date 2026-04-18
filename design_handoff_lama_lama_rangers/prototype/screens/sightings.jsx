// Log new sighting (bottom sheet) + Sightings list + Sighting detail

function LogSightingSheet({ open, onClose, ranger, onSubmit }) {
  const [variant, setVariant] = React.useState(null);
  const [size, setSize] = React.useState(null);
  const [notes, setNotes] = React.useState('');
  const [photos, setPhotos] = React.useState([0]); // indexes
  const canSubmit = variant && size;

  React.useEffect(() => { if (open) { setVariant(null); setSize(null); setNotes(''); setPhotos([0]); } }, [open]);

  if (!open) return null;
  return (
    <div style={{ position: 'absolute', inset: 0, zIndex: 80 }}>
      <div onClick={onClose} style={{ position: 'absolute', inset: 0, background: 'rgba(30,25,10,0.45)', animation: 'llFade 0.18s ease' }}/>
      <div style={{
        position: 'absolute', left: 0, right: 0, bottom: 0,
        background: T.paper, borderRadius: '22px 22px 0 0',
        maxHeight: '92%', display: 'flex', flexDirection: 'column',
        animation: 'llSlide 0.28s ease',
        boxShadow: '0 -8px 24px rgba(0,0,0,0.22)',
      }}>
        <style>{`
          @keyframes llFade { from{opacity:0} to{opacity:1} }
          @keyframes llSlide { from{transform:translateY(100%)} to{transform:translateY(0)} }
        `}</style>
        <div style={{ display: 'flex', justifyContent: 'center', padding: '8px 0 0' }}>
          <div style={{ width: 40, height: 4, background: T.lineStrong, borderRadius: 4 }}/>
        </div>
        <div style={{ display: 'flex', alignItems: 'center', justifyContent: 'space-between', padding: '10px 16px 8px' }}>
          <button onClick={onClose} style={{ background: 'none', border: 'none', color: T.euc, fontFamily: LLFONT, fontSize: 15, cursor: 'pointer', padding: 0 }}>Cancel</button>
          <div style={{ fontFamily: LLFONTD, fontSize: 16, fontWeight: 700, color: T.ink }}>Log sighting</div>
          <div style={{ width: 48 }}/>
        </div>

        <div style={{ overflowY: 'auto', padding: '8px 16px 16px', flex: 1 }}>
          {/* GPS badge */}
          <div style={{ display: 'flex', alignItems: 'center', gap: 10, padding: '10px 12px', background: T.eucSoft, borderRadius: 12, marginBottom: 14 }}>
            <Icon name="target" size={20} color={T.euc} strokeWidth={2}/>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace', fontSize: 13, color: T.ink, fontWeight: 600 }}>−14.4912, 143.7204</div>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>GPS captured · accuracy ±4 m</div>
            </div>
            <div style={{ padding: '4px 8px', background: T.clearedSoft, color: T.cleared, borderRadius: 999, fontFamily: LLFONT, fontSize: 10, fontWeight: 700, letterSpacing: 0.3, textTransform: 'uppercase' }}>Good</div>
          </div>

          {/* Variant picker */}
          <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink, marginBottom: 8 }}>Variant</div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8, marginBottom: 18 }}>
            {T.variants.map(v => {
              const on = variant === v.id;
              return (
                <button key={v.id} onClick={() => setVariant(v.id)} style={{
                  padding: '10px 8px', borderRadius: 12, background: on ? v.hex : T.card,
                  border: `1.5px solid ${on ? v.hex : T.line}`,
                  display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 6,
                  cursor: 'pointer',
                }}>
                  <span style={{ width: 22, height: 22, borderRadius: 22, background: v.hex, boxShadow: `0 0 0 2px ${on ? v.hex : T.paper}, 0 0 0 3px ${on ? '#FFF8EE' : T.line}` }}/>
                  <span style={{ fontFamily: LLFONT, fontSize: 11, fontWeight: 600, color: on ? '#FFF8EE' : T.ink2, textAlign: 'center', lineHeight: 1.1 }}>{v.name}</span>
                </button>
              );
            })}
          </div>

          {/* Size picker */}
          <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink, marginBottom: 8 }}>Infestation size</div>
          <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
            {[
              { id: 'Small',  sub: '<1m²'    },
              { id: 'Medium', sub: '1–10m²'  },
              { id: 'Large',  sub: '>10m²'   },
            ].map(s => {
              const on = size === s.id;
              return (
                <button key={s.id} onClick={() => setSize(s.id)} style={{
                  flex: 1, padding: '10px 6px', borderRadius: 12,
                  background: on ? T.euc : T.card,
                  border: `1.5px solid ${on ? T.euc : T.line}`,
                  display: 'flex', flexDirection: 'column', gap: 2, cursor: 'pointer',
                }}>
                  <span style={{ fontFamily: LLFONTD, fontSize: 14, fontWeight: 700, color: on ? '#FFF8EE' : T.ink }}>{s.id}</span>
                  <span style={{ fontFamily: LLFONT, fontSize: 11, color: on ? 'rgba(255,248,238,0.7)' : T.ink3 }}>{s.sub}</span>
                </button>
              );
            })}
          </div>

          {/* Photos */}
          <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink, marginBottom: 8 }}>Photos · {photos.length}/3</div>
          <div style={{ display: 'flex', gap: 8, marginBottom: 18 }}>
            {photos.map((p, i) => (
              <Placeholder key={i} w="30%" h={86} label="photo" radius={12} tint="#D6D1BC"/>
            ))}
            {photos.length < 3 && (
              <button onClick={() => setPhotos(p => [...p, p.length])} style={{
                flex: 1, height: 86, borderRadius: 12, background: 'transparent',
                border: `1.5px dashed ${T.lineStrong}`, display: 'flex', flexDirection: 'column',
                alignItems: 'center', justifyContent: 'center', gap: 3, cursor: 'pointer',
                color: T.ink3,
              }}>
                <Icon name="camera" size={22} color={T.ink3}/>
                <span style={{ fontFamily: LLFONT, fontSize: 11, fontWeight: 600 }}>Take photo</span>
              </button>
            )}
          </div>

          {/* Notes */}
          <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink, marginBottom: 8 }}>Notes</div>
          <textarea value={notes} onChange={e => setNotes(e.target.value)} placeholder="What did you see? Any signs of flowering, seed, or treatment?" style={{
            width: '100%', minHeight: 76, padding: 12, borderRadius: 12,
            background: T.card, border: `1px solid ${T.line}`, resize: 'none',
            fontFamily: LLFONT, fontSize: 14, color: T.ink, outline: 'none',
            boxSizing: 'border-box',
          }}/>

          <div style={{ height: 16 }}/>
          <Btn kind={canSubmit ? 'primary' : 'ghost'} onClick={() => canSubmit && onSubmit({ variant, size, notes })} style={{ opacity: canSubmit ? 1 : 0.55 }}>
            Submit sighting
          </Btn>
          <div style={{ textAlign: 'center', fontFamily: LLFONT, fontSize: 11, color: T.ink3, marginTop: 8 }}>
            <Icon name="wifi-off" size={12} color={T.ink3} strokeWidth={2}/> &nbsp;Saved locally, will sync later
          </div>
        </div>
      </div>
    </div>
  );
}

function SightingsListScreen({ sightings, onOpen }) {
  const [fVariant, setFVariant] = React.useState('all');
  const [fRanger, setFRanger] = React.useState('all');

  const filtered = sightings.filter(s =>
    (fVariant === 'all' || s.variant === fVariant) &&
    (fRanger === 'all' || s.ranger === fRanger)
  );

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <div style={{ padding: '54px 20px 8px' }}>
        <div style={{ fontFamily: LLFONTD, fontSize: 28, fontWeight: 700, color: T.ink, letterSpacing: -0.6 }}>Sightings</div>
        <div style={{ fontFamily: LLFONT, fontSize: 13, color: T.ink3, marginTop: 2 }}>{filtered.length} records · {sightings.filter(s => s.sync !== 'synced').length} not yet synced</div>
      </div>

      {/* Filter bar */}
      <div style={{ padding: '8px 0 10px', overflowX: 'auto', display: 'flex', gap: 6, whiteSpace: 'nowrap', scrollbarWidth: 'none' }}>
        <div style={{ width: 16, flexShrink: 0 }}/>
        <Chip active={fVariant === 'all' && fRanger === 'all'} onClick={() => { setFVariant('all'); setFRanger('all'); }}>All</Chip>
        {T.variants.map(v => (
          <button key={v.id} onClick={() => setFVariant(fVariant === v.id ? 'all' : v.id)} style={{
            padding: '8px 12px', borderRadius: 999, background: fVariant === v.id ? v.hex : '#FFF8EC',
            color: fVariant === v.id ? '#FFF' : T.ink2, border: `1px solid ${fVariant === v.id ? v.hex : T.line}`,
            fontFamily: LLFONT, fontWeight: 600, fontSize: 13, cursor: 'pointer', display: 'flex', alignItems: 'center', gap: 6, flexShrink: 0,
          }}>
            <span style={{ width: 10, height: 10, borderRadius: 10, background: v.hex, boxShadow: fVariant === v.id ? 'inset 0 0 0 1.5px #FFF' : 'none' }}/>
            {v.name}
          </button>
        ))}
        <div style={{ width: 16, flexShrink: 0 }}/>
      </div>

      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {filtered.map(s => {
          const v = T.variants.find(x => x.id === s.variant);
          const r = RANGERS.find(x => x.id === s.ranger);
          return (
            <Card key={s.id} pad={0} onClick={() => onOpen(s.id)}>
              <div style={{ display: 'flex', alignItems: 'stretch' }}>
                <div style={{ width: 5, background: v.hex, borderRadius: '18px 0 0 18px', flexShrink: 0 }}/>
                <div style={{ flex: 1, padding: '12px 14px', display: 'flex', alignItems: 'center', gap: 12 }}>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ display: 'flex', alignItems: 'center', gap: 8, marginBottom: 2 }}>
                      <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 15, color: T.ink }}>{v.name}</div>
                      <div style={{ padding: '1px 7px', background: T.paperDeep, borderRadius: 999, fontFamily: LLFONT, fontSize: 10, color: T.ink3, fontWeight: 600 }}>{s.size}</div>
                    </div>
                    <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>
                      {r.name} · {s.zone} · {s.when}
                    </div>
                  </div>
                  <SyncBadge status={s.sync}/>
                </div>
              </div>
            </Card>
          );
        })}
        {filtered.length === 0 && (
          <div style={{ textAlign: 'center', padding: 40, color: T.ink3, fontFamily: LLFONT }}>No sightings match</div>
        )}
      </div>
    </div>
  );
}

function SightingDetailScreen({ id, onBack }) {
  const s = SEED_SIGHTINGS.find(x => x.id === id) || SEED_SIGHTINGS[0];
  const v = T.variants.find(x => x.id === s.variant);
  const r = RANGERS.find(x => x.id === s.ranger);
  const [treatOpen, setTreatOpen] = React.useState(true);
  const treatments = [
    { date: '12 Apr', method: 'Foliar spray · Grazon', by: 'Jarrah T.' },
    { date: '29 Mar', method: 'Cut-stump · Access',    by: 'Aunty Maureen' },
  ];

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <TopBar title="Sighting" left={<IconBtn name="chev-left" onClick={onBack}/>} right={<IconBtn name="more"/>}/>

      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* Map thumb */}
        <div style={{ position: 'relative', height: 140, borderRadius: 16, overflow: 'hidden', border: `1px solid ${T.line}` }}>
          <div style={{ position: 'absolute', inset: 0 }}>
            <SatelliteBackdrop w={375} h={140}/>
          </div>
          <div style={{ position: 'absolute', left: '50%', top: '50%', transform: 'translate(-50%, -100%)' }}>
            <svg width="28" height="36" viewBox="0 0 26 34">
              <path d="M13 33s-11-11-11-20a11 11 0 0122 0c0 9-11 20-11 20z" fill={v.hex} stroke="#FFF8EE" strokeWidth="2"/>
              <circle cx="13" cy="12" r="4" fill="#FFF"/>
            </svg>
          </div>
        </div>

        {/* Main facts */}
        <Card>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 8 }}>
            <div style={{ width: 44, height: 44, borderRadius: 14, background: v.hex, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
              <Icon name="leaf" size={22} color="#FFF" strokeWidth={2}/>
            </div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 18, color: T.ink, letterSpacing: -0.3 }}>{v.name}</div>
              <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>{s.size} infestation · {s.zone}</div>
            </div>
            <SyncBadge status={s.sync}/>
          </div>
          <div style={{ borderTop: `0.5px solid ${T.line}`, paddingTop: 10, display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
            <Fact label="Logged by" value={r.name}/>
            <Fact label="When" value={s.when}/>
            <Fact label="GPS" value={`${s.lat.toFixed(4)}, ${s.lng.toFixed(4)}`} mono/>
            <Fact label="Accuracy" value="±4 m"/>
          </div>
          {s.notes && (
            <div style={{ marginTop: 12, padding: 12, background: T.paperDeep, borderRadius: 10, fontFamily: LLFONT, fontSize: 13.5, color: T.ink2, lineHeight: 1.4 }}>
              {s.notes}
            </div>
          )}
        </Card>

        {/* Treatments accordion */}
        <Card pad={0}>
          <button onClick={() => setTreatOpen(o => !o)} style={{ width: '100%', padding: 14, background: 'none', border: 'none', display: 'flex', alignItems: 'center', cursor: 'pointer' }}>
            <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 15, color: T.ink, flex: 1, textAlign: 'left' }}>Treatments · {treatments.length}</div>
            <Icon name={treatOpen ? 'chev-down' : 'chev-right'} size={18} color={T.ink3}/>
          </button>
          {treatOpen && (
            <div>
              {treatments.map((t, i) => (
                <div key={i} style={{ padding: '12px 14px', borderTop: `0.5px solid ${T.line}`, display: 'flex', alignItems: 'center', gap: 10 }}>
                  <div style={{ width: 36, height: 36, borderRadius: 10, background: T.eucSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                    <Icon name="drop" size={18} color={T.euc} strokeWidth={2}/>
                  </div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: LLFONTD, fontWeight: 600, fontSize: 14, color: T.ink }}>{t.method}</div>
                    <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>{t.date} · {t.by}</div>
                  </div>
                </div>
              ))}
              <div style={{ padding: 12, borderTop: `0.5px solid ${T.line}` }}>
                <Btn kind="ghost" icon="plus">Add treatment</Btn>
              </div>
            </div>
          )}
        </Card>
      </div>
    </div>
  );
}

function Fact({ label, value, mono }) {
  return (
    <div>
      <div style={{ fontFamily: LLFONT, fontSize: 10.5, color: T.ink3, fontWeight: 600, letterSpacing: 0.4, textTransform: 'uppercase' }}>{label}</div>
      <div style={{ fontFamily: mono ? 'ui-monospace, "SF Mono", Menlo, monospace' : LLFONTD, fontSize: 14, color: T.ink, fontWeight: 600, marginTop: 1 }}>{value}</div>
    </div>
  );
}

window.LogSightingSheet = LogSightingSheet;
window.SightingsListScreen = SightingsListScreen;
window.SightingDetailScreen = SightingDetailScreen;
