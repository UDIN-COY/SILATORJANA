import { useState, useEffect, useRef } from 'react';
import { createPortal } from 'react-dom';
import { Maximize2, Minimize2, X, Send, ChevronDown } from 'lucide-react';
import { cn } from '@/lib/utils';
import ReactMarkdown from 'react-markdown';
import remarkGfm from 'remark-gfm';

const JLogo = ({ className }: { className?: string }) => (
  <svg 
    className={className} 
    viewBox="0 0 24 24" 
    fill="none" 
    xmlns="http://www.w3.org/2000/svg"
  >
    <path 
      d="M16 4H12.5C9.46243 4 7 6.46243 7 9.5V10.5C7 11.3284 7.67157 12 8.5 12C9.32843 12 10 11.3284 10 10.5V9.5C10 8.11929 11.1193 7 12.5 7H13V16.5C13 18.433 11.433 20 9.5 20C7.567 20 6 18.433 6 16.5V15.5" 
      stroke="currentColor" 
      strokeWidth="2.5" 
      strokeLinecap="round" 
    />
    <circle cx="18" cy="4" r="2.5" fill="#34D399" />
    <circle cx="18" cy="4" r="2.5" fill="currentColor" fillOpacity="0.2" />
  </svg>
);

export function JanaAssistant({ className }: { className?: string }) {
  const [isOpen, setIsOpen] = useState(false);
  const [isFullscreen, setIsFullscreen] = useState(false);
  const [message, setMessage] = useState('');
  const [mounted, setMounted] = useState(false);
  const [isTyping, setIsTyping] = useState(false);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  
  const [chatHistory, setChatHistory] = useState([
    {
      role: 'assistant',
      content: 'Halo! Saya **Jana**, asisten AI Anda. Ada yang bisa saya bantu dengan sistem ini?',
    }
  ]);

  useEffect(() => {
    setMounted(true);
  }, []);

  useEffect(() => {
    if (isOpen) {
      messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [chatHistory, isOpen]);

  const handleSend = async () => {
    if (!message.trim()) return;
    
    const userMessage = message;
    setChatHistory(prev => [...prev, { role: 'user', content: userMessage }]);
    setMessage('');
    setIsTyping(true);
    
    try {
      const response = await fetch('/api/chat', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ message: userMessage })
      });
      
      if (!response.ok) {
        const errorData = await response.json().catch(() => ({}));
        throw new Error(errorData.error || 'Gagal menghubungi Jana');
      }
      
      const data = await response.json();
      setChatHistory(prev => [...prev, { role: 'assistant', content: data.reply || 'Maaf, saya tidak mengerti.' }]);
    } catch (error: any) {
      setChatHistory(prev => [...prev, { role: 'assistant', content: `Pesan Sistem: ${error.message || 'Maaf, terjadi kesalahan saat menghubungi server.'}` }]);
    } finally {
      setIsTyping(false);
    }
  };

  const chatUI = isOpen && mounted ? createPortal(
    <div className={styles(isFullscreen)}>
      {/* Header */}
      <div className="p-4 border-b border-white/10 bg-gradient-to-r from-emerald-800 to-teal-800 text-white flex items-center justify-between shrink-0">
        <div className="flex items-center gap-3">
          <div className="w-10 h-10 bg-white/10 backdrop-blur-md rounded-full flex items-center justify-center border border-white/20 shadow-inner">
            <JLogo className="text-emerald-50 size-6" />
          </div>
          <div>
            <h3 className="font-semibold text-[15px] tracking-tight text-white/95 leading-tight">Asisten Jana</h3>
            <div className="flex items-center gap-1.5 mt-0.5">
              <span className="relative flex h-2 w-2">
                <span className="animate-ping absolute inline-flex h-full w-full rounded-full bg-emerald-400 opacity-75"></span>
                <span className="relative inline-flex rounded-full h-2 w-2 bg-emerald-400"></span>
              </span>
              <p className="text-[11px] font-medium text-emerald-200 uppercase tracking-widest">Online</p>
            </div>
          </div>
        </div>
        <div className="flex items-center gap-1.5">
          <button 
            onClick={() => setIsFullscreen(!isFullscreen)}
            className="p-2 hover:bg-white/10 rounded-xl transition-colors text-emerald-100 hover:text-white group"
            title={isFullscreen ? "Kembali Melayang" : "Layar Penuh"}
          >
            {isFullscreen ? <Minimize2 className="size-[18px] group-active:scale-95 transition-transform" /> : <Maximize2 className="size-[18px] group-active:scale-95 transition-transform" />}
          </button>
          <button 
            onClick={() => setIsOpen(false)}
            className="p-2 hover:bg-red-500/80 rounded-xl transition-colors text-emerald-100 hover:text-white group"
            title="Tutup Asisten"
          >
            <X className="size-[18px] group-active:scale-95 transition-transform" />
          </button>
        </div>
      </div>
      
      {/* Chat Area */}
      <div className="flex-1 bg-slate-50/80 backdrop-blur-sm p-4 sm:p-5 overflow-y-auto w-full relative">
        <div className="flex flex-col gap-5 max-w-4xl mx-auto">
          {chatHistory.map((chat, idx) => (
            <div key={idx} className={chat.role === 'user' ? "flex justify-end pl-10" : "flex justify-start pr-10"}>
               <div 
                 className={cn(
                   "p-4 rounded-2xl text-[14.5px] shadow-sm leading-relaxed", 
                   chat.role === 'user' 
                    ? "bg-emerald-600 text-white rounded-br-sm shadow-emerald-500/20" 
                    : "bg-white border border-slate-200/80 text-slate-700 rounded-bl-sm [&_ul]:list-disc [&_ul]:pl-5 [&_ol]:list-decimal [&_ol]:pl-5 [&_code]:bg-slate-100 [&_code]:px-1.5 [&_code]:py-0.5 [&_code]:rounded [&_code]:text-emerald-700 [&_pre]:bg-slate-800 [&_pre]:text-slate-100 [&_pre_code]:bg-transparent [&_pre_code]:text-inherit [&_pre_code]:p-0 [&_pre]:p-4 [&_pre]:rounded-lg [&_pre]:my-2 [&_pre]:overflow-x-auto [&_p]:mb-2 [&_p]:last:mb-0"
                 )}
               >
                 <ReactMarkdown remarkPlugins={[remarkGfm]}>
                   {chat.content}
                 </ReactMarkdown>
               </div>
            </div>
          ))}
          {isTyping && (
            <div className="flex justify-start pr-10">
               <div className="p-4 rounded-2xl bg-white border border-slate-200/80 text-slate-700 rounded-bl-sm shadow-sm flex gap-1.5 items-center">
                 <div className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce [animation-delay:-0.3s]"></div>
                 <div className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce [animation-delay:-0.15s]"></div>
                 <div className="w-1.5 h-1.5 bg-slate-400 rounded-full animate-bounce"></div>
               </div>
            </div>
          )}
          <div ref={messagesEndRef} className="h-2" />
        </div>
      </div>

      {/* Input Area */}
      <div className="p-4 bg-white border-t border-slate-200/80 shrink-0">
        <div className="max-w-4xl mx-auto flex items-center gap-2 bg-slate-50 border border-slate-200 hover:border-emerald-300 rounded-2xl p-1.5 focus-within:!border-emerald-500 focus-within:bg-white focus-within:ring-4 focus-within:ring-emerald-500/10 transition-all shadow-sm">
          <input 
            type="text" 
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            onKeyDown={(e) => e.key === 'Enter' && handleSend()}
            placeholder="Tanya sesuatu ke Jana..." 
            className="flex-1 bg-transparent border-none focus:outline-none text-[14.5px] py-2.5 px-3 placeholder:text-slate-400 font-medium text-slate-700"
          />
          <button 
            onClick={handleSend}
            disabled={!message.trim()}
            className="p-3 bg-emerald-600 hover:bg-emerald-700 text-white rounded-xl transition-all shrink-0 shadow-sm shadow-emerald-700/20 active:scale-95 disabled:opacity-50 disabled:active:scale-100 disabled:cursor-not-allowed"
          >
            <Send className="size-[18px] ml-0.5" />
          </button>
        </div>
      </div>
    </div>,
    document.body
  ) : null;

  return (
    <div className={className}>
      <button 
        onClick={() => setIsOpen(!isOpen)}
        className={cn(
          "flex items-center justify-between gap-0 sm:gap-2 p-2 sm:px-3 sm:py-2 bg-white sm:bg-gradient-to-r sm:from-emerald-50 sm:to-teal-50 hover:bg-slate-50 sm:hover:from-emerald-100 sm:hover:to-teal-100 border border-slate-200/60 sm:border-emerald-200/60 text-slate-700 sm:text-emerald-800 rounded-xl transition-all shadow-sm w-auto",
          isOpen && "ring-2 ring-emerald-500/20 bg-emerald-50 sm:bg-emerald-100/50 shadow-none border-emerald-300"
        )}
      >
        <div className="flex items-center gap-2">
          <JLogo className="size-[18px] text-emerald-600" />
          <span className="text-[13px] sm:text-sm font-semibold tracking-tight hidden sm:block">Tanya Asisten Jana</span>
        </div>
        <ChevronDown className={cn("size-4 opacity-70 transition-transform hidden sm:block", isOpen && "rotate-180")} />
      </button>

      {chatUI}
    </div>
  );
}

function styles(isFullscreen: boolean) {
  return cn(
    "bg-slate-50 flex flex-col overflow-hidden transition-all duration-300 z-[9999] shadow-2xl",
    isFullscreen 
      ? "fixed inset-0 sm:inset-4 sm:rounded-[2rem] border border-slate-300/50" 
      : "fixed shrink-0 right-4 sm:right-6 top-[80px] w-[90vw] sm:w-[420px] h-[calc(100vh-100px)] max-h-[700px] border border-slate-200/80 rounded-2xl shadow-emerald-900/10 origin-top-right"
  );
}
