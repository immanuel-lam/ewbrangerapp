// Variant Guide + Pesticide Inventory

function GuideScreen({ onOpenVariant }) {
  // Biocontrol warning is active Nov–Mar for Common Pink
  const biocontrol = true;
  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <div style={{ padding: '54px 20px 10px' }}>
        <div style={{ fontFamily: LLFONTD, fontSize: 28, fontWeight: 700, color: T.ink, letterSpacing: -0.6 }}>Lantana guide</div>
        <div style={{ fontFamily: LLFONT, fontSize: 13, color: T.ink3, marginTop: 2 }}>Six variants on country · tap one to learn identifying marks</div>
      </div>

      {biocontrol && (
        <div style={{ margin: '4px 16px 14px', padding: 12, borderRadius: 14, background: T.ochreSoft, border: `1px solid ${T.ochre}`, display: 'flex', gap: 10, alignItems: 'flex-start' }}>
          <Icon name="alert" size={22} color={T.ochreDeep} strokeWidth={2.2}/>
          <div>
            <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 14, color: T.ochreDeep }}>Pink Lantana biocontrol active · Nov – Mar</div>
            <div style={{ fontFamily: LLFONT, fontSize: 12.5, color: T.ink2, marginTop: 2, lineHeight: 1.35 }}>Don't apply foliar spray on flowering pink plants. The leaf-sucking bug does the work — let them feed.</div>
          </div>
        </div>
      )}

      <div style={{ padding: '0 16px', display: 'grid', gridTemplateColumns: '1fr 1fr', gap: 10 }}>
        {T.variants.map(v => (
          <button key={v.id} onClick={() => onOpenVariant(v.id)} style={{
            background: T.card, border: `1px solid ${T.line}`, borderRadius: 16,
            padding: 0, cursor: 'pointer', textAlign: 'left', overflow: 'hidden',
          }}>
            <div style={{ height: 72, background: `linear-gradient(135deg, ${v.hex} 0%, ${shade(v.hex, -20)} 100%)`, position: 'relative', display: 'flex', alignItems: 'flex-end', justifyContent: 'flex-end', padding: 8 }}>
              <Icon name="leaf" size={26} color="rgba(255,255,255,0.7)" strokeWidth={1.6}/>
              {v.id === 'pink' && biocontrol && (
                <div style={{ position: 'absolute', top: 8, left: 8, background: T.ochre, color: '#FFF8EE', fontFamily: LLFONT, fontSize: 9, fontWeight: 700, letterSpacing: 0.4, textTransform: 'uppercase', padding: '2px 7px', borderRadius: 999 }}>Biocontrol</div>
              )}
            </div>
            <div style={{ padding: '10px 12px 12px' }}>
              <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 14, color: T.ink, letterSpacing: -0.2 }}>{v.name}</div>
              <div style={{ fontFamily: LLFONT, fontSize: 11, color: T.ink3, marginTop: 2 }}>Lantana camara</div>
            </div>
          </button>
        ))}
      </div>
    </div>
  );
}

function shade(hex, pct) {
  const h = hex.replace('#','');
  const r = parseInt(h.slice(0,2),16), g = parseInt(h.slice(2,4),16), b = parseInt(h.slice(4,6),16);
  const f = 1 + pct/100;
  const c = (n) => Math.max(0, Math.min(255, Math.round(n*f)));
  return `rgb(${c(r)}, ${c(g)}, ${c(b)})`;
}

function VariantDetailScreen({ id, onBack }) {
  const v = T.variants.find(x => x.id === id) || T.variants[0];
  const info = {
    pink:   { features: ['Pink to rose flowers in clusters', 'Square stems with small prickles', 'Opposite oval leaves, rough to touch'],
              methods: [
                { title: 'Hand-pull seedlings', steps: ['Wet the ground first', 'Grip close to the base', 'Pull slow so roots come up', 'Bag any seed heads'] },
                { title: 'Biocontrol (Nov–Mar)', steps: ['Inspect for leaf-sucking bug', 'Do NOT spray active patches', 'Mark area with pink flag', 'Return in 6 weeks to re-check'] },
              ],
              seasonal: 'Flowers Nov–Mar. Biocontrol active — do not spray.' },
    orange: { features: ['Orange-red flowers', 'Tallest growth, up to 4 m', 'Glossy darker leaves'],
              methods: [
                { title: 'Cut-stump with Access', steps: ['Cut stems 10 cm above ground', 'Apply Access within 30 seconds', 'Mark with dye', 'Record stump count'] },
              ],
              seasonal: 'Flowers year-round. Focus treatment in dry season.' },
    red:    { features: ['Deep red / crimson flowers', 'Arching woody stems', 'Strong sharp scent when crushed'],
              methods: [{ title: 'Foliar spray Grazon', steps: ['Full PPE', 'Cover all foliage to wet', 'Do not spray before rain', 'Log volume used'] }],
              seasonal: 'Flowers Oct–Apr.' },
    yellow: { features: ['Yellow / cream flowers', 'Shorter growth', 'Smooth lighter leaves'],
              methods: [{ title: 'Basal bark treatment', steps: ['Mix Access with diesel 1:60', 'Spray lower 30 cm of stems', 'Wet all around', 'Leave plant standing'] }],
              seasonal: 'Flowers Sep–Feb.' },
    white:  { features: ['Small white / cream clusters', 'Fine hairs on stems', 'Thin leaves'],
              methods: [{ title: 'Hand removal', steps: ['Small patches only', 'Pull whole plant', 'Remove seeds carefully'] }],
              seasonal: 'Dry season flowering.' },
    pale:   { features: ['Pale pink, almost white', 'Mix with pink — watch closely', 'Smaller flower heads'],
              methods: [{ title: 'Spot spray', steps: ['Confirm variant first', 'Use low-volume knapsack', 'Mark plant for re-check'] }],
              seasonal: 'Flowers Oct–Feb.' },
  }[id];

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 120 }}>
      <div style={{ height: 200, background: `linear-gradient(160deg, ${v.hex} 0%, ${shade(v.hex, -30)} 100%)`, position: 'relative' }}>
        <div style={{ position: 'absolute', top: 54, left: 12 }}>
          <button onClick={onBack} style={{ width: 38, height: 38, borderRadius: 38, background: 'rgba(255,255,255,0.9)', border: 'none', display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer' }}>
            <Icon name="chev-left" size={20} color={T.ink}/>
          </button>
        </div>
        <div style={{ position: 'absolute', bottom: 18, left: 20, color: '#FFF8EE' }}>
          <div style={{ fontFamily: LLFONT, fontSize: 11, fontWeight: 600, letterSpacing: 1.4, textTransform: 'uppercase', opacity: 0.75 }}>Lantana camara</div>
          <div style={{ fontFamily: LLFONTD, fontSize: 30, fontWeight: 800, letterSpacing: -0.7, marginTop: 2 }}>{v.name}</div>
        </div>
        <div style={{ position: 'absolute', top: 60, right: 16, width: 70, height: 70, borderRadius: 70, background: 'rgba(255,255,255,0.15)', border: '2px solid rgba(255,255,255,0.5)', display: 'flex', alignItems: 'center', justifyContent: 'center' }}>
          <Icon name="leaf" size={38} color="#FFF8EE" strokeWidth={1.5}/>
        </div>
      </div>

      {id === 'pink' && (
        <div style={{ margin: '14px 16px 0', padding: 12, borderRadius: 14, background: T.ochreSoft, border: `1px solid ${T.ochre}`, display: 'flex', gap: 10, alignItems: 'flex-start' }}>
          <Icon name="alert" size={20} color={T.ochreDeep} strokeWidth={2.2}/>
          <div style={{ fontFamily: LLFONT, fontSize: 12.5, color: T.ink2, lineHeight: 1.35 }}>
            <b style={{ color: T.ochreDeep }}>Biocontrol active Nov–Mar.</b> Do not apply foliar spray on flowering plants.
          </div>
        </div>
      )}

      <div style={{ padding: '16px 16px 0' }}>
        <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase', marginBottom: 8 }}>How to spot it</div>
        <Card>
          {info.features.map((f, i) => (
            <div key={i} style={{ display: 'flex', gap: 10, alignItems: 'flex-start', padding: '6px 0', borderTop: i ? `0.5px solid ${T.line}` : 'none' }}>
              <span style={{ width: 6, height: 6, borderRadius: 6, background: v.hex, marginTop: 7, flexShrink: 0 }}/>
              <div style={{ fontFamily: LLFONT, fontSize: 14, color: T.ink, lineHeight: 1.4 }}>{f}</div>
            </div>
          ))}
        </Card>

        <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase', margin: '18px 0 8px' }}>Control methods</div>
        <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
          {info.methods.map((m, i) => (
            <Card key={i}>
              <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 15, color: T.ink, marginBottom: 8 }}>{m.title}</div>
              {m.steps.map((s, j) => (
                <div key={j} style={{ display: 'flex', gap: 10, alignItems: 'flex-start', padding: '4px 0' }}>
                  <span style={{ width: 22, height: 22, borderRadius: 22, background: T.eucSoft, color: T.euc, fontFamily: LLFONTD, fontSize: 11, fontWeight: 700, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>{j+1}</span>
                  <div style={{ fontFamily: LLFONT, fontSize: 13.5, color: T.ink, lineHeight: 1.4, paddingTop: 3 }}>{s}</div>
                </div>
              ))}
            </Card>
          ))}
        </div>

        <div style={{ fontFamily: LLFONTD, fontSize: 13, fontWeight: 700, color: T.ink3, letterSpacing: 0.4, textTransform: 'uppercase', margin: '18px 0 8px' }}>Seasonal note</div>
        <Card>
          <div style={{ fontFamily: LLFONT, fontSize: 13.5, color: T.ink, lineHeight: 1.4 }}>{info.seasonal}</div>
        </Card>
      </div>
    </div>
  );
}

function InventoryScreen({ onBack }) {
  const [drawer, setDrawer] = React.useState(null);

  return (
    <div style={{ background: T.paper, minHeight: '100%', paddingBottom: 100 }}>
      <TopBar title="Pesticide inventory" left={<IconBtn name="chev-left" onClick={onBack}/>}/>
      <div style={{ padding: '0 16px', display: 'flex', flexDirection: 'column', gap: 10 }}>
        {HERBS.map(h => {
          const pct = Math.round(h.stock * 100);
          const low = h.stock < 0.2;
          const warn = h.stock < 0.35 && !low;
          const tone = low ? T.active : warn ? T.treat : T.euc;
          const toneSoft = low ? T.activeSoft : warn ? T.treatSoft : T.eucSoft;
          return (
            <Card key={h.id} pad={14}>
              <div style={{ display: 'flex', alignItems: 'center', gap: 12 }}>
                <div style={{ width: 44, height: 44, borderRadius: 12, background: toneSoft, display: 'flex', alignItems: 'center', justifyContent: 'center', flexShrink: 0 }}>
                  <Icon name="drop" size={22} color={tone} strokeWidth={2}/>
                </div>
                <div style={{ flex: 1, minWidth: 0 }}>
                  <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 15, color: T.ink }}>{h.name}</div>
                  <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>{h.kind} · {(h.stock*h.total).toFixed(1)} / {h.total} {h.unit}</div>
                </div>
                {low && <span style={{ padding: '2px 7px', background: T.active, color: '#FFF', fontFamily: LLFONT, fontSize: 10, fontWeight: 700, letterSpacing: 0.3, textTransform: 'uppercase', borderRadius: 999 }}>Low</span>}
                {warn && <span style={{ padding: '2px 7px', background: T.treat, color: '#FFF', fontFamily: LLFONT, fontSize: 10, fontWeight: 700, letterSpacing: 0.3, textTransform: 'uppercase', borderRadius: 999 }}>Getting low</span>}
              </div>
              <div style={{ marginTop: 10, height: 8, borderRadius: 8, background: T.paperDeep, overflow: 'hidden' }}>
                <div style={{ width: `${pct}%`, height: '100%', background: tone, borderRadius: 8 }}/>
              </div>
              <div style={{ display: 'flex', justifyContent: 'space-between', marginTop: 8, gap: 8 }}>
                <button onClick={() => setDrawer(drawer === h.id ? null : h.id)} style={{ background: 'none', border: 'none', color: T.ink3, fontFamily: LLFONT, fontSize: 12, cursor: 'pointer', padding: 0 }}>
                  {drawer === h.id ? 'Hide' : 'View'} usage log
                </button>
                <button style={{ background: T.euc, color: '#FFF8EE', border: 'none', borderRadius: 10, padding: '6px 14px', fontFamily: LLFONTD, fontWeight: 600, fontSize: 12, cursor: 'pointer' }}>Log usage</button>
              </div>
              {drawer === h.id && (
                <div style={{ marginTop: 10, paddingTop: 10, borderTop: `0.5px solid ${T.line}` }}>
                  {[
                    { d: '14 Apr', r: 'Jarrah T.',     v: '1.2 L', at: 'Running Creek' },
                    { d: '09 Apr', r: 'Aunty Maureen', v: '0.8 L', at: 'Bromley Rd' },
                    { d: '02 Apr', r: 'Kiri M.',       v: '2.0 L', at: 'Port Stewart N.' },
                  ].map((u, i) => (
                    <div key={i} style={{ display: 'flex', padding: '6px 0', fontFamily: LLFONT, fontSize: 12, color: T.ink2 }}>
                      <span style={{ width: 56, fontFamily: 'ui-monospace, "SF Mono", Menlo, monospace', color: T.ink3 }}>{u.d}</span>
                      <span style={{ flex: 1 }}>{u.r} · {u.at}</span>
                      <span style={{ fontFamily: LLFONTD, fontWeight: 600, color: T.ink }}>{u.v}</span>
                    </div>
                  ))}
                </div>
              )}
            </Card>
          );
        })}
      </div>
    </div>
  );
}

window.GuideScreen = GuideScreen;
window.VariantDetailScreen = VariantDetailScreen;
window.InventoryScreen = InventoryScreen;
