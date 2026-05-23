import { MonitoringPage } from '@/components/MonitoringPage';
import { apiListKegiatan } from '@/lib/api';
import { useState, useEffect } from 'react';

export function WadirMonitoringPage() {
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
  return <MonitoringPage items={items} isLoading={isLoading} title="Monitoring Wadir" />;
}
