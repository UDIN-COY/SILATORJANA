import { MonitoringPage } from '@/components/MonitoringPage';
import { apiListKegiatan } from '@/lib/api';
import { useState, useEffect } from 'react';

export function RektoratMonitoringPage() {
  const [items, setItems] = useState<any[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  useEffect(() => {
    (async () => {
      try {
        const res = await apiListKegiatan({ monitoring: 'true' });
        setItems((res.data || res));
      } catch (e) { console.error(e); } finally { setIsLoading(false); }
    })();
  }, []);
  return <MonitoringPage items={items} isLoading={isLoading} title="Monitoring Kegiatan Seluruh Politeknik" />;
}
