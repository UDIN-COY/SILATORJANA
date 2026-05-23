import { Card, CardContent } from '@/components/ui/card';
import { apiGetKegiatan, apiUpdateKegiatan } from '@/lib/api';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/StatusBadge';
import { ArrowLeft, Save, Send, Loader2, MessageSquare, FileText, TrendingUp, DollarSign, Info } from 'lucide-react';
import { useNavigate, useParams, useSearchParams } from 'react-router-dom';
import { useEffect, useState } from 'react';
import { fetchKAK, fetchIKU, fetchRAB, formatCurrency, formatDate } from '@/lib/helpers';

const TABS = [
  { key: 'info', label: 'Info Kegiatan', icon: Info },
  { key: 'kak', label: 'KAK', icon: FileText },
  { key: 'iku', label: 'IKU', icon: TrendingUp },
  { key: 'rab', label: 'RAB', icon: DollarSign },
];

export function RevisiFormPage() {
  const { id } = useParams();
  const [searchParams] = useSearchParams();
  const navigate = useNavigate();
  const initialTab = searchParams.get('tab') || 'info';
  const [activeTab, setActiveTab] = useState(initialTab);
  const [kegiatan, setKegiatan] = useState<any>(null);
  const [kak, setKak] = useState<any>(null);
  const [ikuList, setIkuList] = useState<any[]>([]);
  const [rabList, setRabList] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [comments, setComments] = useState<Record<string, string>>({});
  const [isSaving, setIsSaving] = useState(false);

  useEffect(() => {
    if (!id) return;
    (async () => {
      try {
        const doc = await apiGetKegiatan(id);
        setKegiatan(doc);
        const [k, i, r] = await Promise.all([fetchKAK(id), fetchIKU(id), fetchRAB(id)]);
        setKak(k); setIkuList(i); setRabList(r);
      } catch (e) { console.error(e); } finally { setIsLoading(false); }
    })();
  }, [id]);

  const handleCommentChange = (field: string, value: string) => {
    setComments(prev => ({ ...prev, [field]: value }));
  };

  const handleSubmitRevision = async () => {
    if (!id) return;
    setIsSaving(true);
    try {
      const catatan = Object.entries(comments)
        .filter(([, v]) => (v as string).trim())
        .map(([k, v]) => `[${k}]: ${v}`)
        .join('\n');
      
      await apiUpdateKegiatan(id, {
        status: 'revision_requested',
        catatan_revisi: catatan || 'Perlu revisi',
      });
      alert('Revisi berhasil dikirim!');
      navigate('/dashboard/verifikator/proposals');
    } catch (e: any) {
      console.error(e);
      alert('Gagal mengirim revisi: ' + (e.message || ''));
    } finally { setIsSaving(false); }
  };

  if (isLoading) return <div className="py-12 text-center"><Loader2 className="animate-spin text-blue-600 mx-auto size-8" /></div>;
  if (!kegiatan) return <div className="py-12 text-center text-slate-500">Data tidak ditemukan.</div>;

  const rabTotal = rabList.reduce((sum: number, r: any) => sum + (parseFloat(r.total) || 0), 0);
  const hasComments = Object.values(comments).some(v => (v as string).trim());

  const CommentBox = ({ field }: { field: string }) => (
    <div className="mt-3 flex items-start gap-2">
      <MessageSquare className="size-4 text-amber-500 mt-2 shrink-0" />
      <textarea
        className="w-full border border-slate-200 rounded-lg p-3 text-sm focus:border-blue-400 focus:ring-1 focus:ring-blue-400 outline-none resize-none bg-amber-50/50"
        rows={2}
        placeholder={`Catatan revisi untuk ${field}...`}
        value={comments[field] || ''}
        onChange={e => handleCommentChange(field, e.target.value)}
      />
    </div>
  );

  return (
    <div className="space-y-6 max-w-5xl mx-auto animate-in fade-in slide-in-from-bottom-4 duration-500 pb-20">
      <div className="flex flex-col sm:flex-row sm:items-center gap-4 py-4 border-b border-slate-100/60">
        <Button variant="outline" size="icon" onClick={() => navigate(-1)} className="shrink-0 h-10 w-10 border-slate-200 text-slate-500 hover:text-slate-800 hover:bg-slate-100/50 shadow-sm transition-all rounded-xl"><ArrowLeft className="size-5" /></Button>
        <div className="flex-1">
          <div className="flex items-center gap-3 mb-1">
             <h2 className="text-3xl font-bold text-slate-800 tracking-tight">Formulir Pengecekan & Revisi</h2>
             <span className="bg-amber-100 text-amber-800 text-xs font-bold px-2.5 py-1 rounded-md border border-amber-200/50">Draft</span>
          </div>
          <p className="text-[15px] font-medium text-slate-500">{kegiatan.nama_kegiatan}</p>
        </div>
        <div className="mt-2 sm:mt-0">
           <StatusBadge status={kegiatan.status} />
        </div>
      </div>

      <div className="bg-amber-50 border border-amber-200/50 rounded-2xl p-5 flex items-start gap-4 shadow-sm mb-8">
         <div className="bg-amber-100/80 p-2 rounded-lg shrink-0">
            <MessageSquare className="size-5 text-amber-600" />
         </div>
         <div>
            <h4 className="text-[15px] font-bold text-amber-900 mb-1">Mode Pemberian Catatan Revisi Aktif</h4>
            <p className="text-[14px] text-amber-800/80 leading-relaxed max-w-3xl">Pilih tab di bawah ini untuk melihat bagian spesifik dari dokumen, lalu isikan catatan revisi pada kotak komentar terkait jika terdapat kesalahan atau hal yang perlu diperbaiki oleh pengusul.</p>
         </div>
      </div>

      {/* Tab Navigation */}
      <div className="flex bg-slate-100/50 rounded-xl border border-slate-200/60 p-1.5 gap-1.5 overflow-x-auto shadow-sm">
        {TABS.map(tab => (
          <button key={tab.key}
            className={`flex-1 px-4 py-3 text-[13px] font-bold uppercase tracking-wider rounded-lg transition-all whitespace-nowrap text-center flex items-center justify-center gap-2.5 relative ${
              activeTab === tab.key 
                ? 'bg-amber-500 text-white shadow-md shadow-amber-500/20 translate-y-0' 
                : 'text-slate-500 hover:text-slate-800 hover:bg-white border border-transparent hover:border-slate-200/60 hover:shadow-sm'
            }`}
             onClick={() => setActiveTab(tab.key)}>
             <tab.icon className={`size-4.5 ${activeTab === tab.key ? 'text-white' : 'text-slate-400'}`} /> {tab.label}
             {comments[tab.key] && <span className="absolute top-2 right-2 size-2 bg-red-500 rounded-full shadow-sm" />}
          </button>
        ))}
      </div>

      {/* Info Kegiatan Tab */}
      {activeTab === 'info' && (
        <Card className="shadow-sm border-slate-200/60 bg-white overflow-hidden relative">
           <div className="absolute top-0 left-0 w-1.5 h-full bg-blue-500"></div>
           <CardContent className="p-8 space-y-8">
             <div className="flex items-center gap-3 border-b border-slate-100 pb-4">
                <Info className="size-6 text-blue-500" />
                <h3 className="text-xl font-bold text-slate-800 tracking-tight">Informasi Utama Kegiatan</h3>
             </div>
             
             <div className="grid grid-cols-1 gap-8">
                <div className="space-y-4">
                   <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 p-5 rounded-2xl bg-slate-50/50 border border-slate-100">
                      <div className="sm:w-1/3 shrink-0"><span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-1">Nama Terdaftar Kegiatan</span><p className="font-semibold text-slate-800 text-[15px]">{kegiatan.nama_kegiatan}</p></div>
                      <div className="sm:w-2/3 w-full"><CommentBox field="Info - Nama Kegiatan" /></div>
                   </div>
                   
                   <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 p-5 rounded-2xl bg-slate-50/50 border border-slate-100">
                      <div className="sm:w-1/3 shrink-0"><span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-1">Kategori / Jenis Kegiatan</span><p className="font-semibold text-slate-800 text-[15px]">{kegiatan.jenis_kegiatan || '-'}</p></div>
                      <div className="sm:w-2/3 w-full"><CommentBox field="Info - Jenis Kegiatan" /></div>
                   </div>

                   <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 p-5 rounded-2xl bg-slate-50/50 border border-slate-100">
                      <div className="sm:w-1/3 shrink-0"><span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-1">Jurusan Terkait</span><p className="font-semibold text-slate-800 text-[15px]">{kegiatan.nama_jurusan || '-'}</p></div>
                      <div className="sm:w-2/3 w-full"><CommentBox field="Info - Jurusan" /></div>
                   </div>

                   <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 p-5 rounded-2xl bg-slate-50/50 border border-slate-100">
                      <div className="sm:w-1/3 shrink-0"><span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-1">Identitas Pengusul</span><p className="font-semibold text-slate-800 text-[15px]">{kegiatan.pengusul_nama || '-'}</p></div>
                      <div className="sm:w-2/3 w-full"><CommentBox field="Info - Pengusul" /></div>
                   </div>
                </div>
             </div>
           </CardContent>
        </Card>
      )}

      {/* KAK Tab */}
      {activeTab === 'kak' && (
        <Card className="shadow-sm border-slate-200/60 bg-white overflow-hidden relative">
           <div className="absolute top-0 left-0 w-1.5 h-full bg-indigo-500"></div>
           <CardContent className="p-8 space-y-8">
             <div className="flex items-center gap-3 border-b border-slate-100 pb-4">
                <FileText className="size-6 text-indigo-500" />
                <h3 className="text-xl font-bold text-slate-800 tracking-tight">Rincian Kerangka Acuan Kerja (KAK)</h3>
             </div>
             
             {kak ? (
               <div className="grid grid-cols-1 gap-8">
                 {['gambaran_umum', 'penerima_manfaat', 'strategi_pencapaian', 'metode_pelaksanaan', 'tahapan_pelaksanaan'].map(key => (
                   <div key={key} className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 p-5 rounded-2xl bg-slate-50/50 border border-slate-100">
                      <div className="sm:w-1/3 shrink-0">
                         <span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-2">{key.replace(/_/g, ' ')}</span>
                         <p className="font-medium text-slate-700 text-[14px] leading-relaxed line-clamp-4">{kak[key] || '-'}</p>
                      </div>
                      <div className="sm:w-2/3 w-full"><CommentBox field={`KAK - ${key.replace(/_/g, ' ')}`} /></div>
                   </div>
                 ))}
                 {kak.kurun_waktu_mulai && (
                   <div className="flex flex-col sm:flex-row sm:items-start justify-between gap-4 p-5 rounded-2xl bg-slate-50/50 border border-slate-100">
                     <div className="sm:w-1/3 shrink-0">
                        <span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-2">Kurun Waktu Operasional</span>
                        <p className="font-semibold text-slate-800 text-[15px]">{formatDate(kak.kurun_waktu_mulai)} — {formatDate(kak.kurun_waktu_selesai)}</p>
                     </div>
                     <div className="sm:w-2/3 w-full"><CommentBox field="KAK - Kurun Waktu Operasional" /></div>
                   </div>
                 )}
               </div>
             ) : (
                <div className="py-12 flex flex-col items-center justify-center text-slate-500">
                   <FileText className="size-10 mb-4 opacity-50" />
                   <p className="font-semibold text-lg">Data KAK Kosong.</p>
                   <p className="text-sm">Dokumen Kerangka Acuan belum diinput oleh pengusul.</p>
                </div>
             )}
           </CardContent>
        </Card>
      )}

      {/* IKU Tab */}
      {activeTab === 'iku' && (
        <Card className="shadow-sm border-slate-200/60 bg-white overflow-hidden relative">
           <div className="absolute top-0 left-0 w-1.5 h-full bg-teal-500"></div>
           <CardContent className="p-8 space-y-8">
             <div className="flex items-center gap-3 border-b border-slate-100 pb-4">
                <TrendingUp className="size-6 text-teal-500" />
                <h3 className="text-xl font-bold text-slate-800 tracking-tight">Indikator Kinerja Utama (IKU)</h3>
             </div>
             
             {ikuList.length > 0 ? (
               <div className="grid grid-cols-1 gap-6">
                 {ikuList.map((iku: any, i: number) => (
                   <div key={iku.id || i} className="flex flex-col sm:flex-row sm:items-start justify-between gap-6 p-5 rounded-2xl bg-white border border-slate-200 shadow-sm">
                     <div className="sm:w-1/3 shrink-0 flex flex-col justify-between h-full">
                        <div>
                           <span className="text-slate-400 text-xs font-bold uppercase tracking-widest block mb-2">Item IKU #{i+1}</span>
                           <p className="font-bold text-slate-800 text-[15px] leading-snug">{iku.nama_iku || iku.indikator || '-'}</p>
                        </div>
                        <div className="mt-4 inline-block bg-teal-50 px-3 py-1.5 rounded border border-teal-100/50 w-fit">
                           <span className="text-xs text-teal-600 font-semibold uppercase tracking-wider block">Target Keberhasilan</span>
                           <span className="font-black text-teal-700 text-lg">{iku.target_persen != null ? `${iku.target_persen}%` : '-'}</span>
                        </div>
                     </div>
                     <div className="sm:w-2/3 w-full"><CommentBox field={`IKU #${i + 1}`} /></div>
                   </div>
                 ))}
               </div>
             ) : (
                <div className="py-12 flex flex-col items-center justify-center text-slate-500">
                   <TrendingUp className="size-10 mb-4 opacity-50" />
                   <p className="font-semibold text-lg">Data IKU Kosong.</p>
                   <p className="text-sm">Dokumen Indikator kinerja belum direkam.</p>
                </div>
             )}
           </CardContent>
        </Card>
      )}

      {/* RAB Tab */}
      {activeTab === 'rab' && (
        <Card className="shadow-sm border-slate-200/60 bg-white overflow-hidden relative">
           <div className="absolute top-0 left-0 w-1.5 h-full bg-emerald-500"></div>
           <CardContent className="p-8 space-y-8">
             <div className="flex items-center justify-between border-b border-slate-100 pb-4">
                <div className="flex items-center gap-3">
                   <DollarSign className="size-6 text-emerald-500" />
                   <h3 className="text-xl font-bold text-slate-800 tracking-tight">Rincian Anggaran (RAB)</h3>
                </div>
                <div className="bg-emerald-50 px-4 py-2 rounded-xl border border-emerald-100/60 text-emerald-800">
                   <span className="text-[11px] font-bold uppercase tracking-widest block mb-0.5 opacity-80">Total Kalkulasi</span>
                   <span className="font-black text-lg">{formatCurrency(rabTotal)}</span>
                </div>
             </div>
             
             {rabList.length > 0 ? (
                <div className="grid grid-cols-1 gap-6">
                  {rabList.map((r: any, i: number) => (
                    <div key={r.id || i} className="flex flex-col sm:flex-row sm:items-start justify-between gap-6 p-6 rounded-2xl bg-white border border-slate-200 shadow-sm relative overflow-hidden">
                      <div className="absolute top-0 left-0 w-1 h-full bg-slate-200/60"></div>
                      <div className="sm:w-2/5 shrink-0">
                         <span className="text-slate-400 text-[11px] font-bold uppercase tracking-widest block mb-2">Item Anggaran #{i+1} <span className="bg-slate-100 px-2 py-0.5 rounded text-slate-500 ml-2">{r.kategori || '-'}</span></span>
                         <p className="font-bold text-slate-800 text-[15px] mb-4">{r.uraian}</p>
                         
                         <div className="grid grid-cols-2 gap-4">
                            <div>
                               <span className="text-slate-400 text-[10px] font-bold uppercase tracking-widest block mb-0.5">Biaya Satuan</span>
                               <span className="font-semibold text-slate-600 text-sm">{formatCurrency(r.harga_satuan)}</span>
                            </div>
                            <div>
                               <span className="text-slate-400 text-[10px] font-bold uppercase tracking-widest block mb-0.5">Total Harga</span>
                               <span className="font-bold text-slate-800 text-[15px]">{formatCurrency(r.total)}</span>
                            </div>
                         </div>
                      </div>
                      <div className="sm:w-3/5 w-full bg-amber-50/30 p-2 rounded-xl"><CommentBox field={`RAB Item #${i+1} (${r.uraian})`} /></div>
                    </div>
                  ))}
                </div>
             ) : (
                <div className="py-12 flex flex-col items-center justify-center text-slate-500">
                   <DollarSign className="size-10 mb-4 opacity-50" />
                   <p className="font-semibold text-lg">Data RAB Kosong.</p>
                   <p className="text-sm">Rincian biaya anggaran belum dirancang.</p>
                </div>
             )}
           </CardContent>
        </Card>
      )}

      {/* Submit Bar */}
      <div className="fixed bottom-0 left-0 right-0 z-50 bg-white/90 backdrop-blur-xl border-t border-slate-200 p-4 sm:px-8 py-5 flex flex-col sm:flex-row justify-between items-center shadow-[0_-10px_40px_-15px_rgba(0,0,0,0.1)]">
        <div className="flex items-center gap-3 mb-4 sm:mb-0 w-full sm:w-auto">
           <div className={`flex items-center justify-center h-10 px-4 rounded-xl font-bold text-sm ${hasComments ? 'bg-amber-100 text-amber-800 border border-amber-200' : 'bg-slate-100 text-slate-500 border border-slate-200'}`}>
              <MessageSquare className="size-4 mr-2" />
              {hasComments ? `${Object.values(comments).filter(v => (v as string).trim()).length} Poin Catatan Revisi Aktif` : 'Belum Ada Instruksi Revisi'}
           </div>
        </div>
        <div className="flex gap-3 w-full sm:w-auto">
          <Button variant="outline" className="h-12 px-6 rounded-xl font-bold bg-white w-full sm:w-auto" onClick={() => navigate(-1)}>Batalkan</Button>
          <Button className="bg-amber-500 hover:bg-amber-600 h-12 px-8 rounded-xl font-bold text-white shadow-xl shadow-amber-500/20 active:scale-95 transition-all w-full sm:w-auto text-[14.5px]" disabled={!hasComments || isSaving} onClick={handleSubmitRevision}>
            {isSaving ? <Loader2 className="animate-spin size-4.5 mr-2" /> : <Send className="size-4.5 mr-2.5" />}
            Konfirmasi & Kirim Instruksi Revisi
          </Button>
        </div>
      </div>
    </div>
  );
}
