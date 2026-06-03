import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { apiListKegiatan } from '@/lib/api';
import { Package, Clock, ShieldCheck, CheckCircle, Plus, FileText, Loader2 } from 'lucide-react';
import { StatusBadge } from '@/components/StatusBadge';
import { Button } from '@/components/ui/button';
import { useNavigate, useOutletContext } from 'react-router-dom';
import { useEffect, useState } from 'react';

export function PengusulDashboard() {
  const navigate = useNavigate();
  const { setPageTourSteps } = useOutletContext<any>();
  const [usulanList, setUsulanList] = useState<any[]>([]);
  const [counts, setCounts] = useState({
    total: 0,
    menunggu: 0,
    berjalan: 0,
    selesai: 0
  });
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    setPageTourSteps([
      {
        target: '.tour-pengusul-header',
        content: (
          <div>
            <h3 className="font-bold text-slate-800 text-sm mb-1">Dashboard Pengusul</h3>
            <p className="text-slate-600 text-xs leading-relaxed">
              Ringkasan aktivitas dan metrik jumlah usulan Anda.
            </p>
          </div>
        ),
        placement: 'bottom',
        disableBeacon: true,
      },
      {
        target: '.tour-pengusul-add',
        content: (
          <div>
            <h3 className="font-bold text-slate-800 text-sm mb-1">Buat Usulan Baru</h3>
            <p className="text-slate-600 text-xs leading-relaxed">
              Tombol cepat untuk mulai membuat draf pengajuan baru.
            </p>
          </div>
        ),
        placement: 'left',
      },
      {
        target: '.tour-pengusul-stats',
        content: (
          <div>
            <h3 className="font-bold text-slate-800 text-sm mb-1">Statistik Real-time</h3>
            <p className="text-slate-600 text-xs leading-relaxed">
              Pantau progres berapa usulan yang sedang diajukan, berjalan, atau sudah selesai.
            </p>
          </div>
        ),
        placement: 'top',
      },
    ]);
  }, [setPageTourSteps]);

  useEffect(() => {
    const fetchUsulan = async () => {
      try {
        let userId: number | string = 1; // fallback
        try {
          const userStr = localStorage.getItem('currentUser');
          if (userStr) {
            const user = JSON.parse(userStr);
            userId = parseInt(user.id || user.user_id || '1', 10);
          }
        } catch (e) {
          console.log('Error reading auth session from localStorage', e);
        }

        const allRes = await apiListKegiatan();

        const allDocs = (allRes.data || allRes);
        setUsulanList(allDocs.slice(0, 5)); // Just take top 5 for the "Aktivitas Terakhir"

        let cTotal = allDocs.length;
        let cMenunggu = 0;
        let cBerjalan = 0;
        let cSelesai = 0;

        allDocs.forEach((doc: any) => {
          if (doc.status === 'selesai' || doc.status === 'completed' || doc.status === 'lpj_done') {
            cSelesai++;
          } else if (doc.status.startsWith('menunggu') || doc.status.startsWith('disetujui') || ['pending_ppk', 'approved_ppk', 'approved_wadir', 'accepted_funds', 'funds_disbursed'].includes(doc.status?.toLowerCase())) {
            cBerjalan++;
          } else if (['draft', 'diajukan', 'revisi', 'submitted', 'revisi_done', 'diverifikasi', 'verified'].includes(doc.status?.toLowerCase())) {
            cMenunggu++;
          }
        });

        setCounts({
          total: cTotal,
          menunggu: cMenunggu,
          berjalan: cBerjalan,
          selesai: cSelesai
        });
      } catch (error) {
        console.error(error);
      } finally {
        setIsLoading(false);
      }
    };
    fetchUsulan();
  }, []);

  return (
    <div className="space-y-6">
      <div className="tour-pengusul-header flex flex-col md:flex-row md:items-center justify-between gap-4">
        <div>
          <h2 className="text-2xl font-bold tracking-tight text-slate-900">Dashboard Pengusul</h2>
          <p className="text-slate-500">Selamat datang kembali! Berikut ringkasan usulan Anda.</p>
        </div>
        <Button onClick={() => navigate('/dashboard/pengusul/usulan/baru')} className="tour-pengusul-add bg-emerald-700 hover:bg-emerald-800">
          <Plus className="size-4 mr-2" />
          Buat Usulan Baru
        </Button>
      </div>

      {isLoading ? (
        <div className="py-12 flex justify-center"><Loader2 className="animate-spin text-emerald-700 size-8" /></div>
      ) : (
        <>
          <div className="tour-pengusul-stats grid grid-cols-2 lg:grid-cols-4 gap-3 sm:gap-4">
            <Card className="shadow-sm border-slate-200">
              <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
                <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
                  <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Total</p>
                  <div className="p-1 sm:p-2 rounded-xl bg-emerald-100 shrink-0">
                    <Package className="size-3.5 sm:size-4 text-emerald-700" />
                  </div>
                </div>
                <div className="flex items-baseline gap-2 mt-auto">
                  <h3 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{counts.total}</h3>
                </div>
              </CardContent>
            </Card>

            <Card className="shadow-sm border-slate-200">
              <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
                <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
                  <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Verifikasi</p>
                  <div className="p-1 sm:p-2 rounded-xl bg-amber-100 shrink-0">
                    <Clock className="size-3.5 sm:size-4 text-amber-600" />
                  </div>
                </div>
                <div className="flex items-baseline gap-2 mt-auto">
                  <h3 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{counts.menunggu}</h3>
                </div>
              </CardContent>
            </Card>

            <Card className="shadow-sm border-slate-200">
              <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
                <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
                  <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Berjalan</p>
                  <div className="p-1 sm:p-2 rounded-xl bg-indigo-100 shrink-0">
                    <ShieldCheck className="size-3.5 sm:size-4 text-indigo-600" />
                  </div>
                </div>
                <div className="flex items-baseline gap-2 mt-auto">
                  <h3 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{counts.berjalan}</h3>
                </div>
              </CardContent>
            </Card>

            <Card className="shadow-sm border-slate-200">
              <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
                <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
                  <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Selesai</p>
                  <div className="p-1 sm:p-2 rounded-xl bg-emerald-100 shrink-0">
                    <CheckCircle className="size-3.5 sm:size-4 text-emerald-600" />
                  </div>
                </div>
                <div className="flex items-baseline gap-2 mt-auto">
                  <h3 className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{counts.selesai}</h3>
                </div>
              </CardContent>
            </Card>
          </div>

          {/* Perlu Revisi Alert */}
          {usulanList.filter((i: any) => i.status === 'revision_requested').length > 0 && (
            <Card className="shadow-sm border-rose-200 bg-rose-50/30">
              <CardHeader className="border-b border-rose-100 bg-rose-50/50">
                <CardTitle className="text-base text-rose-800 flex items-center gap-2">
                  ⚠️ Usulan Perlu Direvisi ({usulanList.filter((i: any) => i.status === 'revision_requested').length})
                </CardTitle>
              </CardHeader>
              <CardContent className="p-0">
                <div className="divide-y divide-rose-100">
                  {usulanList.filter((i: any) => i.status === 'revision_requested').map((item: any) => (
                    <div key={item.id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 hover:bg-rose-50/50">
                      <div className="min-w-0">
                        <p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p>
                        {item.catatan_revisi && <p className="text-xs text-rose-700 mt-1 italic">Catatan: {item.catatan_revisi}</p>}
                      </div>
                      <Button size="sm" onClick={() => navigate(`/dashboard/pengusul/revisi/${item.id}`)} className="bg-rose-600 hover:bg-rose-700 shrink-0">
                        Perbaiki Sekarang
                      </Button>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          {/* Verified — siap diteruskan ke PPK */}
          {usulanList.filter((i: any) => i.status === 'verified' || i.status === 'diverifikasi').length > 0 && (
            <Card className="shadow-sm border-emerald-200 bg-emerald-50/20">
              <CardHeader className="border-b border-emerald-100 bg-emerald-50/30">
                <CardTitle className="text-base text-emerald-800 flex items-center gap-2">
                  ✅ Terverifikasi – Siap Diteruskan ke PPK ({usulanList.filter((i: any) => i.status === 'verified' || i.status === 'diverifikasi').length})
                </CardTitle>
              </CardHeader>
              <CardContent className="p-0">
                <div className="divide-y divide-emerald-100">
                  {usulanList.filter((i: any) => i.status === 'verified' || i.status === 'diverifikasi').map((item: any) => (
                    <div key={item.id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 hover:bg-emerald-50/50">
                      <div className="min-w-0">
                        <p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p>
                        <p className="text-xs text-emerald-700 mt-1">Diverifikasi · Klik "Teruskan ke PPK" di halaman detail</p>
                      </div>
                      <Button size="sm" variant="outline" onClick={() => navigate(`/dashboard/pengusul/usulan/${item.id}`)} className="text-emerald-700 border-emerald-300 hover:bg-emerald-50 shrink-0">
                        Teruskan ke PPK
                      </Button>
                    </div>
                  ))}
                </div>
              </CardContent>
            </Card>
          )}

          <Card className="shadow-sm border-slate-200">
            <CardHeader className="border-b border-slate-100 bg-slate-50/50">
              <CardTitle className="text-lg">Aktivitas Terakhir</CardTitle>
            </CardHeader>
            <CardContent className="p-0">
              <div className="divide-y divide-slate-100">
                {usulanList.length === 0 ? (
                  <div className="p-8 text-center text-slate-500">Anda belum membuat usulan kegiatan.</div>
                ) : (
                  usulanList.map((item) => (
                    <div key={item.id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 sm:gap-4 hover:bg-slate-50 transition-colors">
                      <div className="flex items-start sm:items-center gap-3 sm:gap-4 min-w-0">
                        <div className="p-2.5 rounded-full bg-slate-100 text-slate-500 shrink-0">
                          <FileText className="size-5" />
                        </div>
                        <div className="min-w-0">
                          <p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p>
                          <p className="text-sm text-slate-500">{new Date(item.created_at).toLocaleDateString('id-ID')}</p>
                        </div>
                      </div>
                      <div className="ml-12 sm:ml-0 shrink-0">
                        <StatusBadge status={item.status} />
                      </div>
                    </div>
                  ))
                )}
              </div>
            </CardContent>
          </Card>
        </>
      )}
    </div>
  );
}

// End of component
