import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/card';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Button } from '@/components/ui/button';
import { StatusBadge } from '@/components/StatusBadge';
import { ProgressTracker } from '@/components/ProgressTracker';
import { formatDate, formatCurrency, getUserId, fetchKegiatan } from '@/lib/helpers';
import { ArrowLeft, FileText, Clock, MapPin, User, Loader2, Printer, CheckCircle } from 'lucide-react';
import { useNavigate, useParams } from 'react-router-dom';
import { useState, useEffect } from 'react';
import { databases, APPWRITE_DB_ID } from '@/lib/appwrite';
import { Query } from 'appwrite';

export function DetailUsulanPage() {
  const { id } = useParams();
  const navigate = useNavigate();
  const [kegiatan, setKegiatan] = useState<any>(null);
  const [kak, setKak] = useState<any>(null);
  const [ikuList, setIkuList] = useState<any[]>([]);
  const [rabList, setRabList] = useState<any[]>([]);
  const [history, setHistory] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    if (!id) return;
    const load = async () => {
      try {
        const kg = await databases.getDocument(APPWRITE_DB_ID, 'kegiatan', id);
        setKegiatan(kg);

        try {
          const kakRes = await databases.listDocuments(APPWRITE_DB_ID, 'kak', [Query.equal('kegiatan_id', id)]);
          setKak(kakRes.documents[0] || null);
        } catch {}

        try {
          const ikuRes = await databases.listDocuments(APPWRITE_DB_ID, 'iku', [Query.equal('kegiatan_id', id)]);
          setIkuList(ikuRes.documents);
        } catch {}

        try {
          const rabRes = await databases.listDocuments(APPWRITE_DB_ID, 'rab', [Query.equal('kegiatan_id', id)]);
          setRabList(rabRes.documents);
        } catch {}

        try {
          const histRes = await databases.listDocuments(APPWRITE_DB_ID, 'status_history', [
            Query.equal('ref_id', id), Query.orderDesc('$createdAt')
          ]);
          setHistory(histRes.documents);
        } catch {}
      } catch (err) {
        console.error(err);
      } finally {
        setIsLoading(false);
      }
    };
    load();
  }, [id]);

  if (isLoading) return <div className="py-12 flex justify-center"><Loader2 className="animate-spin text-blue-600 size-8" /></div>;
  if (!kegiatan) return <div className="py-12 text-center text-slate-500">Data kegiatan tidak ditemukan.</div>;

  const totalRab = rabList.reduce((sum, r) => sum + (r.total || r.harga_satuan * (r.qty1 || r.volume || 1)), 0);

  return (
    <div className="space-y-8 max-w-5xl mx-auto pb-12 animate-in fade-in slide-in-from-bottom-4 duration-500">
      <div className="flex flex-col md:flex-row md:items-center gap-4 py-2 border-b border-slate-100 pb-6 mb-4">
        <Button variant="outline" size="icon" onClick={() => navigate(-1)} className="shrink-0 h-10 w-10 border-slate-200 text-slate-600 hover:bg-slate-100/50 hover:text-slate-900 shadow-sm"><ArrowLeft className="size-5" /></Button>
        <div className="flex-1">
          <h2 className="text-3xl font-bold text-slate-900 tracking-tight">{kegiatan.nama_kegiatan}</h2>
          <div className="flex items-center gap-3 mt-2">
            <StatusBadge status={kegiatan.status} />
            <span className="text-sm font-medium text-slate-500 flex items-center gap-1.5"><Clock className="size-3.5"/> {formatDate(kegiatan.$createdAt)}</span>
          </div>
        </div>
        <Button className="bg-slate-800 hover:bg-slate-900 text-white shadow-md w-full md:w-auto h-11 px-6 rounded-xl transition-all" onClick={() => navigate(`/dashboard/pengusul/print/${id}`)}>
          <Printer className="size-4 mr-2" /> Cetak PDF Dokumen
        </Button>
      </div>

      {/* Progress */}
      <Card className="shadow-sm border-slate-200/60 bg-white">
        <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-4"><CardTitle className="text-base text-slate-800">Alur Persetujuan Dokumen</CardTitle></CardHeader>
        <CardContent className="p-8"><ProgressTracker status={kegiatan.status} /></CardContent>
      </Card>

      {/* Info Kegiatan */}
      <Card className="shadow-sm border-slate-200/60 bg-white">
        <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-4"><CardTitle className="text-base text-slate-800">Detail Informasi Umum</CardTitle></CardHeader>
        <CardContent className="p-8 grid grid-cols-1 md:grid-cols-2 gap-8">
          <div className="space-y-6">
            <InfoRow icon={FileText} label="Jenis Kegiatan" value={kegiatan.jenis_kegiatan || kegiatan.kategori || '-'} />
            <InfoRow icon={User} label="Organisasi Pengusul" value={kegiatan.pengusul_organisasi || '-'} />
          </div>
          <div className="space-y-6">
            <InfoRow icon={Clock} label="Tanggal Pelaksanaan" value={formatDate(kegiatan.tanggal_kegiatan || kegiatan.tgl_kegiatan)} />
            <InfoRow icon={MapPin} label="Lokasi Pelaksanaan" value={kegiatan.tempat || '-'} />
          </div>
          {kegiatan.deskripsi && <div className="md:col-span-2 pt-4 border-t border-slate-100"><p className="text-sm font-semibold text-slate-600 mb-2 uppercase tracking-widest">Deskripsi / Latar Belakang</p><p className="text-sm leading-relaxed text-slate-700 bg-slate-50/50 p-4 rounded-xl border border-slate-100/50">{kegiatan.deskripsi || kegiatan.latar_belakang}</p></div>}
        </CardContent>
      </Card>

      {/* KAK */}
      {kak && (
        <Card className="shadow-sm border-slate-200/60 bg-white">
          <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-4"><CardTitle className="text-base text-slate-800">Kerangka Acuan Kerja (KAK)</CardTitle></CardHeader>
          <CardContent className="p-8 space-y-6">
            {kak.gambaran_umum && <div><p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-1.5 flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Gambaran Umum</p><p className="text-[15px] leading-relaxed text-slate-700 pl-3 border-l-[3px] border-emerald-100">{kak.gambaran_umum}</p></div>}
            {kak.tujuan && <div><p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-1.5 flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Tujuan</p><p className="text-[15px] leading-relaxed text-slate-700 pl-3 border-l-[3px] border-emerald-100">{kak.tujuan}</p></div>}
            {kak.sasaran && <div><p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-1.5 flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Sasaran</p><p className="text-[15px] leading-relaxed text-slate-700 pl-3 border-l-[3px] border-emerald-100">{kak.sasaran}</p></div>}
            {kak.penerima_manfaat && <div><p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-1.5 flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Penerima Manfaat</p><p className="text-[15px] leading-relaxed text-slate-700 pl-3 border-l-[3px] border-emerald-100">{kak.penerima_manfaat}</p></div>}
            {kak.strategi_pencapaian && <div><p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-1.5 flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Strategi Pencapaian</p><p className="text-[15px] leading-relaxed text-slate-700 pl-3 border-l-[3px] border-emerald-100">{kak.strategi_pencapaian}</p></div>}
            {kak.metode_pelaksanaan && <div><p className="text-xs font-bold text-emerald-700 uppercase tracking-widest mb-1.5 flex items-center gap-2"><span className="w-1.5 h-1.5 rounded-full bg-emerald-500"></span>Metode Pelaksanaan</p><p className="text-[15px] leading-relaxed text-slate-700 pl-3 border-l-[3px] border-emerald-100">{kak.metode_pelaksanaan}</p></div>}
          </CardContent>
        </Card>
      )}

      {/* IKU */}
      {ikuList.length > 0 && (
        <Card className="shadow-sm border-slate-200/60 bg-white">
          <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-4"><CardTitle className="text-base text-slate-800">Indikator Kinerja Utama (IKU)</CardTitle></CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <Table>
                <TableHeader><TableRow className="bg-slate-50/50"><TableHead className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 whitespace-nowrap">Nama Indikator</TableHead><TableHead className="px-6 py-4 w-32 text-right text-xs font-bold uppercase tracking-wider text-slate-500 whitespace-nowrap">Target (%)</TableHead></TableRow></TableHeader>
                <TableBody>
                  {ikuList.map(iku => (
                    <TableRow key={iku.$id} className="hover:bg-slate-50/50 transition-colors border-b-slate-100/60"><TableCell className="px-6 py-4 font-medium text-slate-700 min-w-[200px]">{iku.nama_iku}</TableCell><TableCell className="px-6 py-4 text-right whitespace-nowrap font-semibold text-emerald-600 bg-emerald-50/30">{iku.target_persen ?? '-'}%</TableCell></TableRow>
                  ))}
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      )}

      {/* RAB */}
      {rabList.length > 0 && (
        <Card className="shadow-sm border-slate-200/60 bg-white">
          <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-4"><CardTitle className="text-base text-slate-800">Rincian Anggaran Biaya (RAB)</CardTitle></CardHeader>
          <CardContent className="p-0">
            <div className="overflow-x-auto">
              <Table>
                <TableHeader>
                  <TableRow className="bg-slate-50/50 border-b-slate-100/60">
                    <TableHead className="px-6 py-4 text-xs font-bold uppercase tracking-wider text-slate-500 whitespace-nowrap">Keterangan / Uraian</TableHead>
                    <TableHead className="px-6 py-4 text-center w-20 text-xs font-bold uppercase tracking-wider text-slate-500 whitespace-nowrap">Volume</TableHead>
                    <TableHead className="px-6 py-4 text-right w-40 text-xs font-bold uppercase tracking-wider text-slate-500 whitespace-nowrap">Harga Satuan</TableHead>
                    <TableHead className="px-6 py-4 text-right w-40 text-xs font-bold uppercase tracking-wider text-slate-500 whitespace-nowrap">Total Harga</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {rabList.map(rab => {
                    const total = rab.total || (rab.harga_satuan * (rab.qty1 || rab.volume || 1));
                    return (
                      <TableRow key={rab.$id} className="hover:bg-slate-50/50 transition-colors border-b-slate-100/60">
                        <TableCell className="px-6 py-4 font-medium text-slate-700 min-w-[200px]">{rab.uraian}</TableCell>
                        <TableCell className="px-6 py-4 text-center whitespace-nowrap font-medium text-slate-600">{rab.qty1 || rab.volume || 1}</TableCell>
                        <TableCell className="px-6 py-4 text-right whitespace-nowrap text-slate-600">{formatCurrency(rab.harga_satuan)}</TableCell>
                        <TableCell className="px-6 py-4 text-right font-semibold text-slate-800 whitespace-nowrap">{formatCurrency(total)}</TableCell>
                      </TableRow>
                    );
                  })}
                  <TableRow className="bg-emerald-50/80">
                    <TableCell colSpan={3} className="px-6 py-5 text-right whitespace-nowrap text-sm font-bold text-emerald-900 uppercase tracking-widest">Total Keseluruhan Anggaran</TableCell>
                    <TableCell className="px-6 py-5 text-right font-bold text-emerald-700 text-lg whitespace-nowrap">{formatCurrency(totalRab)}</TableCell>
                  </TableRow>
                </TableBody>
              </Table>
            </div>
          </CardContent>
        </Card>
      )}

      {/* History */}
      {history.length > 0 && (
        <Card className="shadow-sm border-slate-200/60 bg-white">
          <CardHeader className="bg-slate-50/30 border-b border-slate-100/60 py-4"><CardTitle className="text-base text-slate-800">Riwayat Perubahan Status</CardTitle></CardHeader>
          <CardContent className="p-0">
            <div className="divide-y divide-slate-100/80">
              {history.map(h => (
                <div key={h.$id} className="p-5 flex items-start gap-4 hover:bg-slate-50/50 transition-colors">
                  <div className="size-2.5 rounded-full bg-emerald-500 mt-2 shrink-0 shadow-sm shadow-emerald-500/20" />
                  <div>
                    <div className="flex items-center gap-3">
                      <StatusBadge status={h.status_baru || h.new_status} />
                      <span className="text-xs font-medium text-slate-400 bg-slate-100 px-2.5 py-1 rounded-md">{formatDate(h.$createdAt || h.timestamp)}</span>
                    </div>
                    {h.catatan && <p className="text-[14px] leading-relaxed text-slate-600 mt-2 bg-white px-3 py-2 border border-slate-100 rounded-lg shadow-sm w-fit max-w-full">"{h.catatan}"</p>}
                  </div>
                </div>
              ))}
            </div>
          </CardContent>
        </Card>
      )}

      {/* Aksi submit ulang untuk Pengusul setelah diverifikasi */}
      {kegiatan.status === 'diverifikasi' && (
        <Card className="shadow-lg border-emerald-200/60 bg-gradient-to-br from-emerald-50 relative overflow-hidden to-white">
          <div className="absolute top-0 left-0 w-1 h-full bg-emerald-500"></div>
          <CardHeader className="md:flex md:items-center md:justify-between py-6 px-8">
            <div className="mb-4 md:mb-0 space-y-1.5">
              <CardTitle className="text-lg text-emerald-900 flex items-center gap-2">
                 <CheckCircle className="size-5 text-emerald-600" /> Usulan Telah Berhasil Diverifikasi
              </CardTitle>
              <p className="text-sm font-medium text-emerald-700/80 max-w-xl">Dokumen usulan ini telah lulus verifikasi tingkat pertama dan siap untuk diproses ke level Pejabat Pembuat Komitmen (PPK). Silakan tekan tombol di samping untuk meneruskan.</p>
            </div>
            <Button
              className="w-full md:w-auto bg-[#047857] hover:bg-[#065F46] text-white shadow-lg shadow-emerald-700/20 px-8 py-5 rounded-xl transition-all font-semibold h-12 border-none cursor-pointer"
              onClick={async () => {
                try {
                  await databases.updateDocument(APPWRITE_DB_ID, 'kegiatan', kegiatan.$id, { status: 'pending_ppk' });
                  alert('Berhasil diteruskan ke PPK');
                  window.location.reload();
                } catch (e: any) {
                  alert('Gagal: ' + e.message);
                }
              }}
            >
              Teruskan ke PPK
            </Button>
          </CardHeader>
        </Card>
      )}
    </div>
  );
}

function InfoRow({ icon: Icon, label, value }: { icon: any; label: string; value: string }) {
  return (
    <div className="flex items-start gap-3 bg-slate-50/50 p-4 rounded-xl border border-slate-100/60">
      <div className="p-2.5 rounded-lg bg-white shadow-sm border border-slate-100"><Icon className="size-4.5 text-emerald-600" /></div>
      <div><p className="text-[11px] uppercase tracking-widest font-bold text-slate-400 mb-0.5">{label}</p><p className="text-[15px] font-semibold text-slate-800">{value}</p></div>
    </div>
  );
}
