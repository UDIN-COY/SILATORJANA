import { useState, useEffect } from 'react';
import { Bell, Check, Info, AlertCircle, CheckCircle } from 'lucide-react';
import { client, databases, APPWRITE_DB_ID } from '@/lib/appwrite';
import { Query } from 'appwrite';
import { getUserId, timeAgo } from '@/lib/helpers';
import { useNavigate } from 'react-router-dom';

interface NotificationDropdownProps {
  role: string;
}

interface NotificationItem {
  id: string;
  title: string;
  message: string;
  time: string;
  read: boolean;
  type: 'info' | 'success' | 'warning';
  link: string;
}

export function NotificationDropdown({ role }: NotificationDropdownProps) {
  const navigate = useNavigate();
  const [isOpen, setIsOpen] = useState(false);
  const [notifications, setNotifications] = useState<NotificationItem[]>([]);
  const [unreadCount, setUnreadCount] = useState(0);

  // Initial load
  useEffect(() => {
    loadNotifications();

    // Subscribe to realtime updates on kegiatan
    const unsubscribe = client.subscribe(
      `databases.${APPWRITE_DB_ID}.collections.kegiatan.documents`,
      (response: any) => {
        if (response.events.includes('databases.*.collections.*.documents.*.update') ||
            response.events.includes('databases.*.collections.*.documents.*.create')) {
          handleRealtimeUpdate(response.payload, response.events);
        }
      }
    );

    return () => unsubscribe();
  }, [role]);

  const loadNotifications = async () => {
    try {
      const userId = getUserId();
      let queries = [Query.orderDesc('$updatedAt'), Query.limit(10)];
      
      if (role === 'pengusul') {
        queries.push(Query.equal('pengusul_id', parseInt(userId || '0', 10)));
      } else if (role === 'verifikator') {
        queries.push(Query.equal('status', 'submitted'));
      } else if (role === 'ppk') {
        queries.push(Query.equal('status', 'verified'));
      } else if (role === 'wadir2') {
        queries.push(Query.equal('status', 'approved_ppk'));
      } else if (role === 'bendahara') {
        queries.push(Query.equal('status', 'approved_wadir'));
      }

      const res = await databases.listDocuments(APPWRITE_DB_ID, 'kegiatan', queries);
      
      const items = res.documents.map(doc => formatNotification(doc, role)).filter(Boolean) as NotificationItem[];
      setNotifications(items);
      setUnreadCount(items.filter(i => !i.read).length);
    } catch (e) {
      console.error('Failed to load notifications:', e);
    }
  };

  const handleRealtimeUpdate = (payload: any, events: string[]) => {
    const userId = getUserId();
    const isCreate = events.some(e => e.includes('.create'));
    
    // Determine if relevant based on role
    let isRelevant = false;
    
    if (role === 'pengusul' && payload.pengusul_id === parseInt(userId || '0', 10)) {
      isRelevant = true; // Any update to their proposal
    } else if (role === 'verifikator' && payload.status === 'submitted') {
      isRelevant = true;
    } else if (role === 'ppk' && payload.status === 'verified') {
      isRelevant = true;
    } else if (role === 'wadir2' && payload.status === 'approved_ppk') {
      isRelevant = true;
    } else if (role === 'bendahara' && payload.status === 'approved_wadir') {
      isRelevant = true;
    }

    if (isRelevant) {
      const newNotif = formatNotification(payload, role, true);
      if (newNotif) {
        setNotifications(prev => [newNotif, ...prev.filter(n => n.id !== newNotif.id)].slice(0, 10));
        setUnreadCount(prev => prev + 1);
      }
    }
  };

  const formatNotification = (doc: any, userRole: string, isNew = false): NotificationItem | null => {
    if (userRole === 'pengusul') {
      let msg = '';
      let type: 'info'|'success'|'warning' = 'info';
      if (doc.status === 'revision_requested') { msg = 'Memerlukan revisi'; type = 'warning'; }
      else if (doc.status === 'verified') { msg = 'Lolos verifikasi'; type = 'success'; }
      else if (doc.status === 'approved_wadir') { msg = 'Disetujui Wadir'; type = 'success'; }
      else if (doc.status === 'rejected') { msg = 'Ditolak'; type = 'warning'; }
      else { msg = `Status diperbarui: ${doc.status}`; }
      
      return {
        id: doc.$id + doc.status,
        title: doc.nama_kegiatan,
        message: msg,
        time: doc.$updatedAt,
        read: !isNew,
        type,
        link: `/dashboard/pengusul/usulan/${doc.$id}`
      };
    } else {
      // Approver roles
      return {
        id: doc.$id + doc.status,
        title: 'Usulan Baru Masuk',
        message: `${doc.nama_kegiatan} membutuhkan tinjauan Anda.`,
        time: doc.$updatedAt,
        read: !isNew,
        type: 'info',
        link: `/dashboard/${userRole}/review/${doc.$id}` // Or usulan/:id for verifikator
      };
    }
  };

  const markAllRead = () => {
    setNotifications(prev => prev.map(n => ({ ...n, read: true })));
    setUnreadCount(0);
  };

  const handleItemClick = (link: string) => {
    setIsOpen(false);
    navigate(link.replace('/review/', role === 'verifikator' ? '/usulan/' : '/review/'));
  };

  return (
    <div className="relative">
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className={`relative p-2 rounded-lg transition-colors ${isOpen ? 'bg-emerald-50' : 'hover:bg-white/50'}`}
      >
        <Bell className="size-5" style={{ color: '#2D6A4F' }} />
        {unreadCount > 0 && (
          <span className="absolute top-1.5 right-1.5 size-2 bg-red-500 rounded-full border-2 border-white animate-pulse" />
        )}
      </button>

      {isOpen && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => setIsOpen(false)} />
          <div className="absolute right-0 top-full mt-2 w-80 rounded-2xl bg-white z-50 flex flex-col py-2 animate-in fade-in slide-in-from-top-2" style={{ boxShadow: '0 10px 40px rgba(0,0,0,0.12)', border: '1px solid rgba(0,0,0,0.06)' }}>
            <div className="px-4 py-2 border-b border-slate-100 flex items-center justify-between">
              <p className="text-sm font-bold text-slate-900">Notifikasi</p>
              {unreadCount > 0 && (
                <button onClick={markAllRead} className="text-xs font-medium text-emerald-600 hover:text-emerald-700 flex items-center gap-1">
                  <Check className="size-3" /> Tandai terbaca
                </button>
              )}
            </div>
            
            <div className="max-h-80 overflow-y-auto">
              {notifications.length === 0 ? (
                <div className="px-4 py-8 text-center text-slate-500 text-sm">
                  Belum ada notifikasi
                </div>
              ) : (
                <div className="divide-y divide-slate-50">
                  {notifications.map((notif, idx) => (
                    <button 
                      key={notif.id + idx} 
                      onClick={() => handleItemClick(notif.link)}
                      className={`w-full text-left px-4 py-3 hover:bg-slate-50 transition-colors flex items-start gap-3 ${!notif.read ? 'bg-emerald-50/30' : ''}`}
                    >
                      <div className="mt-0.5 shrink-0">
                        {notif.type === 'success' ? <CheckCircle className="size-4 text-emerald-500" /> :
                         notif.type === 'warning' ? <AlertCircle className="size-4 text-amber-500" /> :
                         <Info className="size-4 text-blue-500" />}
                      </div>
                      <div className="flex-1 min-w-0">
                        <p className={`text-sm truncate ${!notif.read ? 'font-semibold text-slate-900' : 'font-medium text-slate-700'}`}>
                          {notif.title}
                        </p>
                        <p className={`text-xs mt-0.5 ${!notif.read ? 'text-slate-600' : 'text-slate-500'}`}>
                          {notif.message}
                        </p>
                        <p className="text-[10px] text-slate-400 mt-1">
                          {timeAgo(notif.time)}
                        </p>
                      </div>
                      {!notif.read && <div className="size-2 bg-emerald-500 rounded-full shrink-0 mt-1.5" />}
                    </button>
                  ))}
                </div>
              )}
            </div>
            
            <div className="px-4 py-2 border-t border-slate-100 text-center">
              <button onClick={() => { setIsOpen(false); navigate(`/dashboard/${role}`); }} className="text-xs font-medium text-slate-500 hover:text-slate-700">
                Lihat Semua
              </button>
            </div>
          </div>
        </>
      )}
    </div>
  );
}
