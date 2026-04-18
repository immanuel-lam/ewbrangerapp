// Tasks, Patrol, Mesh Sync, More menu

function TasksScreen({ onBack }) {
  const [tasks, setTasks] = React.useState(TASKS);
  const [swipe, setSwipe] = React.useState(null);

  const toggle = (id) => setTasks(t => t.map(x => x.id === id ? { ...x, done: !x.done } : x));

  const pr = {
    high: { bg: T.activeSoft, fg: T.active, label: 'High' },
    med:  { bg: T.treatSoft,  fg: T.treat,  label: 'Med' },
    low:  { bg: T.eucSoft,    fg: T.euc,    label: 'Low' },
  };

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <TopBar title="Tasks" left={<IconBtn name="chev-left" onClick={onBack}/>} right={<IconBtn name="plus"/>}/>
      <div style={{ padding: '0 16px 10px', display: 'flex', gap: 6 }}>
        <Chip active>All · {tasks.filter(t => !t.done).length}</Chip>
        <Chip>Mine</Chip>
        <Chip>Done</Chip>
      </div>
      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 8 }}>
        {tasks.map(t => {
          const p = pr[t.priority];
          const r = RANGERS.find(x => x.id === t.assigned);
          const open = swipe === t.id;
          return (
            <div key={t.id} style={{ position: 'relative', borderRadius: 16, overflow: 'hidden' }}>
              <div style={{ position: 'absolute', inset: 0, background: T.cleared, display: 'flex', alignItems: 'center', justifyContent: 'flex-end', paddingRight: 20, color: '#FFF', fontFamily: LLFONTD, fontWeight: 700, fontSize: 14, gap: 6 }}>
                <Icon name="check" size={18} color="#FFF" strokeWidth={2.5}/> Done
              </div>
              <div onClick={() => setSwipe(s => s === t.id ? null : t.id)} style={{
                position: 'relative', background: t.done ? T.paperDeep : T.card,
                border: `1px solid ${T.line}`, borderRadius: 16, padding: 14,
                transform: open ? 'translateX(-84px)' : 'translateX(0)',
                transition: 'transform 0.2s ease', cursor: 'pointer',
              }}>
                <div style={{ display: 'flex', alignItems: 'center', gap: 10 }}>
                  <button onClick={(e) => { e.stopPropagation(); toggle(t.id); }} style={{
                    width: 26, height: 26, borderRadius: 26,
                    background: t.done ? T.cleared : 'transparent',
                    border: `2px solid ${t.done ? T.cleared : T.lineStrong}`,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                    cursor: 'pointer', flexShrink: 0,
                  }}>
                    {t.done && <Icon name="check" size={14} color="#FFF" strokeWidth={3}/>}
                  </button>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontFamily: LLFONTD, fontWeight: 600, fontSize: 14.5, color: t.done ? T.ink3 : T.ink, textDecoration: t.done ? 'line-through' : 'none' }}>{t.title}</div>
                    <div style={{ display: 'flex', gap: 6, alignItems: 'center', marginTop: 5 }}>
                      <span style={{ padding: '2px 7px', background: p.bg, color: p.fg, borderRadius: 999, fontFamily: LLFONT, fontSize: 10.5, fontWeight: 700, letterSpacing: 0.2, textTransform: 'uppercase' }}>{p.label}</span>
                      <span style={{ padding: '2px 7px', background: T.paperDeep, color: T.ink3, borderRadius: 999, fontFamily: LLFONT, fontSize: 10.5, fontWeight: 600, display: 'inline-flex', alignItems: 'center', gap: 3 }}>
                        <Icon name="calendar" size={10} color={T.ink3} strokeWidth={2.4}/> {t.due}
                      </span>
                      <span style={{ padding: '2px 7px', background: T.paperDeep, color: T.ink3, borderRadius: 999, fontFamily: LLFONT, fontSize: 10.5, fontWeight: 600 }}>{r.initials}</span>
                    </div>
                  </div>
                </div>
              </div>
            </div>
          );
        })}
        <div style={{ textAlign: 'center', fontFamily: LLFONT, fontSize: 11, color: T.ink3, padding: 8 }}>
          ← Tap a card to reveal swipe action
        </div>
      </div>
    </div>
  );
}

function PatrolScreen({ ranger }) {
  const [active, setActive] = React.useState(false);
  const [elapsed, setElapsed] = React.useState(0);
  const [checks, setChecks] = React.useState({ water: false, fuel: false, radio: false, firstaid: false, sunscreen: false });
  const [zone, setZone] = React.useState('Running Creek');

  React.useEffect(() => {
    if (!active) return;
    const i = setInterval(() => setElapsed(e => e + 1), 1000);
    return () => clearInterval(i);
  }, [active]);

  const fmt = (s) => {
    const h = Math.floor(s/3600), m = Math.floor((s%3600)/60), sec = s%60;
    return `${String(h).padStart(2,'0')}:${String(m).padStart(2,'0')}:${String(sec).padStart(2,'0')}`;
  };

  const checklist = [
    { id: 'water',     label: 'Water — 4L per person' },
    { id: 'fuel',      label: 'Fuel — quad and ute'   },
    { id: 'radio',     label: 'UHF radio + spare battery' },
    { id: 'firstaid',  label: 'First aid kit'         },
    { id: 'sunscreen', label: 'Sunscreen + hat'       },
  ];
  const allChecked = Object.values(checks).every(Boolean);

  const days = ['M','T','W','T','F','S','S'];
  const patrolDots = [true, false, true, true, false, true, false]; // this week

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <div style={{ padding: '54px 20px 10px' }}>
        <div style={{ fontFamily: LLFONTD, fontSize: 28, fontWeight: 700, color: T.ink, letterSpacing: -0.6 }}>Patrol</div>
        <div style={{ fontFamily: LLFONT, fontSize: 13, color: T.ink3, marginTop: 2 }}>{active ? 'On country · tracking' : 'Ready to head out'}</div>
      </div>

      <div style={{ padding: '0 16px' }}>
        {/* Calendar strip */}
        <Card pad={12} style={{ marginBottom: 12 }}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
            <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 13, color: T.ink }}>This week</div>
            <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>4 patrols</div>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(7, 1fr)', gap: 4 }}>
            {days.map((d, i) => {
              const today = i === 3;
              return (
                <div key={i} style={{ display: 'flex', flexDirection: 'column', alignItems: 'center', gap: 4 }}>
                  <div style={{ fontFamily: LLFONT, fontSize: 10, color: T.ink3, fontWeight: 600 }}>{d}</div>
                  <div style={{
                    width: 32, height: 32, borderRadius: 10,
                    background: today ? T.euc : 'transparent',
                    border: today ? 'none' : `1px solid ${T.line}`,
                    color: today ? '#FFF8EE' : T.ink,
                    fontFamily: LLFONTD, fontSize: 13, fontWeight: 700,
                    display: 'flex', alignItems: 'center', justifyContent: 'center',
                  }}>{13+i}</div>
                  <div style={{ width: 5, height: 5, borderRadius: 5, background: patrolDots[i] ? T.ochre : 'transparent' }}/>
                </div>
              );
            })}
          </div>
        </Card>

        {!active && (
          <Card pad={16}>
            <div style={{ fontFamily: LLFONTD, fontSize: 16, fontWeight: 700, color: T.ink, marginBottom: 2 }}>Pre-departure checklist</div>
            <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3, marginBottom: 12 }}>Tick each one before you roll out</div>
            {checklist.map((c, i) => (
              <button key={c.id} onClick={() => setChecks(s => ({ ...s, [c.id]: !s[c.id] }))} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '10px 2px',
                width: '100%', background: 'none', border: 'none', cursor: 'pointer',
                borderTop: i ? `0.5px solid ${T.line}` : 'none', textAlign: 'left',
              }}>
                <div style={{
                  width: 24, height: 24, borderRadius: 7,
                  background: checks[c.id] ? T.euc : 'transparent',
                  border: `1.5px solid ${checks[c.id] ? T.euc : T.lineStrong}`,
                  display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0,
                }}>
                  {checks[c.id] && <Icon name="check" size={15} color="#FFF8EE" strokeWidth={3}/>}
                </div>
                <span style={{ fontFamily: LLFONT, fontSize: 14, color: T.ink }}>{c.label}</span>
              </button>
            ))}

            <div style={{ fontFamily: LLFONTD, fontSize: 12, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase', margin: '16px 0 6px' }}>Patrol area</div>
            <select value={zone} onChange={e => setZone(e.target.value)} style={{
              width: '100%', padding: '12px', borderRadius: 12, background: T.paperDeep,
              border: `1px solid ${T.line}`, fontFamily: LLFONT, fontSize: 14, color: T.ink,
              appearance: 'none', outline: 'none',
            }}>
              {ZONES.map(z => <option key={z.id}>{z.name}</option>)}
              <option>Free-text · other</option>
            </select>

            <div style={{ height: 14 }}/>
            <Btn kind={allChecked ? 'dark' : 'ghost'} icon="play" onClick={() => allChecked && setActive(true)} style={{ opacity: allChecked ? 1 : 0.5 }}>Start patrol</Btn>
          </Card>
        )}

        {active && (
          <Card pad={0} style={{ overflow: 'hidden' }}>
            <div style={{ background: T.euc, padding: '18px 16px', color: '#FFF8EE' }}>
              <div style={{ fontFamily: LLFONT, fontSize: 11, fontWeight: 600, letterSpacing: 1, textTransform: 'uppercase', opacity: 0.7 }}>On patrol · {zone}</div>
              <div style={{ fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace', fontSize: 42, fontWeight: 600, letterSpacing: -0.5, marginTop: 4 }}>{fmt(elapsed)}</div>
              <div style={{ display: 'flex', gap: 16, marginTop: 8, fontFamily: LLFONT, fontSize: 12, opacity: 0.85 }}>
                <span>2.1 km covered</span>
                <span>·</span>
                <span>3 sightings logged</span>
              </div>
            </div>
            <div style={{ padding: 14 }}>
              <div style={{ fontFamily: LLFONTD, fontSize: 12, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase', marginBottom: 6 }}>Field notes</div>
              <textarea placeholder="What's on country today?" style={{
                width: '100%', minHeight: 72, padding: 12, borderRadius: 12,
                background: T.paperDeep, border: `1px solid ${T.line}`, resize: 'none',
                fontFamily: LLFONT, fontSize: 14, color: T.ink, outline: 'none',
                boxSizing: 'border-box',
              }}/>
              <div style={{ height: 12 }}/>
              <Btn kind="danger" icon="stop" onClick={() => { setActive(false); setElapsed(0); }}>End patrol</Btn>
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}

function MeshSyncScreen({ onBack }) {
  const [phase, setPhase] = React.useState('discover'); // discover | syncing | conflict | done
  const [selected, setSelected] = React.useState(null);
  const [conflictChoice, setConflictChoice] = React.useState(null);

  React.useEffect(() => {
    if (phase === 'syncing') {
      const t = setTimeout(() => setPhase('conflict'), 2600);
      return () => clearTimeout(t);
    }
  }, [phase]);

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <TopBar title="End-of-day sync" left={<IconBtn name="chev-left" onClick={onBack}/>} sub="No internet needed · device-to-device"/>

      <div style={{ padding: '0 16px' }}>
        {/* Animated self + peers */}
        <Card pad={0} style={{ overflow: 'hidden' }}>
          <div style={{ background: T.eucDark, padding: '30px 16px 18px', position: 'relative', overflow: 'hidden' }}>
            {/* radiating waves */}
            {(phase === 'discover' || phase === 'syncing') && (
              <>
                <style>{`
                  @keyframes llPulse { 0%{transform:scale(0.4);opacity:0.7} 100%{transform:scale(2.2);opacity:0} }
                `}</style>
                {[0, 0.8, 1.6].map(d => (
                  <div key={d} style={{
                    position: 'absolute', top: 60, left: '50%', width: 100, height: 100,
                    borderRadius: 100, border: `2px solid ${T.ochre}`, marginLeft: -50,
                    animation: `llPulse 2.4s ${d}s infinite ease-out`, pointerEvents: 'none',
                  }}/>
                ))}
              </>
            )}
            <div style={{ textAlign: 'center', position: 'relative' }}>
              <div style={{ width: 76, height: 76, borderRadius: 76, background: T.ochre, margin: '0 auto', display: 'flex', alignItems: 'center', justifyContent: 'center', color: '#FFF8EE', fontFamily: LLFONTD, fontWeight: 700, fontSize: 22, border: '3px solid rgba(255,248,238,0.25)' }}>AM</div>
              <div style={{ fontFamily: LLFONTD, fontSize: 15, fontWeight: 700, color: '#FFF8EE', marginTop: 10 }}>This device</div>
              <div style={{ fontFamily: LLFONT, fontSize: 12, color: 'rgba(255,248,238,0.6)', marginTop: 2 }}>
                {phase === 'discover' && 'Looking for nearby rangers…'}
                {phase === 'syncing'  && 'Sharing records…'}
                {phase === 'conflict' && 'Review conflicts'}
                {phase === 'done'     && 'All caught up'}
              </div>
            </div>
          </div>

          {/* Peer list */}
          <div>
            {PEERS.map((p, i) => (
              <button key={p.id} onClick={() => phase === 'discover' && (setSelected(p.id), setPhase('syncing'))} disabled={phase !== 'discover'} style={{
                display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', width: '100%',
                background: 'none', border: 'none', borderTop: i ? `0.5px solid ${T.line}` : 'none',
                cursor: phase === 'discover' ? 'pointer' : 'default', textAlign: 'left',
              }}>
                <div style={{ width: 40, height: 40, borderRadius: 40, background: T.eucSoft, color: T.euc, display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: LLFONTD, fontWeight: 700, fontSize: 14 }}>{p.initials}</div>
                <div style={{ flex: 1 }}>
                  <div style={{ fontFamily: LLFONTD, fontWeight: 600, fontSize: 14, color: T.ink }}>{p.name}</div>
                  <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>{p.records} records to share</div>
                </div>
                {phase === 'syncing' && selected === p.id && (
                  <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ochre, fontWeight: 600, display: 'flex', alignItems: 'center', gap: 6 }}>
                    <span className="spin"><Icon name="sync" size={14} color={T.ochre} strokeWidth={2}/></span>
                    Syncing…
                    <style>{`.spin{display:inline-block;animation:llSpin 1.2s linear infinite}@keyframes llSpin{to{transform:rotate(360deg)}}`}</style>
                  </div>
                )}
                {phase === 'discover' && <Icon name="chev-right" size={18} color={T.ink3}/>}
              </button>
            ))}
          </div>
        </Card>

        {/* Conflict resolution */}
        {phase === 'conflict' && (
          <div style={{ marginTop: 14 }}>
            <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase', marginBottom: 8 }}>1 conflict · which version to keep?</div>
            <Card pad={0}>
              <div style={{ padding: '12px 14px', borderBottom: `0.5px solid ${T.line}` }}>
                <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 14, color: T.ink }}>Marina Plains sighting</div>
                <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>Both devices edited the size</div>
              </div>
              <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr' }}>
                {[
                  { id: 'mine',  label: 'Yours',  by: 'Aunty Maureen', when: '2h ago',  size: 'Medium', note: 'Re-emergence in cleared zone' },
                  { id: 'their', label: "Jarrah's", by: 'Jarrah T.',   when: '45m ago', size: 'Large',  note: 'Spread beyond original patch' },
                ].map((v, i) => {
                  const on = conflictChoice === v.id;
                  return (
                    <button key={v.id} onClick={() => setConflictChoice(v.id)} style={{
                      padding: 12, border: 'none', cursor: 'pointer', textAlign: 'left',
                      background: on ? T.eucSoft : T.card,
                      borderLeft: i ? `0.5px solid ${T.line}` : 'none',
                      borderTop: on ? `2px solid ${T.euc}` : '2px solid transparent',
                    }}>
                      <div style={{ fontFamily: LLFONT, fontSize: 10, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase' }}>{v.label}</div>
                      <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 20, color: T.ink, marginTop: 2 }}>{v.size}</div>
                      <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3, marginTop: 1 }}>{v.by} · {v.when}</div>
                      <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink2, marginTop: 8, lineHeight: 1.35 }}>{v.note}</div>
                    </button>
                  );
                })}
              </div>
              <div style={{ padding: 12, borderTop: `0.5px solid ${T.line}` }}>
                <Btn kind={conflictChoice ? 'primary' : 'ghost'} onClick={() => conflictChoice && setPhase('done')} style={{ opacity: conflictChoice ? 1 : 0.5 }}>Keep this version</Btn>
              </div>
            </Card>
          </div>
        )}

        {/* Summary */}
        {phase === 'done' && (
          <Card style={{ marginTop: 14 }}>
            <div style={{ display: 'flex', alignItems: 'center', gap: 10, marginBottom: 10 }}>
              <div style={{ width: 36, height: 36, borderRadius: 36, background: T.clearedSoft, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name="check" size={20} color={T.cleared} strokeWidth={2.5}/>
              </div>
              <div>
                <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 15, color: T.ink }}>All caught up</div>
                <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>Sync finished at 5:47 pm</div>
              </div>
            </div>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 8, marginTop: 6 }}>
              {[
                { n: 12, l: 'Sent'     },
                { n: 7,  l: 'Received' },
                { n: 1,  l: 'Resolved' },
              ].map(x => (
                <div key={x.l} style={{ padding: '12px 8px', background: T.paperDeep, borderRadius: 12, textAlign: 'center' }}>
                  <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 22, color: T.ink, letterSpacing: -0.5 }}>{x.n}</div>
                  <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>{x.l}</div>
                </div>
              ))}
            </div>
          </Card>
        )}
      </div>
    </div>
  );
}

function MoreScreen({ ranger, onGoto, onLogout }) {
  const items = [
    { id: 'sync',      label: 'Mesh sync',         icon: 'radio',    sub: '3 devices nearby', tint: T.ochreSoft,  color: T.ochre },
    { id: 'tasks',     label: 'Tasks',             icon: 'check',    sub: '4 open',           tint: T.eucSoft,    color: T.euc   },
    { id: 'inventory', label: 'Pesticide stock',   icon: 'drop',     sub: '2 items low',      tint: T.activeSoft, color: T.active},
    { id: 'detail',    label: 'Sighting history',  icon: 'eye',      sub: '7 records',        tint: T.paperDeep,  color: T.ink2  },
  ];

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <div style={{ padding: '54px 20px 12px' }}>
        <div style={{ fontFamily: LLFONTD, fontSize: 28, fontWeight: 700, color: T.ink, letterSpacing: -0.6 }}>More</div>
      </div>

      <div style={{ padding: '0 16px' }}>
        <Card pad={14} style={{ marginBottom: 14 }}>
          <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
            <div style={{ width: 48, height: 48, borderRadius: 48, background: ranger.tone, color: '#FFF8EE', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: LLFONTD, fontWeight: 700, fontSize: 17 }}>{ranger.initials}</div>
            <div style={{ flex: 1 }}>
              <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 16, color: T.ink }}>{ranger.name}</div>
              <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>{ranger.role} · Port Stewart</div>
            </div>
            <div style={{ display: 'flex', alignItems: 'center', gap: 4, padding: '4px 8px', background: T.treatSoft, color: T.treat, borderRadius: 999, fontFamily: LLFONT, fontSize: 11, fontWeight: 700 }}>
              <Icon name="wifi-off" size={12} color={T.treat} strokeWidth={2.4}/> Offline
            </div>
          </div>
        </Card>

        <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10, marginBottom: 14 }}>
          {items.map(x => (
            <button key={x.id} onClick={() => onGoto(x.id)} style={{
              background: T.card, border: `1px solid ${T.line}`, borderRadius: 16, padding: 14,
              display: 'flex', flexDirection: 'column', alignItems: 'flex-start', gap: 8,
              cursor: 'pointer', textAlign: 'left', minHeight: 110,
            }}>
              <div style={{ width: 38, height: 38, borderRadius: 12, background: x.tint, display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
                <Icon name={x.icon} size={20} color={x.color} strokeWidth={2}/>
              </div>
              <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 14, color: T.ink }}>{x.label}</div>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>{x.sub}</div>
            </button>
          ))}
        </div>

        <Card pad={0}>
          {[
            { label: 'Help & training videos', icon: 'book' },
            { label: 'About this app',        icon: 'user' },
          ].map((x, i) => (
            <div key={x.label} style={{ display: 'flex', alignItems: 'center', gap: 12, padding: '14px 16px', borderTop: i ? `0.5px solid ${T.line}` : 'none' }}>
              <Icon name={x.icon} size={20} color={T.ink2}/>
              <div style={{ flex: 1, fontFamily: LLFONT, fontSize: 15, color: T.ink }}>{x.label}</div>
              <Icon name="chev-right" size={16} color={T.ink3}/>
            </div>
          ))}
        </Card>

        <div style={{ marginTop: 16 }}>
          <Btn kind="ghost" onClick={onLogout}>Sign off</Btn>
        </div>
      </div>
    </div>
  );
}

window.TasksScreen = TasksScreen;
window.PatrolScreen = PatrolScreen;
window.MeshSyncScreen = MeshSyncScreen;
window.MoreScreen = MoreScreen;
