// Shared atoms — Lama Lama Rangers
// Icons (line-based SVG), Badges, Buttons, Chips, TopBar, TabBar, Placeholders

// ─── Icons ────────────────────────────────────────────────
const Icon = ({ name, size = 22, color = 'currentColor', strokeWidth = 1.8 }) => {
  const s = { width: size, height: size, display: 'block', flexShrink: 0 };
  const p = { fill: 'none', stroke: color, strokeWidth, strokeLinecap: 'round', strokeLinejoin: 'round' };
  switch (name) {
    case 'map':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M3 6l6-2 6 2 6-2v14l-6 2-6-2-6 2V6zM9 4v16M15 6v16"/></svg>;
    case 'eye':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M2 12s3.5-7 10-7 10 7 10 7-3.5 7-10 7-10-7-10-7z"/><circle {...p} cx="12" cy="12" r="3"/></svg>;
    case 'foot':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M7 20c-2 0-3-1.5-3-3.5 0-2 1.5-3 1.5-5C5.5 9 6.5 7 9 7s3.5 2 3.5 4c0 2 1.5 3 1.5 5 0 2-1 3.5-3 3.5H7zM16 4.5a1.5 1.5 0 110 3 1.5 1.5 0 010-3zM19.5 8a1.2 1.2 0 110 2.4 1.2 1.2 0 010-2.4zM14 9a1 1 0 110 2 1 1 0 010-2z"/></svg>;
    case 'book':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M4 5a2 2 0 012-2h13v16H6a2 2 0 00-2 2V5zM4 19a2 2 0 002-2h13"/></svg>;
    case 'more':
      return <svg viewBox="0 0 24 24" style={s}><circle {...p} cx="5" cy="12" r="1.3"/><circle {...p} cx="12" cy="12" r="1.3"/><circle {...p} cx="19" cy="12" r="1.3"/></svg>;
    case 'plus':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 5v14M5 12h14"/></svg>;
    case 'x':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M6 6l12 12M18 6L6 18"/></svg>;
    case 'check':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M5 12.5l4 4 10-10"/></svg>;
    case 'chev-right':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M9 5l7 7-7 7"/></svg>;
    case 'chev-left':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M15 5l-7 7 7 7"/></svg>;
    case 'chev-down':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M5 9l7 7 7-7"/></svg>;
    case 'filter':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M3 5h18M6 12h12M10 19h4"/></svg>;
    case 'camera':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M3 8a2 2 0 012-2h2l2-2h6l2 2h2a2 2 0 012 2v9a2 2 0 01-2 2H5a2 2 0 01-2-2V8z"/><circle {...p} cx="12" cy="12.5" r="3.3"/></svg>;
    case 'pin':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 21s7-7 7-12a7 7 0 10-14 0c0 5 7 12 7 12z"/><circle {...p} cx="12" cy="9" r="2.3"/></svg>;
    case 'clock':
      return <svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="12" r="8.5"/><path {...p} d="M12 7.5V12l3 2"/></svg>;
    case 'alert':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 3l10 17H2L12 3z"/><path {...p} d="M12 10v4M12 17.2v.3"/></svg>;
    case 'wifi-off':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M2 8.5a15 15 0 0120 0M5 12a10 10 0 0114 0M8.5 15.5a5 5 0 017 0M12 19v.1M3 3l18 18"/></svg>;
    case 'sync':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M3 12a9 9 0 0115-6.7L21 8M21 12a9 9 0 01-15 6.7L3 16M21 4v4h-4M3 20v-4h4"/></svg>;
    case 'battery':
      return <svg viewBox="0 0 24 24" style={s}><rect {...p} x="2" y="7" width="17" height="10" rx="2"/><path {...p} d="M21 10v4"/></svg>;
    case 'leaf':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M20 4C10 4 4 10 4 20c10 0 16-6 16-16zM4 20l10-10"/></svg>;
    case 'drop':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 3s6 7 6 12a6 6 0 01-12 0c0-5 6-12 6-12z"/></svg>;
    case 'layers':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M12 3l9 5-9 5-9-5 9-5zM3 13l9 5 9-5M3 17l9 5 9-5"/></svg>;
    case 'target':
      return <svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="12" r="9"/><circle {...p} cx="12" cy="12" r="5"/><circle {...p} cx="12" cy="12" r="1"/></svg>;
    case 'calendar':
      return <svg viewBox="0 0 24 24" style={s}><rect {...p} x="3" y="5" width="18" height="16" rx="2"/><path {...p} d="M3 10h18M8 3v4M16 3v4"/></svg>;
    case 'play':
      return <svg viewBox="0 0 24 24" style={s}><path {...p} d="M7 4l13 8-13 8V4z"/></svg>;
    case 'stop':
      return <svg viewBox="0 0 24 24" style={s}><rect {...p} x="6" y="6" width="12" height="12" rx="1.5"/></svg>;
    case 'search':
      return <svg viewBox="0 0 24 24" style={s}><circle {...p} cx="11" cy="11" r="7"/><path {...p} d="M20 20l-4-4"/></svg>;
    case 'radio':
      return <svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="12" r="2"/><path {...p} d="M8.5 8.5a5 5 0 000 7M15.5 8.5a5 5 0 010 7M5 5a10 10 0 000 14M19 5a10 10 0 010 14"/></svg>;
    case 'user':
      return <svg viewBox="0 0 24 24" style={s}><circle {...p} cx="12" cy="8" r="4"/><path {...p} d="M4 21c0-4.4 3.6-8 8-8s8 3.6 8 8"/></svg>;
    default:
      return null;
  }
};

// ─── Status dot / badge ───────────────────────────────────
const StatusDot = ({ status, size = 10 }) => {
  const m = { active: T.active, treat: T.treat, cleared: T.cleared,
              synced: T.synced, pending: T.pending, conflict: T.conflict };
  return <span style={{ display: 'inline-block', width: size, height: size, borderRadius: size, background: m[status] || '#999' }}/>;
};

const SyncBadge = ({ status }) => {
  const map = {
    synced:   { label: 'synced',  bg: T.clearedSoft, fg: T.cleared, icon: 'check' },
    pending:  { label: 'pending', bg: T.treatSoft,   fg: T.treat,   icon: 'clock' },
    conflict: { label: 'conflict',bg: T.activeSoft,  fg: T.active,  icon: 'alert' },
  };
  const c = map[status];
  return (
    <span style={{ display: 'inline-flex', alignItems: 'center', gap: 4, padding: '3px 8px 3px 6px', borderRadius: 999, background: c.bg, color: c.fg, fontSize: 11, fontWeight: 600, letterSpacing: -0.1, fontFamily: LLFONT }}>
      <Icon name={c.icon} size={11} color={c.fg} strokeWidth={2.4}/> {c.label}
    </span>
  );
};

// ─── Variant dot + chip ───────────────────────────────────
const VariantDot = ({ id, size = 14, ring = true }) => {
  const v = T.variants.find(x => x.id === id) || T.variants[0];
  return (
    <span style={{
      display: 'inline-block', width: size, height: size, borderRadius: size,
      background: v.hex,
      boxShadow: ring ? `0 0 0 1.5px ${T.paper}, 0 0 0 2.5px ${T.lineStrong}` : 'none',
    }}/>
  );
};

// ─── Buttons ──────────────────────────────────────────────
const Btn = ({ children, kind = 'primary', onClick, style = {}, block = true, icon }) => {
  const kinds = {
    primary:   { bg: T.ochre,   fg: '#FFF8EE', bd: T.ochreDeep },
    dark:      { bg: T.euc,     fg: '#F0EAD9', bd: T.eucDark   },
    ghost:     { bg: 'transparent', fg: T.euc, bd: T.lineStrong },
    danger:    { bg: T.active,  fg: '#FFF',    bd: '#8C2520'   },
  };
  const s = kinds[kind];
  return (
    <button onClick={onClick} style={{
      display: 'inline-flex', alignItems: 'center', justifyContent: 'center', gap: 8,
      width: block ? '100%' : 'auto', minHeight: 48, padding: '0 18px',
      background: s.bg, color: s.fg, border: `1px solid ${s.bd}`,
      borderRadius: 14, fontFamily: LLFONTD, fontWeight: 600, fontSize: 16,
      letterSpacing: -0.2, cursor: 'pointer',
      boxShadow: kind === 'ghost' ? 'none' : '0 1px 0 rgba(0,0,0,0.06), 0 1px 2px rgba(0,0,0,0.05)',
      ...style,
    }}>
      {icon && <Icon name={icon} size={18} color={s.fg} strokeWidth={2}/>}
      {children}
    </button>
  );
};

// ─── Chip (selectable) ────────────────────────────────────
const Chip = ({ children, active, onClick, tone = 'euc' }) => {
  const bg = active ? (tone === 'ochre' ? T.ochre : T.euc) : '#FFF8EC';
  const fg = active ? '#FFF8EE' : T.ink2;
  const bd = active ? 'transparent' : T.line;
  return (
    <button onClick={onClick} style={{
      padding: '8px 13px', borderRadius: 999, background: bg, color: fg,
      border: `1px solid ${bd}`, fontFamily: LLFONT, fontWeight: 600, fontSize: 13,
      letterSpacing: -0.1, cursor: 'pointer', whiteSpace: 'nowrap',
    }}>{children}</button>
  );
};

// ─── Card ─────────────────────────────────────────────────
const Card = ({ children, style = {}, pad = 16, onClick }) => (
  <div onClick={onClick} style={{
    background: T.card, borderRadius: 18, padding: pad,
    border: `1px solid ${T.line}`,
    boxShadow: '0 1px 2px rgba(40,30,10,0.04)',
    cursor: onClick ? 'pointer' : 'default',
    ...style,
  }}>{children}</div>
);

// ─── Top bar (in-app, replaces iOS NavBar for custom look) ─
const TopBar = ({ title, left, right, sub }) => (
  <div style={{
    paddingTop: 56, paddingBottom: 8, paddingLeft: 16, paddingRight: 16,
    background: T.paper,
  }}>
    <div style={{ display: 'flex', alignItems: 'center', minHeight: 36 }}>
      <div style={{ width: 44 }}>{left}</div>
      <div style={{ flex: 1, textAlign: 'center', fontFamily: LLFONTD, fontWeight: 700, fontSize: 17, color: T.ink, letterSpacing: -0.3 }}>{title}</div>
      <div style={{ width: 44, display: 'flex', justifyContent: 'flex-end' }}>{right}</div>
    </div>
    {sub && <div style={{ textAlign: 'center', fontFamily: LLFONT, fontSize: 12, color: T.ink3, marginTop: 2 }}>{sub}</div>}
  </div>
);

const IconBtn = ({ name, onClick, bg = 'transparent', color = T.euc, size = 38 }) => (
  <button onClick={onClick} style={{
    width: size, height: size, borderRadius: size, background: bg, border: 'none',
    display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
    color,
  }}><Icon name={name} size={22} color={color} strokeWidth={2}/></button>
);

// ─── Tab bar ──────────────────────────────────────────────
const TabBar = ({ tab, setTab }) => {
  const tabs = [
    { id: 'map',      label: 'Map',       icon: 'map'  },
    { id: 'sightings',label: 'Sightings', icon: 'eye'  },
    { id: 'patrol',   label: 'Patrol',    icon: 'foot' },
    { id: 'guide',    label: 'Guide',     icon: 'book' },
    { id: 'more',     label: 'More',      icon: 'more' },
  ];
  return (
    <div style={{
      position: 'absolute', bottom: 0, left: 0, right: 0, zIndex: 40,
      paddingTop: 8, paddingBottom: 28,
      background: 'linear-gradient(to top, rgba(244,239,228,0.98) 60%, rgba(244,239,228,0))',
      borderTop: `0.5px solid ${T.line}`,
    }}>
      <div style={{ display: 'flex', justifyContent: 'space-around', padding: '0 4px' }}>
        {tabs.map(t => {
          const on = tab === t.id;
          return (
            <button key={t.id} onClick={() => setTab(t.id)} style={{
              flex: 1, display: 'flex', flexDirection: 'column', alignItems: 'center',
              gap: 3, padding: '6px 0', background: 'transparent', border: 'none', cursor: 'pointer',
              color: on ? T.ochre : T.ink3,
            }}>
              <Icon name={t.icon} size={24} color={on ? T.ochre : T.ink3} strokeWidth={on ? 2.2 : 1.8}/>
              <span style={{ fontFamily: LLFONT, fontSize: 10.5, fontWeight: on ? 700 : 500, letterSpacing: 0.1 }}>{t.label}</span>
            </button>
          );
        })}
      </div>
    </div>
  );
};

// ─── Placeholder image (striped) ──────────────────────────
const Placeholder = ({ w = '100%', h = 120, label, tint = T.eucSoft, radius = 14 }) => (
  <div style={{
    width: w, height: h, borderRadius: radius, position: 'relative', overflow: 'hidden',
    background: `repeating-linear-gradient(135deg, ${tint} 0 8px, ${T.paperDeep} 8px 16px)`,
    border: `1px solid ${T.line}`,
    display: 'flex', alignItems: 'center', justifyContent: 'center',
  }}>
    {label && <span style={{ fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace', fontSize: 10, color: T.ink3, background: 'rgba(244,239,228,0.9)', padding: '3px 7px', borderRadius: 4, letterSpacing: 0.2 }}>{label}</span>}
  </div>
);

Object.assign(window, { Icon, StatusDot, SyncBadge, VariantDot, Btn, Chip, Card, TopBar, IconBtn, TabBar, Placeholder });
