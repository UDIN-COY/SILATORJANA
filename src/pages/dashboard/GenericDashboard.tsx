import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { useLocation, useOutletContext } from 'react-router-dom';
import { Package, Clock, ShieldCheck, CheckCircle } from 'lucide-react';
import { useEffect } from 'react';

export function GenericDashboard() {
  const location = useLocation();
  const role = location.pathname.split('/')[2] || 'Pengguna';
  const { setPageTourSteps } = useOutletContext<any>();

  useEffect(() => {
    setPageTourSteps([
      {
        target: '.tour-dashboard-header',
        content: (
          <div>
            <h3 className="font-bold text-slate-800 text-sm mb-1">Halaman Dashboard</h3>
            <p className="text-slate-600 text-xs leading-relaxed">
              Selamat datang di Dashboard. Ini adalah halaman utama untuk melihat gambaran umum aktivitas Anda di sistem.
            </p>
          </div>
        ),
        placement: 'bottom',
        disableBeacon: true,
      },
      {
        target: '.tour-dashboard-stats',
        content: (
          <div>
            <h3 className="font-bold text-slate-800 text-sm mb-1">Metrik Aktivitas</h3>
            <p className="text-slate-600 text-xs leading-relaxed">
              Kartu-kartu ini menampilkan riwayat pengajuan dan metrik penting lainnya secara cepat dan real-time.
            </p>
          </div>
        ),
        placement: 'top',
      },
      {
        target: '.tour-dashboard-recent',
        content: (
          <div>
            <h3 className="font-bold text-slate-800 text-sm mb-1">Aktivitas Terakhir</h3>
            <p className="text-slate-600 text-xs leading-relaxed">
              Pantau dokumen atau aktivitas terbaru yang masuk dan perlu perhatian Anda di daftar ini.
            </p>
          </div>
        ),
        placement: 'top',
      }
    ]);
  }, [setPageTourSteps]);

  return (
    <div className="space-y-6 sm:space-y-8 animate-in fade-in slide-in-from-bottom-4 duration-500 pb-8 sm:pb-12">
      <div className="tour-dashboard-header pb-3 sm:pb-4 border-b border-slate-100/60">
        <h2 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-800 capitalize">Dashboard {role.replace('-', ' ')}</h2>
        <p className="text-[14px] sm:text-[15px] font-medium text-slate-500 mt-1 sm:mt-2">Gambaran umum aktivitas dan metriks panel {role.replace('-', ' ')} dalam sistem.</p>
      </div>

      <div className="tour-dashboard-stats grid grid-cols-2 lg:grid-cols-3 gap-3 sm:gap-6">
        <Card className="shadow-sm border-slate-200/60 hover:shadow-md transition-shadow bg-white rounded-2xl overflow-hidden relative">
          <div className="absolute top-0 right-0 p-3 opacity-5 pointer-events-none">
             <Package className="size-16 sm:size-24 text-blue-900" />
          </div>
          <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
            <div className="flex items-start sm:items-center justify-between space-y-0 pb-2 gap-2">
              <p className="text-[10px] sm:text-xs font-bold uppercase tracking-widest text-slate-500 leading-tight">Usulan Aktif</p>
              <div className="p-1.5 sm:p-2.5 rounded-xl bg-blue-50/80 border border-blue-100/50 shadow-sm shrink-0">
                <Package className="size-3.5 sm:size-4.5 text-blue-600" />
              </div>
            </div>
            <div className="flex items-baseline pt-2 sm:pt-4 relative z-10 mt-auto">
              <h3 className="text-2xl sm:text-4xl font-extrabold tracking-tight text-slate-800">24</h3>
            </div>
          </CardContent>
        </Card>

        <Card className="shadow-sm border-slate-200/60 hover:shadow-md transition-shadow bg-white rounded-2xl overflow-hidden relative">
          <div className="absolute top-0 right-0 p-3 opacity-5 pointer-events-none">
             <Clock className="size-16 sm:size-24 text-amber-900" />
          </div>
          <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
            <div className="flex items-start sm:items-center justify-between space-y-0 pb-2 gap-2">
              <p className="text-[10px] sm:text-xs font-bold uppercase tracking-widest text-slate-500 leading-tight">Tindakan</p>
              <div className="p-1.5 sm:p-2.5 rounded-xl bg-amber-50/80 border border-amber-100/50 shadow-sm shrink-0">
                <Clock className="size-3.5 sm:size-4.5 text-amber-600" />
              </div>
            </div>
            <div className="flex items-baseline pt-2 sm:pt-4 relative z-10 mt-auto">
              <h3 className="text-2xl sm:text-4xl font-extrabold tracking-tight text-slate-800">8</h3>
            </div>
          </CardContent>
        </Card>
        
        <Card className="shadow-sm border-slate-200/60 hover:shadow-md transition-shadow bg-white rounded-2xl overflow-hidden relative col-span-2 lg:col-span-1">
          <div className="absolute top-0 right-0 p-3 opacity-5 pointer-events-none">
             <CheckCircle className="size-16 sm:size-24 text-emerald-900" />
          </div>
          <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
            <div className="flex items-start sm:items-center justify-between space-y-0 pb-2 gap-2">
              <p className="text-[10px] sm:text-xs font-bold uppercase tracking-widest text-slate-500 leading-tight">Selesai</p>
              <div className="p-1.5 sm:p-2.5 rounded-xl bg-[#047857]/10 border border-emerald-100/50 shadow-sm shrink-0">
                <CheckCircle className="size-3.5 sm:size-4.5 text-[#047857]" />
              </div>
            </div>
            <div className="flex items-baseline pt-2 sm:pt-4 relative z-10 mt-auto">
              <h3 className="text-2xl sm:text-4xl font-extrabold tracking-tight text-slate-800">12</h3>
            </div>
          </CardContent>
        </Card>
      </div>

      <Card className="relative shadow-sm border-slate-200/60 overflow-hidden bg-white rounded-2xl">
         <div className="absolute inset-0 bg-gradient-to-br from-slate-50/50 to-white -z-10 pointer-events-none" />
         <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-5 px-8">
           <CardTitle className="text-lg text-slate-800">Ringkasan Area Kerja</CardTitle>
           <CardDescription className="text-[14px] font-medium text-slate-500 tracking-tight mt-1">Menampilkan tugas spesifik berdasarkan peran <strong className="text-slate-700 capitalize">{role.replace('-', ' ')}</strong> pada workflow usulan.</CardDescription>
         </CardHeader>
         <CardContent className="p-8">
           <div className="py-20 text-center border-2 border-dashed border-slate-200/80 rounded-2xl bg-white shadow-[inset_0_0_20px_rgba(0,0,0,0.01)] transition-all">
             <div className="inline-flex items-center justify-center size-16 rounded-full bg-slate-50 mb-5 shadow-sm border border-slate-100/80">
               <ShieldCheck className="size-7 text-slate-400" />
             </div>
             <h3 className="text-lg font-bold text-slate-800">Belum Ada Data Tugas</h3>
             <p className="text-[14px] text-slate-500 mt-2 max-w-md mx-auto font-medium leading-relaxed">
               Saat ini belum ada data terperinci yang memerlukan perhatian Anda untuk peran <span className="text-slate-700 font-semibold capitalize">{role.replace('-', ' ')}</span>.
             </p>
           </div>
         </CardContent>
      </Card>
    </div>
  );
}
