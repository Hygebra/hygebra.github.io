/**
 * 侧边栏控制脚本
 * 功能：
 * 1. 菜单按钮切换侧边栏显示/隐藏
 * 2. 拖拽分隔线调节侧边栏宽度
 * 3. 保存用户偏好设置到 LocalStorage
 * 4. 处理可折叠菜单
 */

(function() {
  'use strict';

  // 配置
  const CONFIG = {
    MIN_WIDTH: 150,
    MAX_WIDTH: 400,
    DEFAULT_WIDTH: 200,
    STORAGE_KEY: 'sidebarWidth',
    BREAKPOINT_MOBILE: 768
  };

  // DOM 元素
  let sidebar = null;
  let menuBtn = null;
  let resizer = null;
  let main = null;

  // 状态
  let isResizing = false;
  let isHidden = false;
  let currentWidth = CONFIG.DEFAULT_WIDTH;

  /**
   * 初始化脚本
   */
  function init() {
    // 获取 DOM 元素
    sidebar = document.querySelector('.sidebar');
    menuBtn = document.getElementById('menu-toggle');
    main = document.querySelector('.main');

    if (!sidebar) return; // 如果没有侧边栏，不执行

    // 创建分隔线元素（仅在非手机版本）
    if (window.innerWidth > CONFIG.BREAKPOINT_MOBILE) {
      createResizer();
    }

    // 从 LocalStorage 恢复宽度设置
    restoreWidth();

    // 绑定事件
    if (menuBtn) {
      menuBtn.addEventListener('click', toggleSidebar);
    }

    // 绑定菜单折叠事件
    initializeMenuToggles();

    // 响应窗口大小变化
    window.addEventListener('resize', handleResize);

    // 初始化完成
    updateLayout();
  }

  /**
   * 初始化菜单折叠按钮
   */
  function initializeMenuToggles() {
    restoreMenuState();

    document.addEventListener('click', function(e) {
      const item = e.target.closest('.toggle-item');
      if (!item) return;

      e.preventDefault();

      const targetId = item.getAttribute('data-toggle');
      const submenu = document.getElementById(targetId);

      if (submenu) {
        submenu.classList.toggle('expanded');

        const toggleBtn = item.querySelector('.toggle-btn');
        if (toggleBtn) {
          toggleBtn.classList.toggle('collapsed', !submenu.classList.contains('expanded'));
        }

        saveMenuState();
      }
    });

    // sidebar 可能是 fetch 后才插入的，所以延迟再高亮一次
    setTimeout(() => {
      restoreMenuState();
      highlightCurrentPage();
    }, 100);
  }

  function saveMenuState() {
    const state = {};
    document.querySelectorAll('.submenu').forEach(menu => {
      state[menu.id] = menu.classList.contains('expanded');
    });
    localStorage.setItem('sidebarMenuState', JSON.stringify(state));
  }

  function restoreMenuState() {
    const raw = localStorage.getItem('sidebarMenuState');
    if (!raw) return;

    let state = {};
    try {
      state = JSON.parse(raw);
    } catch {
      return;
    }

    document.querySelectorAll('.submenu').forEach(menu => {
      const expanded = state[menu.id];

      if (expanded === true) {
        menu.classList.add('expanded');
      } else if (expanded === false) {
        menu.classList.remove('expanded');
      }

      const toggleItem = document.querySelector(`.toggle-item[data-toggle="${menu.id}"]`);
      const toggleBtn = toggleItem ? toggleItem.querySelector('.toggle-btn') : null;

      if (toggleBtn) {
        toggleBtn.classList.toggle('collapsed', !menu.classList.contains('expanded'));
      }
    });
  }

  function highlightCurrentPage() {
    const currentPath = window.location.pathname.replace(/\/+$/, '');
    const currentFile = currentPath.split('/').pop() || 'index.html';

    document.querySelectorAll('.sidebar a').forEach(link => {
      link.classList.remove('active');

      const href = link.getAttribute('href');
      if (!href || href.startsWith('#')) return;

      const linkUrl = new URL(href, window.location.href);
      const linkPath = linkUrl.pathname.replace(/\/+$/, '');
      const linkFile = linkPath.split('/').pop() || 'index.html';

      if (linkPath === currentPath || linkFile === currentFile) {
        link.classList.add('active');

        const submenu = link.closest('ul.submenu');
        if (submenu) {
          submenu.classList.add('expanded');

          const toggleItem = document.querySelector(`.toggle-item[data-toggle="${submenu.id}"]`);
          if (toggleItem) {
            toggleItem.classList.add('active');
            const toggleBtn = toggleItem.querySelector('.toggle-btn');
            if (toggleBtn) {
              toggleBtn.classList.remove('collapsed');
            }
          }
        }
      }
    });
  }

  /**
   * 创建可拖拽的分隔线
   */
  function createResizer() {
    resizer = document.createElement('div');
    resizer.className = 'resizer';
    document.body.appendChild(resizer);

    resizer.addEventListener('mousedown', startResize);
  }

  /**
   * 开始拖拽分隔线
   */
  function startResize(e) {
    if (window.innerWidth <= CONFIG.BREAKPOINT_MOBILE) return;
    if (isHidden) return;

    isResizing = true;
    const startX = e.clientX;
    const startWidth = currentWidth;

    document.addEventListener('mousemove', onResize);
    document.addEventListener('mouseup', stopResize);

    function onResize(moveEvent) {
      if (!isResizing) return;

      const deltaX = moveEvent.clientX - startX;
      const newWidth = Math.max(
        CONFIG.MIN_WIDTH,
        Math.min(CONFIG.MAX_WIDTH, startWidth + deltaX)
      );

      setWidth(newWidth);
    }

    function stopResize() {
      isResizing = false;
      document.removeEventListener('mousemove', onResize);
      document.removeEventListener('mouseup', stopResize);

      // 保存到 LocalStorage
      localStorage.setItem(CONFIG.STORAGE_KEY, currentWidth);
    }
  }

  /**
   * 切换侧边栏显示/隐藏
   */
  function toggleSidebar() {
    isHidden = !isHidden;

    if (isHidden) {
      sidebar.classList.add('hidden');
      if (resizer) resizer.style.display = 'none';
    } else {
      sidebar.classList.remove('hidden');
      if (resizer) resizer.style.display = 'block';
    }

    updateLayout();
  }

  /**
   * 设置侧边栏宽度
   */
  function setWidth(width) {
    currentWidth = width;
    document.documentElement.style.setProperty('--sidebar-width', `${width}px`);
    updateResizerPosition();
  }

  /**
   * 更新分隔线位置
   */
  function updateResizerPosition() {
    if (resizer) {
      resizer.style.left = `${currentWidth}px`;
    }
  }

  /**
   * 更新整体布局
   */
  function updateLayout() {
    if (!isHidden) {
      setWidth(currentWidth);
    }
  }

  /**
   * 从 LocalStorage 恢复宽度设置
   */
  function restoreWidth() {
    const savedWidth = localStorage.getItem(CONFIG.STORAGE_KEY);
    if (savedWidth) {
      const width = parseInt(savedWidth, 10);
      if (width >= CONFIG.MIN_WIDTH && width <= CONFIG.MAX_WIDTH) {
        currentWidth = width;
      }
    }
    setWidth(currentWidth);
  }

  /**
   * 处理窗口大小变化
   */
  function handleResize() {
    const isMobile = window.innerWidth <= CONFIG.BREAKPOINT_MOBILE;

    if (isMobile && !resizer) {
      // 从桌面版切换到手机版，隐藏分隔线
      return;
    }

    if (!isMobile && !resizer) {
      // 从手机版切换到桌面版，创建分隔线
      createResizer();
    }

    // 在手机版时，重置侧边栏为正常位置（非隐藏状态下）
    if (isMobile && !isHidden) {
      sidebar.style.transform = 'none';
      if (menuBtn) {
        menuBtn.style.display = 'block';
      }
    }

    // 在桌面版时，恢复分隔线
    if (!isMobile && resizer) {
      if (!isHidden) {
        resizer.style.display = 'block';
      }
    }
  }

  /**
   * 页面加载完成后初始化
   */
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
})();
