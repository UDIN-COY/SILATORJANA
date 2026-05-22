import { Link } from 'react-router-dom';
import { motion } from 'motion/react';
import { AppLogo } from '@/components/AppLogo';
import { FileText, Shield, DollarSign, ArrowRight, ChevronRight, Activity, Users, BarChart3, CheckCircle2, Navigation } from 'lucide-react';

const features = [
  { icon: FileText, title: 'Pengajuan Cepat', desc: 'Proses usulan barang dan anggaran dengan tracking real-time di tiap tahapan.', color: '#36C06C', bg: 'rgba(54,192,108,0.1)' },
  { icon: Shield, title: 'Verifikasi Berlapis', desc: 'Sistem persetujuan terstruktur mulai dari verifikator, PPK, hingga wadir.', color: '#2D6A4F', bg: 'rgba(45,106,79,0.1)' },
  { icon: DollarSign, title: 'Transparansi Anggaran', desc: 'Monitoring penggunaan dana dari awal usulan hingga LPJ yang dapat diandalkan.', color: '#52DE97', bg: 'rgba(82,222,151,0.1)' },
];

const stats = [
  { icon: Users, label: 'Pengguna Aktif', value: '500+' },
  { icon: Activity, label: 'Kegiatan Dikelola', value: '1,200+' },
  { icon: BarChart3, label: 'Dana Tersalurkan', value: 'Rp 2.5M+' },
];

export function LandingPage() {
  return (
    <div className="min-h-screen bg-white overflow-hidden" style={{ fontFamily: "'Plus Jakarta Sans', sans-serif" }}>
      <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@400;500;600;700;800&display=swap" rel="stylesheet" />

      {/* Navbar */}
      <header className="fixed top-0 w-full z-50 transition-all duration-300" style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(12px)', borderBottom: '1px solid rgba(0,0,0,0.05)' }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 h-16 md:h-20 flex items-center justify-between">
          <div className="flex items-center gap-2 md:gap-3 shrink-0">
            <AppLogo className="size-8 md:size-10 drop-shadow-sm" />
            <span className="font-extrabold text-lg md:text-xl tracking-tight" style={{ color: '#1A4D2E' }}>LATORJANA</span>
          </div>
          <div className="flex items-center gap-2 md:gap-4 shrink-0">
            <Link to="/login" className="px-3 md:px-5 py-2 text-sm font-semibold rounded-lg transition-colors hover:bg-slate-50 hidden sm:block" style={{ color: '#1A4D2E' }}>Masuk</Link>
            <Link to="/login" className="px-5 md:px-7 py-2 md:py-2.5 text-xs md:text-sm font-bold text-white rounded-full transition-all hover:-translate-y-0.5 hover:shadow-lg flex items-center gap-2" style={{ background: 'linear-gradient(135deg, #1A4D2E, #36C06C)', boxShadow: '0 4px 15px rgba(26,77,46,0.2)' }}>
              Mulai Sistem <Navigation className="size-3 md:size-4 hidden sm:block" />
            </Link>
          </div>
        </div>
      </header>

      {/* Hero Section */}
      <section className="relative pt-28 md:pt-40 pb-20 md:pb-32 overflow-hidden">
        {/* Background Effects */}
        <div className="absolute inset-0 -z-10" style={{ background: 'linear-gradient(180deg, #f1f8e9 0%, #ffffff 100%)' }} />
        <div className="absolute top-0 right-0 -z-10 opacity-30 w-[300px] h-[300px] md:w-[600px] md:h-[600px] rounded-full transform translate-x-1/3 -translate-y-1/4" style={{ background: 'radial-gradient(circle, #36C06C, transparent)', filter: 'blur(80px)' }} />
        <div className="absolute bottom-0 left-0 -z-10 opacity-20 w-[300px] h-[300px] md:w-[500px] md:h-[500px] rounded-full transform -translate-x-1/3 translate-y-1/3" style={{ background: 'radial-gradient(circle, #1A4D2E, transparent)', filter: 'blur(60px)' }} />

        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 text-center relative z-10 w-full overflow-hidden">
          <motion.div initial={{ opacity: 0, y: 30 }} animate={{ opacity: 1, y: 0 }} transition={{ duration: 0.8, ease: "easeOut" }}>
            <div className="inline-flex items-center justify-center gap-2 px-3 md:px-4 py-1.5 md:py-2 rounded-full text-xs md:text-sm font-semibold mb-6 md:mb-8" style={{ background: 'rgba(54,192,108,0.1)', color: '#1A4D2E', border: '1px solid rgba(54,192,108,0.2)' }}>
              <span className="size-2 rounded-full animate-pulse" style={{ background: '#36C06C' }} />
              Platform Terintegrasi PNJ
            </div>
            
            <h1 className="text-4xl sm:text-5xl md:text-6xl lg:text-7xl font-extrabold tracking-tight leading-[1.15] mb-4 md:mb-6 px-4" style={{ color: '#0D2818' }}>
              Sistem Layanan Terpadu<br className="hidden sm:block" />
              <span className="inline-block mt-2 sm:mt-0 px-2.5 py-1 md:py-2 md:px-4 rounded-xl md:rounded-2xl bg-gradient-to-br from-emerald-50 to-teal-50/50 border border-emerald-100/60 break-words" style={{ color: '#1A4D2E' }}>
                Administrasi Pengajuan
              </span>
            </h1>
            
            <p className="text-base sm:text-lg md:text-xl max-w-3xl mx-auto mb-8 md:mb-12 leading-relaxed px-4 text-slate-600 font-medium">
              Platform layanan usulan pengadaan barang, kegiatan, dan manajemen anggaran secara terintegrasi, cepat, dan transparan di lingkup Politeknik Negeri Jakarta.
            </p>
            
            <div className="flex flex-col sm:flex-row justify-center items-stretch sm:items-center gap-3 sm:gap-4 px-6 md:px-0">
              <Link to="/login" className="inline-flex items-center justify-center gap-2 px-6 sm:px-8 py-3.5 sm:py-4 rounded-2xl text-white font-bold text-base sm:text-lg transition-all hover:-translate-y-1 shadow-lg shadow-emerald-900/20" style={{ background: 'linear-gradient(135deg, #1A4D2E 0%, #2D6A4F 50%, #36C06C 100%)', backgroundSize: '200% 100%' }}>
                Masuk ke Sistem <ArrowRight className="size-5 shrink-0" />
              </Link>
              <a href="#features" className="inline-flex items-center justify-center gap-2 px-6 sm:px-8 py-3.5 sm:py-4 rounded-2xl font-semibold text-base sm:text-lg border-2 transition-all hover:-translate-y-0.5 bg-white/70 backdrop-blur-md" style={{ borderColor: '#c8e6c9', color: '#1A4D2E' }}>
                Mode Panduan <ChevronRight className="size-5 shrink-0" />
              </a>
            </div>
            
            <div className="mt-8 md:mt-12 flex items-center justify-center gap-4 text-sm font-medium text-slate-500 flex-wrap px-4">
               <div className="flex items-center gap-1.5"><CheckCircle2 className="size-4 text-emerald-500" /> Akses Cepat</div>
               <div className="flex items-center gap-1.5"><CheckCircle2 className="size-4 text-emerald-500" /> Bebas Kertas</div>
               <div className="flex items-center gap-1.5"><CheckCircle2 className="size-4 text-emerald-500" /> Transparan</div>
            </div>
          </motion.div>
        </div>
      </section>

      {/* Stats Section */}
      <section className="py-8 md:py-12 relative z-10 w-full overflow-hidden px-4 sm:px-6">
        <div className="max-w-4xl mx-auto">
          <div className="grid grid-cols-1 sm:grid-cols-3 gap-4 md:gap-6 p-6 sm:p-8 rounded-[2rem] shadow-[0_10px_40px_rgba(0,0,0,0.06)] border border-slate-100" style={{ background: 'rgba(255,255,255,0.9)', backdropFilter: 'blur(20px)' }}>
            {stats.map((s, i) => (
              <motion.div key={i} initial={{ opacity: 0, scale: 0.95 }} whileInView={{ opacity: 1, scale: 1 }} transition={{ delay: i * 0.1, duration: 0.5 }} viewport={{ once: true }} className="text-center p-4 bg-slate-50/50 rounded-2xl border border-slate-100/50">
                <s.icon className="size-7 md:size-8 mx-auto mb-3" style={{ color: '#36C06C' }} />
                <div className="text-3xl md:text-4xl font-black tracking-tight mb-1" style={{ color: '#0D2818' }}>{s.value}</div>
                <div className="text-xs md:text-sm text-emerald-800/70 font-semibold uppercase tracking-widest">{s.label}</div>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* Features Section */}
      <section id="features" className="py-20 md:py-32 w-full overflow-hidden" style={{ background: 'linear-gradient(180deg, #ffffff 0%, #f4fbf5 100%)' }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12 md:mb-20">
            <h2 className="text-3xl md:text-5xl font-extrabold mb-4 sm:mb-6 tracking-tight" style={{ color: '#0D2818' }}>Keunggulan Sistem</h2>
            <p className="text-slate-500 text-base md:text-lg max-w-2xl mx-auto px-4">Modul pengelolaan kegiatan yang didesain khusus untuk memenuhi tata kelola kampus dengan presisi yang tinggi.</p>
          </div>
          
          <div className="grid grid-cols-1 md:grid-cols-3 gap-6 md:gap-8">
            {features.map((f, i) => (
              <motion.div key={i} initial={{ opacity: 0, y: 30 }} whileInView={{ opacity: 1, y: 0 }} transition={{ delay: i * 0.15, duration: 0.6 }} viewport={{ once: true }}
                className="p-8 md:p-10 rounded-[2rem] border transition-all hover:-translate-y-2 hover:shadow-[0_20px_40px_rgba(26,77,46,0.08)] cursor-default bg-white relative overflow-hidden group"
                style={{ borderColor: 'rgba(200,230,201,0.6)' }}>
                <div className="absolute top-0 right-0 p-6 opacity-[0.03] pointer-events-none group-hover:scale-110 transition-transform duration-500">
                   <f.icon className="size-32" />
                </div>
                <div className="size-14 md:size-16 rounded-2xl flex items-center justify-center mb-6 md:mb-8" style={{ background: f.bg }}>
                  <f.icon className="size-7 md:size-8" style={{ color: f.color }} />
                </div>
                <h3 className="text-xl md:text-2xl font-bold mb-3 md:mb-4" style={{ color: '#064e3b' }}>{f.title}</h3>
                <p className="text-slate-600 leading-relaxed text-sm md:text-base font-medium">{f.desc}</p>
              </motion.div>
            ))}
          </div>
        </div>
      </section>

      {/* CTA Section */}
      <section className="py-20 md:py-28 relative overflow-hidden">
        <div className="absolute inset-0" style={{ background: '#0D2818' }} />
        <div className="absolute inset-0 bg-[url('https://www.transparenttextures.com/patterns/cubes.png')] opacity-10" />
        <div className="absolute rounded-full opacity-25 md:opacity-20 w-[300px] h-[300px] md:w-[600px] md:h-[600px] top-[-100px] right-[-100px] md:top-[-200px] md:right-[-200px]" style={{ background: 'radial-gradient(circle, #36C06C, transparent)', filter: 'blur(80px)' }} />
        <div className="absolute rounded-full opacity-20 hidden md:block w-[400px] h-[400px] bottom-[-150px] left-[-100px]" style={{ background: 'radial-gradient(circle, #2D6A4F, transparent)', filter: 'blur(80px)' }} />
        
        <div className="max-w-4xl mx-auto px-6 text-center relative z-10">
          <motion.div initial={{ opacity: 0, scale: 0.95 }} whileInView={{ opacity: 1, scale: 1 }} transition={{ duration: 0.6 }} viewport={{ once: true }}>
             <h2 className="text-3xl sm:text-4xl md:text-5xl font-extrabold text-white mb-6 md:mb-8 tracking-tight">Mulai Sistem Administrasi<br/>Sekarang Juga</h2>
             <p className="text-white/70 text-base md:text-xl md:leading-relaxed max-w-2xl mx-auto mb-8 md:mb-12">Login menggunakan NIP atau email institusi Anda untuk mengakses panel khusus di Sistem LATORJANA.</p>
             <Link to="/login" className="inline-flex items-center justify-center gap-2 w-full sm:w-auto px-8 md:px-10 py-4 md:py-5 rounded-2xl font-extrabold text-base md:text-lg transition-all hover:-translate-y-1 hover:shadow-[0_15px_40px_rgba(54,192,108,0.4)]" style={{ background: 'linear-gradient(135deg, #36C06C, #52DE97)', color: '#0D2818' }}>
               Akses Dashboard <ArrowRight className="size-5 md:size-6 shrink-0" />
             </Link>
          </motion.div>
        </div>
      </section>

      {/* Footer */}
      <footer className="py-8 md:py-12 border-t w-full overflow-hidden" style={{ borderColor: '#e8f5e9', background: '#f8faf8' }}>
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 flex flex-col md:flex-row justify-between items-center gap-6">
          <div className="flex flex-col items-center md:items-start gap-2">
             <div className="flex items-center gap-2">
               <AppLogo className="size-8 opacity-90 grayscale-0 hover:grayscale-0 transition-all drop-shadow-sm" />
               <span className="font-bold text-lg tracking-tight" style={{ color: '#1A4D2E' }}>LATORJANA</span>
             </div>
             <p className="text-slate-500 text-xs md:text-sm font-medium mt-1">Sistem Layanan Terpadu Administrasi Pengajuan.</p>
          </div>
          <div className="text-center md:text-right">
             <p className="text-slate-500 text-xs md:text-sm font-medium">© {new Date().getFullYear()} Politeknik Negeri Jakarta.<br className="md:hidden"/> Hak Cipta Dilindungi.</p>
          </div>
        </div>
      </footer>
    </div>
  );
}

