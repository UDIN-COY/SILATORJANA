import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { apiListKegiatan } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { formatDate } from '@/lib/helpers';
import { Eye, CheckCircle, Clock, FileText, Loader2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';

export function WadirDashboard() {
  const navigate = useNavigate();
  const [items, setItems] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const res = await apiListKegiatan();
        setItems((res.data || res));
      } catch (e) { console.error(e); } finally { setIsLoading(false); }
    })();
  }, []);

  // Menunggu persetujuan Wadir: setelah PPK menyetujui
  const pendingReview = items.filter(i => i.status === 'approved_ppk');
  // Proposal yang dikembalikan untuk revisi oleh Wadir
  const inRevision = items.filter(i => i.status === 'revision_requested');
  const approved = items.filter(i => ['approved_wadir', 'accepted_funds', 'funds_disbursed', 'completed', 'lpj_done', 'lpj_approved'].includes(i.status));

  if (isLoading) return <div className="py-12 flex justify-center"><Loader2 className="animate-spin text-blue-600 size-8" /></div>;

  return (
    <div className="space-y-6">
      <div><h2 className="text-2xl font-bold text-slate-900">Dashboard Wadir</h2><p className="text-slate-500">Persetujuan kegiatan tingkat Wakil Direktur.</p></div>

      <div className="grid grid-cols-2 sm:grid-cols-3 gap-3 sm:gap-4">
        <Card className="shadow-sm border-slate-200">
          <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
            <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
              <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Menunggu</p>
              <div className="p-1.5 sm:p-3 rounded-xl bg-amber-100 shrink-0"><Clock className="size-3.5 sm:size-5 text-amber-600" /></div>
            </div>
            <div className="flex items-baseline gap-2 mt-auto">
              <p className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{pendingReview.length}</p>
            </div>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200">
          <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
            <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
              <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Disetujui</p>
              <div className="p-1.5 sm:p-3 rounded-xl bg-emerald-100 shrink-0"><CheckCircle className="size-3.5 sm:size-5 text-emerald-600" /></div>
            </div>
            <div className="flex items-baseline gap-2 mt-auto">
              <p className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{approved.length}</p>
            </div>
          </CardContent>
        </Card>
        <Card className="shadow-sm border-slate-200 col-span-2 sm:col-span-1">
          <CardContent className="p-4 sm:p-6 flex flex-col justify-between h-full">
            <div className="flex items-start sm:items-center justify-between pb-2 gap-1 sm:gap-2">
              <p className="text-[11px] sm:text-sm font-medium text-slate-600 leading-tight">Total</p>
              <div className="p-1.5 sm:p-3 rounded-xl bg-blue-100 shrink-0"><FileText className="size-3.5 sm:size-5 text-blue-600" /></div>
            </div>
            <div className="flex items-baseline gap-2 mt-auto">
              <p className="text-2xl sm:text-3xl font-bold tracking-tight text-slate-900">{items.length}</p>
            </div>
          </CardContent>
        </Card>
      </div>

      {/* Menunggu Persetujuan Wadir */}
      {pendingReview.length > 0 && (
        <Card className="shadow-sm border-amber-200 bg-amber-50/30">
          <CardHeader className="border-b border-amber-100">
            <CardTitle className="text-base text-amber-800">Menunggu Persetujuan Wadir ({pendingReview.length})</CardTitle>
          </CardHeader>
          <CardContent className="p-0"><div className="divide-y divide-amber-100">
            {pendingReview.map(item => (
              <div key={item.id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 sm:gap-4 hover:bg-amber-50/50">
                <div className="min-w-0">
                  <p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p>
                  <p className="text-xs text-slate-500 mt-1">{formatDate(item.created_at)} · Disetujui PPK</p>
                </div>
                <div className="shrink-0">
                  <Button size="sm" onClick={() => navigate(`/dashboard/wadir2/review/${item.id}`)} className="bg-emerald-700 hover:bg-emerald-800">
                    <Eye className="size-4 mr-1" />Review
                  </Button>
                </div>
              </div>
            ))}
          </div></CardContent>
        </Card>
      )}

      {/* Proposal yang dikembalikan untuk revisi */}
      {inRevision.length > 0 && (
        <Card className="shadow-sm border-rose-200 bg-rose-50/20">
          <CardHeader className="border-b border-rose-100">
            <CardTitle className="text-base text-rose-700">Dikembalikan untuk Revisi ({inRevision.length})</CardTitle>
          </CardHeader>
          <CardContent className="p-0"><div className="divide-y divide-rose-100">
            {inRevision.map(item => (
              <div key={item.id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 sm:gap-4 hover:bg-rose-50/30">
                <div className="min-w-0">
                  <p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p>
                  <p className="text-xs text-slate-500 mt-1">{formatDate(item.created_at)} · Menunggu perbaikan dari pengusul</p>
                </div>
                <div className="shrink-0">
                  <Button size="sm" variant="outline" onClick={() => navigate(`/dashboard/wadir2/review/${item.id}`)} className="text-rose-600 border-rose-200 hover:bg-rose-50">
                    <Eye className="size-4 mr-1" />Lihat
                  </Button>
                </div>
              </div>
            ))}
          </div></CardContent>
        </Card>
      )}
    </div>
  );
}
