// Same behaviour as the portfolio (rigascg.com): plain links, page fades via
// CSS view transitions, with a script fallback for browsers without them.

(function () {
  const scroller = document.querySelector('.simplebar-content-wrapper');
  const mark = document.querySelector('.mark');
  const root = document.documentElement;
  const key = 'scroll:' + location.pathname;

  // The page scrolls inside SimpleBar's container, not the window, so the
  // browser can't remember the position by itself: save it and restore it
  // on Back/Forward and reload.
  addEventListener('pagehide', () => {
    try { sessionStorage.setItem(key, String(scroller.scrollTop)); } catch (e) {}
  });
  const nav = performance.getEntriesByType('navigation')[0];
  if (nav && (nav.type === 'back_forward' || nav.type === 'reload')) {
    let y = 0;
    try { y = Number(sessionStorage.getItem(key)) || 0; } catch (e) {}
    if (y > 0) {
      scroller.scrollTop = y;
      if (scroller.scrollTop < y) addEventListener('load', () => { scroller.scrollTop = y; }, { once: true });
    }
  }

  // The title mark stays still during a page transition, unless it has been
  // scrolled out of view (then it fades with the page instead of sliding).
  const releaseMarkIfScrolled = () => {
    if (scroller.scrollTop > mark.offsetHeight) mark.style.viewTransitionName = 'none';
  };
  addEventListener('pageswap', releaseMarkIfScrolled);
  addEventListener('pagereveal', releaseMarkIfScrolled);

  // Fallback fade: only plain left clicks on same-site links. Middle/ctrl/
  // shift clicks and links opening elsewhere are left alone.
  if (root.classList.contains('js-fade')) {
    document.addEventListener('click', (e) => {
      if (e.defaultPrevented || e.button !== 0 || e.ctrlKey || e.metaKey || e.shiftKey || e.altKey) return;
      const link = e.target.closest('a[href]');
      if (!link || (link.target && link.target !== '_self') || link.hasAttribute('download')) return;
      const url = new URL(link.href, location.href);
      if (url.origin !== location.origin || url.pathname.startsWith('/admin')) return;
      if (url.pathname === location.pathname && url.search === location.search) return;
      if (!/\/$|\.html?$/.test(url.pathname)) return; // files (PDFs etc.) open normally
      e.preventDefault();
      root.classList.add('js-fading-out');
      setTimeout(() => { location.href = url.href; }, 300);
    });
    addEventListener('pageshow', (e) => { if (e.persisted) root.classList.remove('js-fading-out'); });
  }

  // External links open in a new tab.
  document.querySelectorAll('main a[href^="http"]').forEach((a) => {
    if (new URL(a.href).origin !== location.origin) { a.target = '_blank'; a.rel = 'noopener'; }
  });
})();
