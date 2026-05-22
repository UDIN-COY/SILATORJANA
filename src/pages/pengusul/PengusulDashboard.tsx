import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Package, Clock, ShieldCheck, CheckCircle, Plus, FileText, Loader2 } from 'lucide-react';
import { StatusBadge } from '@/components/StatusBadge';
import { Button } from '@/components/ui/button';
import { useNavigate, useOutletContext } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { account, databases, APPWRITE_DB_ID } from '@/lib/appwrite';
import { Query } from 'appwrite';

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
            userId = parseInt(user.$id || user.user_id || '1', 10);
          }
        } catch (e) {
          console.log('Error reading auth session from localStorage', e);
        }

        const allRes = await databases.listDocuments(APPWRITE_DB_ID, 'kegiatan', [
          Query.equal('pengusul_id', userId),
          Query.orderDesc('$createdAt'),
        ]);

        const allDocs = allRes.documents;
        setUsulanList(allDocs.slice(0, 5)); // Just take top 5 for the "Aktivitas Terakhir"

        let cTotal = allDocs.length;
        let cMenunggu = 0;
        let cBerjalan = 0;
        let cSelesai = 0;

        allDocs.forEach((doc: any) => {
          if (doc.status === 'selesai' || doc.status === 'completed' || doc.status === 'lpj_done') {
            cSelesai++;
          } else if (doc.status.startsWith('menunggu') || doc.status.startsWith('disetujui') || doc.status === 'pending_ppk' || doc.status === 'approved_ppk' || doc.status === 'approved_wadir') {
            cBerjalan++;
          } else if (doc.status === 'draft' || doc.status === 'diajukan' || doc.status === 'revisi' || doc.status === 'submitted' || doc.status === 'diverifikasi') {
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
                    <div key={item.$id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 sm:gap-4 hover:bg-slate-50 transition-colors">
                      <div className="flex items-start sm:items-center gap-3 sm:gap-4 min-w-0">
                        <div className="p-2.5 rounded-full bg-slate-100 text-slate-500 shrink-0">
                          <FileText className="size-5" />
                        </div>
                        <div className="min-w-0">
                          <p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p>
                          <p className="text-sm text-slate-500">{new Date(item.$createdAt).toLocaleDateString('id-ID')}</p>
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
