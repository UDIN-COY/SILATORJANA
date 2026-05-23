import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { apiListKegiatan } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/StatusBadge';
import { formatDate } from '@/lib/helpers';
import { Eye, Loader2 } from 'lucide-react';
import { useNavigate } from 'react-router-dom';
import { useState, useEffect } from 'react';

export function BendaharaProposalList() {
  const navigate = useNavigate();
  const [items, setItems] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    (async () => {
      try {
        const res = await apiListKegiatan();
        setItems((res.data || res).filter((d: any) => ['approved_wadir','accepted_funds','funds_disbursed','lpj_submitted','lpj_approved','lpj_done','completed'].includes(d.status?.toLowerCase())));
      } catch (e) { console.error(e); } finally { setIsLoading(false); }
    })();
  }, []);

  return (
    <div className="space-y-6">
      <div><h2 className="text-2xl font-bold text-slate-900">Pencairan & LPJ</h2><p className="text-slate-500">Kelola pencairan dana dan verifikasi LPJ.</p></div>
      <Card className="shadow-sm border-slate-200">
        <CardContent className="p-0">
          {isLoading ? <div className="py-12 text-center"><Loader2 className="animate-spin text-blue-600 mx-auto" /></div> :
          items.length === 0 ? <div className="py-12 text-center text-slate-500">Belum ada kegiatan.</div> :
          <div className="divide-y divide-slate-100">
            {items.map(item => (
              <div key={item.id} className="flex flex-col sm:flex-row sm:items-center justify-between p-4 gap-3 sm:gap-4 hover:bg-slate-50/50">
                <div className="min-w-0"><p className="font-semibold text-slate-900 truncate">{item.nama_kegiatan}</p><p className="text-xs text-slate-500 mt-1">{formatDate(item.created_at)}</p></div>
                <div className="flex items-center gap-3 shrink-0"><StatusBadge status={item.status} />
                  <Button size="sm" variant="outline" onClick={() => navigate(`/dashboard/bendahara/detail/${item.id}`)}><Eye className="size-4 mr-1" />Detail</Button>
                </div>
              </div>
            ))}
          </div>}
        </CardContent>
      </Card>
    </div>
  );
}
