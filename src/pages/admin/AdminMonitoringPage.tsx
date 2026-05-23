import { MonitoringPage } from '@/components/MonitoringPage';
import { apiListKegiatan, apiUpdateKegiatan } from '@/lib/api';
import { useState, useEffect } from 'react';

export function AdminMonitoringPage() {
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

  const handleIntervene = async (id: string, newStatus: string) => {
    try {
      await apiUpdateKegiatan(id, { status: newStatus });
      setItems(prev => prev.map(item => item.id === id ? { ...item, status: newStatus, $updatedAt: new Date().toISOString() } : item));
      alert(`Status berhasil diubah menjadi ${newStatus}`);
    } catch (e: any) {
      alert(`Gagal merubah status: ${e.message}`);
    }
  };

  return <MonitoringPage items={items} isLoading={isLoading} title="Monitoring & Intervensi (Admin)" onIntervene={handleIntervene} />;
}
