// 全局变量
let fontSize = 16;
let lineHeight = 1.5;
let currentTheme = 'light';
let currentLayout = 'single';

// 页面加载完成后执行
window.addEventListener('DOMContentLoaded', function() {
    // 初始化所有页面的交互功能
    initMainPage();
    initFileManager();
    initReader();
    initSettings();
    initNotes();
    
    // 初始化主题
    applyTheme(currentTheme);
});

// 初始化主页面
function initMainPage() {
    const viewButtons = document.querySelectorAll('.view-options .btn-icon');
    if (viewButtons.length > 0) {
        viewButtons.forEach(button => {
            button.addEventListener('click', function() {
                viewButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }
}

// 初始化文件管理器
function initFileManager() {
    // 视图切换
    const listViewBtn = document.getElementById('list-view-btn');
    const gridViewBtn = document.getElementById('grid-view-btn');
    const fileList = document.getElementById('file-list');
    const fileGrid = document.getElementById('file-grid');
    
    if (listViewBtn && gridViewBtn && fileList && fileGrid) {
        listViewBtn.addEventListener('click', function() {
            listViewBtn.classList.add('active');
            gridViewBtn.classList.remove('active');
            fileList.style.display = 'block';
            fileGrid.style.display = 'none';
        });
        
        gridViewBtn.addEventListener('click', function() {
            gridViewBtn.classList.add('active');
            listViewBtn.classList.remove('active');
            fileGrid.style.display = 'grid';
            fileList.style.display = 'none';
        });
    }
    
    // 批量操作
    const fileCheckboxes = document.querySelectorAll('.file-checkbox');
    const batchControls = document.getElementById('batch-controls');
    const cancelBatchBtn = document.getElementById('cancel-batch-btn');
    
    if (fileCheckboxes.length > 0 && batchControls) {
        fileCheckboxes.forEach(checkbox => {
            checkbox.addEventListener('change', function() {
                const checkedCount = document.querySelectorAll('.file-checkbox:checked').length;
                if (checkedCount > 0) {
                    batchControls.style.display = 'flex';
                } else {
                    batchControls.style.display = 'none';
                }
            });
        });
        
        if (cancelBatchBtn) {
            cancelBatchBtn.addEventListener('click', function() {
                fileCheckboxes.forEach(checkbox => {
                    checkbox.checked = false;
                });
                batchControls.style.display = 'none';
            });
        }
    }
    
    // 分类标签切换
    const categoryTabs = document.querySelectorAll('.category-tabs .tab-btn');
    if (categoryTabs.length > 0) {
        categoryTabs.forEach(tab => {
            tab.addEventListener('click', function() {
                categoryTabs.forEach(t => t.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }
    
    // 文件导入按钮
    const importBtn = document.getElementById('import-btn');
    if (importBtn) {
        importBtn.addEventListener('click', function() {
            alert('文件导入功能将在实际应用中实现');
        });
    }
}

// 初始化阅读视图
function initReader() {
    // 阅读控制菜单
    const readerContent = document.getElementById('reader-content');
    const readerControls = document.getElementById('reader-controls');
    const closeControlsBtn = document.getElementById('close-controls-btn');
    
    if (readerContent) {
        readerContent.addEventListener('click', function(e) {
            // 只有点击内容区域空白处才显示控制菜单
            if (e.target === readerContent || e.target === readerContent.querySelector('.content-wrapper')) {
                if (readerControls) {
                    readerControls.style.display = 'block';
                }
            }
        });
    }
    
    if (closeControlsBtn && readerControls) {
        closeControlsBtn.addEventListener('click', function() {
            readerControls.style.display = 'none';
        });
    }
    
    // 字体大小调整
    const decreaseFontBtn = document.getElementById('decrease-font-btn');
    const increaseFontBtn = document.getElementById('increase-font-btn');
    const fontSizeValue = document.getElementById('font-size-value');
    const contentWrapper = document.querySelector('.content-wrapper');
    
    if (decreaseFontBtn && increaseFontBtn && fontSizeValue && contentWrapper) {
        decreaseFontBtn.addEventListener('click', function() {
            if (fontSize > 12) {
                fontSize -= 2;
                fontSizeValue.textContent = fontSize + 'px';
                contentWrapper.style.fontSize = fontSize + 'px';
            }
        });
        
        increaseFontBtn.addEventListener('click', function() {
            if (fontSize < 24) {
                fontSize += 2;
                fontSizeValue.textContent = fontSize + 'px';
                contentWrapper.style.fontSize = fontSize + 'px';
            }
        });
    }
    
    // 字体类型选择
    const fontFamilySelect = document.getElementById('font-family-select');
    if (fontFamilySelect && contentWrapper) {
        fontFamilySelect.addEventListener('change', function() {
            contentWrapper.style.fontFamily = this.value;
        });
    }
    
    // 行间距设置
    const lineHeightSlider = document.getElementById('line-height-slider');
    const lineHeightValue = document.getElementById('line-height-value');
    
    if (lineHeightSlider && lineHeightValue && contentWrapper) {
        lineHeightSlider.addEventListener('input', function() {
            lineHeight = parseFloat(this.value);
            lineHeightValue.textContent = lineHeight;
            contentWrapper.style.lineHeight = lineHeight;
        });
    }
    
    // 主题切换
    const themeButtons = document.querySelectorAll('.theme-btn');
    if (themeButtons.length > 0) {
        themeButtons.forEach(button => {
            button.addEventListener('click', function() {
                const theme = this.getAttribute('data-theme');
                applyTheme(theme);
                
                themeButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }
    
    // 页面布局切换
    const layoutButtons = document.querySelectorAll('.layout-btn');
    if (layoutButtons.length > 0 && readerContent) {
        layoutButtons.forEach(button => {
            button.addEventListener('click', function() {
                const layout = this.getAttribute('data-layout');
                currentLayout = layout;
                applyLayout(layout, readerContent);
                
                layoutButtons.forEach(btn => btn.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }
    
    // 目录面板
    const tocBtn = document.getElementById('toc-btn');
    const tocPanel = document.getElementById('toc-panel');
    const closeTocBtn = document.getElementById('close-toc-btn');
    const tocItems = document.querySelectorAll('.toc-item');
    
    if (tocBtn && tocPanel) {
        tocBtn.addEventListener('click', function() {
            tocPanel.style.display = 'flex';
        });
    }
    
    if (closeTocBtn && tocPanel) {
        closeTocBtn.addEventListener('click', function() {
            tocPanel.style.display = 'none';
        });
    }
    
    if (tocItems.length > 0) {
        tocItems.forEach(item => {
            item.addEventListener('click', function() {
                tocItems.forEach(i => i.classList.remove('active'));
                this.classList.add('active');
                
                if (tocPanel) {
                    tocPanel.style.display = 'none';
                }
            });
        });
    }
    
    // 书签按钮
    const bookmarkBtn = document.getElementById('bookmark-btn');
    if (bookmarkBtn) {
        bookmarkBtn.addEventListener('click', function() {
            this.classList.toggle('active');
            if (this.classList.contains('active')) {
                alert('书签已添加');
            } else {
                alert('书签已移除');
            }
        });
    }
    
    // 笔记按钮
    const noteBtn = document.getElementById('note-btn');
    if (noteBtn) {
        noteBtn.addEventListener('click', function() {
            alert('笔记功能将在实际应用中实现');
        });
    }
}

// 初始化设置页面
function initSettings() {
    // 主题切换
    const themeOptions = document.querySelectorAll('.theme-option');
    if (themeOptions.length > 0) {
        themeOptions.forEach(option => {
            option.addEventListener('click', function() {
                const theme = this.getAttribute('data-theme');
                themeOptions.forEach(opt => opt.classList.remove('active'));
                this.classList.add('active');
                
                // 应用主题
                if (theme === 'dark') {
                    document.body.classList.add('dark-theme');
                } else {
                    document.body.classList.remove('dark-theme');
                }
            });
        });
    }
    
    // 切换开关
    const toggleSwitches = document.querySelectorAll('.toggle-switch input');
    if (toggleSwitches.length > 0) {
        toggleSwitches.forEach(toggle => {
            toggle.addEventListener('change', function() {
                console.log('Toggle changed:', this.checked);
            });
        });
    }
    
    // 设置项点击
    const settingsItems = document.querySelectorAll('.settings-item');
    if (settingsItems.length > 0) {
        settingsItems.forEach(item => {
            const infoSection = item.querySelector('.settings-info');
            if (infoSection) {
                infoSection.addEventListener('click', function(e) {
                    // 避免触发按钮点击事件
                    if (!e.target.closest('button') && !e.target.closest('select') && !e.target.closest('.toggle-switch')) {
                        const actionButton = item.querySelector('.btn-icon');
                        if (actionButton) {
                            // 模拟点击操作按钮
                            console.log('Settings item clicked');
                        }
                    }
                });
            }
        });
    }
}

// 初始化笔记与书签管理
function initNotes() {
    // 标签页切换
    const tabBtns = document.querySelectorAll('.tab-container .tab-btn');
    const tabContents = document.querySelectorAll('.tab-content');
    
    if (tabBtns.length > 0 && tabContents.length > 0) {
        tabBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const tabId = this.getAttribute('data-tab');
                
                // 更新标签按钮状态
                tabBtns.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
                
                // 更新标签内容
                tabContents.forEach(content => {
                    content.style.display = 'none';
                    content.classList.remove('active');
                });
                
                const activeContent = document.getElementById(tabId + '-tab');
                if (activeContent) {
                    activeContent.style.display = 'block';
                    activeContent.classList.add('active');
                }
            });
        });
    }
    
    // 分类按钮
    const categoryBtns = document.querySelectorAll('.category-btn');
    if (categoryBtns.length > 0) {
        categoryBtns.forEach(btn => {
            btn.addEventListener('click', function() {
                const parent = this.parentElement;
                const siblings = parent.querySelectorAll('.category-btn');
                siblings.forEach(b => b.classList.remove('active'));
                this.classList.add('active');
            });
        });
    }
    
    // 导出按钮
    const exportBtn = document.getElementById('export-btn');
    if (exportBtn) {
        exportBtn.addEventListener('click', function() {
            alert('导出功能将在实际应用中实现');
        });
    }
    
    // 笔记和书签操作按钮
    const actionButtons = document.querySelectorAll('.note-actions .btn-icon, .bookmark-actions .btn-icon');
    if (actionButtons.length > 0) {
        actionButtons.forEach(button => {
            button.addEventListener('click', function() {
                const action = this.querySelector('i').classList.contains('fa-edit') ? '编辑' : '删除';
                alert(action + '功能将在实际应用中实现');
            });
        });
    }
}

// 应用主题
function applyTheme(theme) {
    const body = document.body;
    
    // 移除所有主题类
    body.classList.remove('dark-theme', 'night-theme');
    
    // 应用新主题
    if (theme === 'dark') {
        body.classList.add('dark-theme');
        currentTheme = 'dark';
    } else if (theme === 'night') {
        body.classList.add('night-theme');
        currentTheme = 'night';
    } else {
        currentTheme = 'light';
    }
}

// 应用页面布局
function applyLayout(layout, readerContent) {
    if (!readerContent) return;
    
    // 移除所有布局类
    readerContent.classList.remove('single-layout', 'double-layout', 'scroll-layout');
    
    // 应用新布局
    if (layout === 'double') {
        readerContent.classList.add('double-layout');
        readerContent.style.maxWidth = '1200px';
        readerContent.style.columnCount = '2';
        readerContent.style.columnGap = '40px';
    } else if (layout === 'scroll') {
        readerContent.classList.add('scroll-layout');
        readerContent.style.maxWidth = '800px';
        readerContent.style.columnCount = '1';
    } else {
        // 单页布局
        readerContent.classList.add('single-layout');
        readerContent.style.maxWidth = '800px';
        readerContent.style.columnCount = '1';
    }
}

// 辅助函数：显示提示信息
function showToast(message, duration = 2000) {
    // 创建提示元素
    const toast = document.createElement('div');
    toast.className = 'toast';
    toast.textContent = message;
    
    // 添加样式
    toast.style.position = 'fixed';
    toast.style.bottom = '80px';
    toast.style.left = '50%';
    toast.style.transform = 'translateX(-50%)';
    toast.style.padding = '12px 24px';
    toast.style.backgroundColor = 'rgba(0, 0, 0, 0.8)';
    toast.style.color = 'white';
    toast.style.borderRadius = '4px';
    toast.style.zIndex = '1000';
    toast.style.opacity = '0';
    toast.style.transition = 'opacity 0.3s ease';
    
    // 添加到页面
    document.body.appendChild(toast);
    
    // 显示提示
    setTimeout(() => {
        toast.style.opacity = '1';
    }, 100);
    
    // 隐藏提示
    setTimeout(() => {
        toast.style.opacity = '0';
        setTimeout(() => {
            document.body.removeChild(toast);
        }, 300);
    }, duration);
}

// 辅助函数：获取元素相对于文档的位置
function getElementPosition(element) {
    const rect = element.getBoundingClientRect();
    return {
        x: rect.left + window.scrollX,
        y: rect.top + window.scrollY
    };
}

// 辅助函数：平滑滚动到指定元素
function scrollToElement(element, offset = 0) {
    const position = getElementPosition(element);
    window.scrollTo({
        top: position.y - offset,
        behavior: 'smooth'
    });
}

// 模拟数据加载
function loadMockData() {
    console.log('Loading mock data...');
    // 这里可以添加模拟数据加载逻辑
}

// 处理窗口大小变化
window.addEventListener('resize', function() {
    // 响应式布局调整
    adjustLayout();
});

// 调整布局
function adjustLayout() {
    const width = window.innerWidth;
    const bottomNav = document.querySelector('.bottom-nav');
    const mainContent = document.querySelector('.main-content');
    
    if (bottomNav && mainContent) {
        if (width < 768) {
            bottomNav.style.display = 'flex';
            mainContent.style.paddingBottom = '80px';
        } else {
            bottomNav.style.display = 'none';
            mainContent.style.paddingBottom = '32px';
        }
    }
}

// 键盘快捷键
window.addEventListener('keydown', function(e) {
    // 阅读视图快捷键
    if (document.body.classList.contains('reader-mode')) {
        switch(e.key) {
            case 'Escape':
                const readerControls = document.getElementById('reader-controls');
                const tocPanel = document.getElementById('toc-panel');
                if (readerControls && readerControls.style.display === 'block') {
                    readerControls.style.display = 'none';
                }
                if (tocPanel && tocPanel.style.display === 'flex') {
                    tocPanel.style.display = 'none';
                }
                break;
            case 'ArrowLeft':
                // 上一页
                break;
            case 'ArrowRight':
                // 下一页
                break;
            case 'b':
                // 切换书签
                const bookmarkBtn = document.getElementById('bookmark-btn');
                if (bookmarkBtn) {
                    bookmarkBtn.click();
                }
                break;
            case 'n':
                // 添加笔记
                const noteBtn = document.getElementById('note-btn');
                if (noteBtn) {
                    noteBtn.click();
                }
                break;
        }
    }
});

// 触摸事件处理（移动端）
let touchStartX = 0;
let touchStartY = 0;
let touchEndX = 0;
let touchEndY = 0;

document.addEventListener('touchstart', function(e) {
    touchStartX = e.changedTouches[0].screenX;
    touchStartY = e.changedTouches[0].screenY;
}, false);

document.addEventListener('touchend', function(e) {
    touchEndX = e.changedTouches[0].screenX;
    touchEndY = e.changedTouches[0].screenY;
    handleSwipe();
}, false);

function handleSwipe() {
    const diffX = touchEndX - touchStartX;
    const diffY = touchEndY - touchStartY;
    
    // 水平滑动
    if (Math.abs(diffX) > Math.abs(diffY) && Math.abs(diffX) > 50) {
        if (diffX > 0) {
            // 向右滑动 - 上一页
            console.log('Swipe right');
        } else {
            // 向左滑动 - 下一页
            console.log('Swipe left');
        }
    }
    
    // 垂直滑动
    if (Math.abs(diffY) > Math.abs(diffX) && Math.abs(diffY) > 50) {
        if (diffY > 0) {
            // 向下滑动 - 显示顶部工具栏
            console.log('Swipe down');
        } else {
            // 向上滑动 - 显示底部工具栏
            console.log('Swipe up');
        }
    }
}

// 模拟文件操作
function mockFileOperation(operation) {
    console.log('File operation:', operation);
    showToast(operation + '操作将在实际应用中实现');
}

// 模拟云同步
function mockCloudSync() {
    console.log('Syncing data to cloud...');
    showToast('正在同步数据到云端');
    
    // 模拟同步完成
    setTimeout(() => {
        showToast('数据同步完成');
    }, 2000);
}

// 导出功能
function exportData(type) {
    console.log('Exporting data as:', type);
    showToast('正在导出数据为' + type + '格式');
    
    // 模拟导出完成
    setTimeout(() => {
        showToast('数据导出完成');
    }, 1500);
}

// 搜索功能
function searchFiles(query) {
    console.log('Searching files for:', query);
    // 实际应用中这里会过滤文件列表
}

// 排序功能
function sortFiles(criteria) {
    console.log('Sorting files by:', criteria);
    // 实际应用中这里会重新排序文件列表
}

// 筛选功能
function filterFiles(filter) {
    console.log('Filtering files by:', filter);
    // 实际应用中这里会筛选文件列表
}
