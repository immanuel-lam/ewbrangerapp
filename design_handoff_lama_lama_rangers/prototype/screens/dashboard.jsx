// Dashboard — Lama Lama Rangers
// Greeting, line chart (sightings/month × variant), donut (zone status), stat cards, recent sightings

function LineChart({ data, labels, width = 343, height = 140 }) {
  // data: [{ variant, points: [n, n, ...] }]
  const pad = { l: 22, r: 10, t: 8, b: 20 };
  const W = width - pad.l - pad.r;
  const H = height - pad.t - pad.b;
  const max = Math.max(4, ...data.flatMap(d => d.points));
  const n = labels.length;
  const xAt = (i) => pad.l + (W * i) / (n - 1);
  const yAt = (v) => pad.t + H - (H * v) / max;

  return (
    <svg width={width} height={height} style={{ display: 'block' }}>
      {/* grid */}
      {[0, 0.5, 1].map(t => (
        <line key={t} x1={pad.l} x2={pad.l + W} y1={pad.t + H * (1 - t)} y2={pad.t + H * (1 - t)} stroke={T.line} strokeWidth="1" strokeDasharray={t === 0 ? '' : '2 3'}/>
      ))}
      {/* lines */}
      {data.map(d => {
        const v = T.variants.find(x => x.id === d.variant);
        const path = d.points.map((p, i) => `${i ? 'L' : 'M'}${xAt(i).toFixed(1)} ${yAt(p).toFixed(1)}`).join(' ');
        return (
          <g key={d.variant}>
            <path d={path} fill="none" stroke={v.hex} strokeWidth="1.8" strokeLinejoin="round" strokeLinecap="round"/>
            {d.points.map((p, i) => (
              <circle key={i} cx={xAt(i)} cy={yAt(p)} r="2.4" fill={T.paper} stroke={v.hex} strokeWidth="1.6"/>
            ))}
          </g>
        );
      })}
      {/* x labels */}
      {labels.map((l, i) => (
        <text key={l} x={xAt(i)} y={height - 4} textAnchor="middle" fontSize="10" fontFamily={LLFONT} fill={T.ink3}>{l}</text>
      ))}
      {/* y min/max */}
      <text x={pad.l - 4} y={pad.t + 4} textAnchor="end" fontSize="9" fontFamily={LLFONT} fill={T.ink3}>{max}</text>
      <text x={pad.l - 4} y={pad.t + H + 3} textAnchor="end" fontSize="9" fontFamily={LLFONT} fill={T.ink3}>0</text>
    </svg>
  );
}

function ZoneDonut({ active, treat, cleared, size = 118 }) {
  const total = active + treat + cleared;
  const r = size / 2 - 10;
  const cx = size / 2, cy = size / 2;
  const circ = 2 * Math.PI * r;
  let offset = 0;
  const segs = [
    { val: active,  color: T.active },
    { val: treat,   color: T.treat },
    { val: cleared, color: T.cleared },
  ];
  return (
    <svg width={size} height={size}>
      <circle cx={cx} cy={cy} r={r} fill="none" stroke={T.paperDeep} strokeWidth="12"/>
      {segs.map((s, i) => {
        const len = (s.val / total) * circ;
        const c = (
          <circle key={i} cx={cx} cy={cy} r={r} fill="none" stroke={s.color} strokeWidth="12"
            strokeDasharray={`${len} ${circ - len}`}
            strokeDashoffset={-offset}
            transform={`rotate(-90 ${cx} ${cy})`}
            strokeLinecap="butt"/>
        );
        offset += len;
        return c;
      })}
      <text x={cx} y={cy - 2} textAnchor="middle" fontFamily={LLFONTD} fontSize="22" fontWeight="700" fill={T.ink}>{total}</text>
      <text x={cx} y={cy + 14} textAnchor="middle" fontFamily={LLFONT} fontSize="10" fill={T.ink3}>zones</text>
    </svg>
  );
}

function DashboardScreen({ ranger, onOpenSighting, onGoto }) {
  const months = ['Nov','Dec','Jan','Feb','Mar','Apr'];
  // Seeded chart data per variant
  const chartData = [
    { variant: 'pink',   points: [2, 4, 7, 9, 6, 3] },
    { variant: 'orange', points: [1, 2, 3, 4, 5, 6] },
    { variant: 'red',    points: [4, 5, 3, 4, 7, 8] },
    { variant: 'yellow', points: [0, 1, 2, 2, 3, 2] },
    { variant: 'white',  points: [1, 1, 2, 3, 2, 4] },
    { variant: 'pale',   points: [0, 2, 3, 2, 4, 5] },
  ];

  const recent = SEED_SIGHTINGS.slice(0, 3);

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <div style={{ padding: '54px 20px 14px' }}>
        <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.bark, letterSpacing: 1.4, fontWeight: 600, textTransform: 'uppercase' }}>Gather · Wet season</div>
        <div style={{ fontFamily: LLFONTD, fontSize: 28, fontWeight: 700, color: T.ink, letterSpacing: -0.7, marginTop: 2 }}>G'day, {ranger.name.split(' ')[0]}.</div>
        <div style={{ fontFamily: LLFONT, fontSize: 14, color: T.ink3, marginTop: 2 }}>5 rangers on country · offline mode</div>
      </div>

      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 12 }}>
        {/* Chart card */}
        <Card pad={14}>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', marginBottom: 8 }}>
            <div style={{ fontFamily: LLFONTD, fontSize: 15, fontWeight: 700, color: T.ink }}>Sightings by variant</div>
            <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>last 6 months</div>
          </div>
          <div style={{ overflow: 'hidden', margin: '0 -2px' }}>
            <LineChart data={chartData} labels={months} width={315} height={130}/>
          </div>
          <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 6, marginTop: 8 }}>
            {T.variants.map(v => (
              <div key={v.id} style={{ display: 'flex', alignItems: 'center', gap: 6, fontFamily: LLFONT, fontSize: 11, color: T.ink2 }}>
                <span style={{ width: 14, height: 2.5, background: v.hex, borderRadius: 2 }}/>
                {v.name}
              </div>
            ))}
          </div>
        </Card>

        {/* Zone status + stat cards row */}
        <div style={{ display: 'flex', gap: 12 }}>
          <Card pad={14} style={{ flex: '0 0 158px' }}>
            <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink, marginBottom: 4 }}>Zone status</div>
            <div style={{ display: 'flex', justifyContent: 'center' }}>
              <ZoneDonut active={2} treat={2} cleared={1}/>
            </div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 4, marginTop: 6 }}>
              {[
                { k: 'Active',    v: 2, c: T.active  },
                { k: 'Treating',  v: 2, c: T.treat   },
                { k: 'Cleared',   v: 1, c: T.cleared },
              ].map(r => (
                <div key={r.k} style={{ display: 'flex', alignItems: 'center', gap: 7, fontFamily: LLFONT, fontSize: 11, color: T.ink2 }}>
                  <span style={{ width: 8, height: 8, borderRadius: 8, background: r.c }}/>
                  <span style={{ flex: 1 }}>{r.k}</span>
                  <span style={{ fontWeight: 600, color: T.ink }}>{r.v}</span>
                </div>
              ))}
            </div>
          </Card>

          <div style={{ flex: 1, display: 'flex', flexDirection: 'column', gap: 12 }}>
            <Card pad={12} onClick={() => onGoto('tasks')}>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>Open tasks</div>
              <div style={{ fontFamily: LLFONTD, fontSize: 30, fontWeight: 700, color: T.euc, letterSpacing: -0.8 }}>4</div>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>2 high priority</div>
            </Card>
            <Card pad={12}>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3, fontWeight: 600, letterSpacing: 0.3, textTransform: 'uppercase' }}>Treatments · Apr</div>
              <div style={{ fontFamily: LLFONTD, fontSize: 30, fontWeight: 700, color: T.ochre, letterSpacing: -0.8 }}>18</div>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3 }}>↑ 4 from March</div>
            </Card>
          </div>
        </div>

        {/* Recent sightings */}
        <div>
          <div style={{ display: 'flex', alignItems: 'baseline', justifyContent: 'space-between', padding: '10px 4px 8px' }}>
            <div style={{ fontFamily: LLFONTD, fontSize: 15, fontWeight: 700, color: T.ink }}>Recent sightings</div>
            <button onClick={() => onGoto('sightings')} style={{ background: 'none', border: 'none', color: T.ochre, fontFamily: LLFONT, fontSize: 13, fontWeight: 600, cursor: 'pointer' }}>See all</button>
          </div>
          <Card pad={0}>
            {recent.map((s, i) => {
              const r = RANGERS.find(x => x.id === s.ranger);
              const v = T.variants.find(x => x.id === s.variant);
              return (
                <div key={s.id} onClick={() => onOpenSighting(s.id)} style={{
                  display: 'flex', alignItems: 'center', gap: 10, padding: '12px 14px',
                  borderTop: i ? `0.5px solid ${T.line}` : 'none', cursor: 'pointer',
                }}>
                  <div style={{ width: 36, height: 36, borderRadius: 10, background: v.hex, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                    <Icon name="leaf" size={18} color="rgba(255,255,255,0.92)" strokeWidth={2}/>
                  </div>
                  <div style={{ flex: 1, minWidth: 0 }}>
                    <div style={{ fontFamily: LLFONTD, fontSize: 14, fontWeight: 600, color: T.ink }}>{v.name} · <span style={{ color: T.ink3, fontWeight: 500 }}>{s.zone}</span></div>
                    <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3, marginTop: 1, whiteSpace: 'nowrap', overflow: 'hidden', textOverflow: 'ellipsis' }}>{r.name} · {s.when} · {s.size}</div>
                  </div>
                  <SyncBadge status={s.sync}/>
                </div>
              );
            })}
          </Card>
        </div>
      </div>
    </div>
  );
}

window.DashboardScreen = DashboardScreen;
