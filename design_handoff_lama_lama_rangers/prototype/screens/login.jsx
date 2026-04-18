// Login + PIN entry — Lama Lama Rangers
// Cape York coastline motif (stylized topographic lines), ranger list, PIN pad

function CoastMotif() {
  // Stylized topographic lines suggesting the Cape York coastline — not a literal map.
  return (
    <svg width="100%" height="160" viewBox="0 0 375 160" preserveAspectRatio="none" style={{ display: 'block' }}>
      <defs>
        <linearGradient id="sky" x1="0" y1="0" x2="0" y2="1">
          <stop offset="0" stopColor="#E6D8B7"/>
          <stop offset="1" stopColor="#C89F6B"/>
        </linearGradient>
      </defs>
      <rect width="375" height="160" fill="url(#sky)"/>
      {/* sun */}
      <circle cx="290" cy="58" r="26" fill="#F3DEC5" opacity="0.8"/>
      <circle cx="290" cy="58" r="18" fill="#E8B07A"/>
      {/* topographic contour lines — stylized coastline */}
      {[0,1,2,3,4,5,6].map(i => {
        const y = 70 + i*11;
        const amp = 6 + i*1.2;
        const path = `M-10 ${y} C 40 ${y-amp}, 90 ${y+amp}, 150 ${y-amp*0.6} S 260 ${y+amp}, 320 ${y-amp*0.4} S 400 ${y+amp*0.6}, 420 ${y}`;
        const opacity = 0.15 + i*0.08;
        return <path key={i} d={path} fill="none" stroke="#2E4634" strokeWidth="1.1" opacity={opacity}/>;
      })}
      {/* ridge silhouettes */}
      <path d="M0 128 L30 112 L55 122 L95 100 L130 116 L175 102 L220 118 L265 104 L310 120 L350 108 L375 116 L375 160 L0 160 Z" fill="#2E4634" opacity="0.85"/>
      <path d="M0 140 L45 128 L85 136 L140 122 L195 134 L240 124 L290 138 L340 128 L375 134 L375 160 L0 160 Z" fill="#1E2F22"/>
    </svg>
  );
}

function LoginScreen({ onLogin }) {
  const [step, setStep] = React.useState('pick'); // pick | pin
  const [ranger, setRanger] = React.useState(null);
  const [pin, setPin] = React.useState('');
  const [shake, setShake] = React.useState(false);

  const onDigit = (d) => {
    if (pin.length >= 4) return;
    const next = pin + d;
    setPin(next);
    if (next.length === 4) {
      // any 4-digit pin accepts; "0000" for demo rejection
      setTimeout(() => {
        if (next === '0000') {
          setShake(true); setTimeout(() => { setShake(false); setPin(''); }, 500);
        } else {
          onLogin(ranger);
        }
      }, 180);
    }
  };

  return (
    <div style={{ height: '100%', display: 'flex', flexDirection: 'column', background: T.paper }}>
      <CoastMotif/>
      <div style={{ flex: 1, padding: '20px 24px 40px', display: 'flex', flexDirection: 'column' }}>
        <div style={{ fontFamily: LLFONTD, fontSize: 11, letterSpacing: 2.2, color: T.bark, fontWeight: 600, textTransform: 'uppercase', marginBottom: 4 }}>Cape York · Port Stewart</div>
        <div style={{ fontFamily: LLFONTD, fontSize: 30, fontWeight: 800, color: T.euc, letterSpacing: -0.8, lineHeight: 1.02 }}>Lama Lama</div>
        <div style={{ fontFamily: LLFONTD, fontSize: 30, fontWeight: 800, color: T.ochre, letterSpacing: -0.8, lineHeight: 1.02, marginBottom: 18 }}>Rangers</div>

        {step === 'pick' && (
          <>
            <div style={{ fontFamily: LLFONT, fontSize: 14, color: T.ink3, marginBottom: 12 }}>Good to see you. Who's signing on today?</div>
            <div style={{ display: 'flex', flexDirection: 'column', gap: 8, flex: 1 }}>
              {RANGERS.map(r => (
                <button key={r.id} onClick={() => { setRanger(r); setStep('pin'); }} style={{
                  display: 'flex', alignItems: 'center', gap: 12, padding: 12,
                  background: T.card, border: `1px solid ${T.line}`, borderRadius: 14,
                  textAlign: 'left', cursor: 'pointer', minHeight: 56,
                }}>
                  <div style={{ width: 40, height: 40, borderRadius: 40, background: r.tone, color: '#FFF8EE', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: LLFONTD, fontWeight: 700, fontSize: 15 }}>{r.initials}</div>
                  <div style={{ flex: 1 }}>
                    <div style={{ fontFamily: LLFONTD, fontWeight: 600, fontSize: 16, color: T.ink }}>{r.name}</div>
                    <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>{r.role}</div>
                  </div>
                  <Icon name="chev-right" size={18} color={T.ink3}/>
                </button>
              ))}
            </div>
          </>
        )}

        {step === 'pin' && (
          <>
            <button onClick={() => { setStep('pick'); setPin(''); }} style={{ background: 'none', border: 'none', color: T.euc, fontFamily: LLFONT, fontSize: 14, padding: 0, display: 'inline-flex', alignItems: 'center', gap: 4, cursor: 'pointer', alignSelf: 'flex-start', marginBottom: 14 }}>
              <Icon name="chev-left" size={16} color={T.euc}/> Change ranger
            </button>
            <div style={{ display: 'flex', alignItems: 'center', gap: 12, marginBottom: 6 }}>
              <div style={{ width: 44, height: 44, borderRadius: 44, background: ranger.tone, color: '#FFF8EE', display: 'flex', alignItems: 'center', justifyContent: 'center', fontFamily: LLFONTD, fontWeight: 700, fontSize: 16 }}>{ranger.initials}</div>
              <div>
                <div style={{ fontFamily: LLFONTD, fontWeight: 700, fontSize: 18, color: T.ink }}>{ranger.name}</div>
                <div style={{ fontFamily: LLFONT, fontSize: 12, color: T.ink3 }}>Enter your 4-digit PIN</div>
              </div>
            </div>

            <div style={{
              display: 'flex', justifyContent: 'center', gap: 14, margin: '24px 0 8px',
              transform: shake ? 'translateX(0)' : 'none',
              animation: shake ? 'llShake 0.45s ease' : 'none',
            }}>
              {[0,1,2,3].map(i => (
                <div key={i} style={{
                  width: 18, height: 18, borderRadius: 18,
                  background: pin.length > i ? T.euc : 'transparent',
                  border: `1.5px solid ${pin.length > i ? T.euc : T.lineStrong}`,
                }}/>
              ))}
            </div>
            <style>{`@keyframes llShake { 0%,100%{transform:translateX(0)} 20%,60%{transform:translateX(-8px)} 40%,80%{transform:translateX(8px)} }`}</style>

            <div style={{ flex: 1 }}/>
            <div style={{ display: 'grid', gridTemplateColumns: 'repeat(3, 1fr)', gap: 10, marginTop: 8 }}>
              {[1,2,3,4,5,6,7,8,9].map(n => (
                <button key={n} onClick={() => onDigit(String(n))} style={pinBtn}>{n}</button>
              ))}
              <div/>
              <button onClick={() => onDigit('0')} style={pinBtn}>0</button>
              <button onClick={() => setPin(p => p.slice(0,-1))} style={{ ...pinBtn, background: 'transparent', border: 'none', boxShadow: 'none' }}>
                <Icon name="chev-left" size={22} color={T.ink2}/>
              </button>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

const pinBtn = {
  height: 64, borderRadius: 18, background: T.card, border: `1px solid ${T.line}`,
  fontFamily: LLFONTR, fontSize: 28, fontWeight: 500, color: T.ink,
  display: 'flex', alignItems: 'center', justifyContent: 'center', cursor: 'pointer',
  boxShadow: '0 1px 0 rgba(0,0,0,0.04)',
};

window.LoginScreen = LoginScreen;
