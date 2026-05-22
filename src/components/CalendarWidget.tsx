import React, { useState } from 'react';
import { Calendar as CalendarIcon, ChevronDown, ChevronLeft, ChevronRight } from 'lucide-react';

export function CalendarWidget() {
  const [isOpen, setIsOpen] = useState(false);
  const [viewDate, setViewDate] = useState(new Date());
  
  const today = new Date();

  const daysInMonth = new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 0).getDate();
  const firstDayOfMonth = new Date(viewDate.getFullYear(), viewDate.getMonth(), 1).getDay();

  const handlePrevMonth = () => {
    setViewDate(new Date(viewDate.getFullYear(), viewDate.getMonth() - 1, 1));
  };

  const handleNextMonth = () => {
    setViewDate(new Date(viewDate.getFullYear(), viewDate.getMonth() + 1, 1));
  };

  const months = ["Januari", "Februari", "Maret", "April", "Mei", "Juni", "Juli", "Agustus", "September", "Oktober", "November", "Desember"];
  const days = ["Min", "Sen", "Sel", "Rab", "Kam", "Jum", "Sab"];

  return (
    <div className="relative">
      <button 
        className="flex items-center gap-2 p-2 sm:px-3 rounded-xl border border-slate-200/60 bg-white hover:bg-slate-50 transition-colors shadow-sm text-slate-700"
        onClick={() => {
          if (!isOpen) setViewDate(new Date());
          setIsOpen(!isOpen);
        }}
      >
        <CalendarIcon className="size-[18px] sm:size-4 text-emerald-600" />
        <span className="text-[13px] font-medium hidden sm:block">
          {today.getDate()} {months[today.getMonth()]} {today.getFullYear()}
        </span>
        <ChevronDown className="size-4 text-slate-400 hidden sm:block" />
      </button>

      {isOpen && (
        <>
          <div className="fixed inset-0 z-40" onClick={() => { setViewDate(new Date()); setIsOpen(false); }} />
          <div className="fixed inset-x-4 top-[72px] sm:absolute sm:inset-auto sm:right-0 sm:top-full mt-2 w-auto sm:w-72 rounded-2xl bg-white z-50 shadow-xl border border-slate-200/60 p-4 animate-in fade-in slide-in-from-top-2 duration-200">
            <div className="flex items-center justify-between mb-4">
              <button onClick={handlePrevMonth} className="p-1 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-slate-800 transition-colors">
                <ChevronLeft className="size-5" />
              </button>
              <h3 className="font-bold text-slate-800 text-[14px]">
                {months[viewDate.getMonth()]} {viewDate.getFullYear()}
              </h3>
              <button onClick={handleNextMonth} className="p-1 hover:bg-slate-100 rounded-lg text-slate-500 hover:text-slate-800 transition-colors">
                <ChevronRight className="size-5" />
              </button>
            </div>
            
            <div className="grid grid-cols-7 gap-1 text-center mb-2">
              {days.map(day => (
                <div key={day} className="text-[11px] font-bold text-slate-400 uppercase">{day}</div>
              ))}
            </div>
            
            <div className="grid grid-cols-7 gap-1 text-center">
              {Array.from({ length: firstDayOfMonth }).map((_, idx) => (
                <div key={`empty-${idx}`} className="size-8" />
              ))}
              {Array.from({ length: daysInMonth }).map((_, idx) => {
                const day = idx + 1;
                const isToday = day === today.getDate() && 
                               viewDate.getMonth() === today.getMonth() && 
                               viewDate.getFullYear() === today.getFullYear();
                
                return (
                  <div 
                    key={day} 
                    className={`size-8 mx-auto flex items-center justify-center rounded-lg text-[13px] cursor-default
                      ${isToday ? 'bg-[#047857] text-white font-bold shadow-md' : 'text-slate-700 hover:bg-slate-100'}`}
                  >
                    {day}
                  </div>
                );
              })}
            </div>
          </div>
        </>
      )}
    </div>
  );
}
