// subcomponents/Toolbar.tsx
// 工具栏组件

import React from 'react';
import './Toolbar.css';

interface ToolbarProps {
  zoom: number;
  onZoomIn: () => void;
  onZoomOut: () => void;
  onReset: () => void;
  onFullscreen: () => void;
  onPrev: () => void;
  onNext: () => void;
  currentIndex: number;
  totalImages: number;
  isFullscreen: boolean;
}

export const Toolbar: React.FC<ToolbarProps> = ({
  zoom,
  onZoomIn,
  onZoomOut,
  onReset,
  onFullscreen,
  onPrev,
  onNext,
  currentIndex,
  totalImages,
  isFullscreen
}) => {
  return (
    <div className="image-viewer-toolbar">
      <div className="toolbar-group">
        <button 
          className="toolbar-btn" 
          onClick={onPrev}
          disabled={currentIndex === 0}
          title="上一张 (←/↑)"
        >
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M15.41 7.41L14 6l-6 6 6 6 1.41-1.41L10.83 12z"/>
          </svg>
        </button>
        <span className="toolbar-text">
          {currentIndex + 1} / {totalImages}
        </span>
        <button 
          className="toolbar-btn" 
          onClick={onNext}
          disabled={currentIndex === totalImages - 1}
          title="下一张 (→/↓)"
        >
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/>
          </svg>
        </button>
      </div>

      <div className="toolbar-group">
        <button 
          className="toolbar-btn" 
          onClick={onZoomOut}
          title="缩小 (-)"
        >
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M19 13H5v-2h14v2z"/>
          </svg>
        </button>
        <span className="toolbar-text zoom-level">
          {Math.round(zoom * 100)}%
        </span>
        <button 
          className="toolbar-btn" 
          onClick={onZoomIn}
          title="放大 (+)"
        >
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z"/>
          </svg>
        </button>
        <button 
          className="toolbar-btn" 
          onClick={onReset}
          title="重置 (0)"
        >
          <svg viewBox="0 0 24 24" width="20" height="20">
            <path fill="currentColor" d="M12 5V1L7 6l5 5V7c3.31 0 6 2.69 6 6s-2.69 6-6 6-6-2.69-6-6H4c0 4.42 3.58 8 8 8s8-3.58 8-8-3.58-8-8-8z"/>
          </svg>
        </button>
      </div>

      <div className="toolbar-group">
        <button 
          className="toolbar-btn" 
          onClick={onFullscreen}
          title={isFullscreen ? '退出全屏 (Esc)' : '全屏 (F)'}
        >
          {isFullscreen ? (
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M5 16h3v3h2v-5H5v2zm3-8H5v2h5V5H8v3zm6 11h2v-3h3v-2h-5v5zm2-11V5h-2v5h5V8h-3z"/>
            </svg>
          ) : (
            <svg viewBox="0 0 24 24" width="20" height="20">
              <path fill="currentColor" d="M7 14H5v5h5v-2H7v-3zm-2-4h2V7h3V5H5v5zm12 7h-3v2h5v-5h-2v3zM14 5v2h3v3h2V5h-5z"/>
            </svg>
          )}
        </button>
      </div>
    </div>
  );
};
