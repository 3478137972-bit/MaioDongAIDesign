// ImageViewer.tsx
// 核心图片查看器组件

import React, { useState, useCallback, useMemo, useEffect } from 'react';
import { useImageLoader } from './hooks/useImageLoader';
import { useGesture } from './hooks/useGesture';
import { useKeyboard } from './hooks/useKeyboard';
import { Toolbar } from './subcomponents/Toolbar';
import { Thumbnail } from './subcomponents/Thumbnail';
import { LoadingSpinner } from './subcomponents/LoadingSpinner';
import { ErrorPlaceholder } from './subcomponents/ErrorPlaceholder';
import type { ImageViewerProps, TransformState } from './types';
import './ImageViewer.css';

export const ImageViewer: React.FC<ImageViewerProps> = ({
  images,
  initialIndex = 0,
  showThumbnails = true,
  showToolbar = true,
  lazyLoad = true,
  onImageChange,
  className = ''
}) => {
  const [currentIndex, setCurrentIndex] = useState(initialIndex);
  const [isFullscreen, setIsFullscreen] = useState(false);

  // 图片加载状态管理
  const { loadedImages, loadingStates, loadError, loadImage } = useImageLoader(images, lazyLoad);

  // 手势处理（缩放、拖拽）
  const { transform, setTransform, onPointerDown, onPointerMove, onPointerUp, onWheel } = useGesture({
    minScale: 0.5,
    maxScale: 5,
    onTransformChange: (t) => console.log('Transform changed:', t)
  });

  // 当前图片
  const currentImage = useMemo(() => images[currentIndex], [images, currentIndex]);

  // 切换图片
  const handleImageChange = useCallback((index: number) => {
    if (index < 0 || index >= images.length) return;
    setCurrentIndex(index);
    setTransform({ scale: 1, translateX: 0, translateY: 0, rotate: 0 });
    onImageChange?.(index, images[index]);
    // 预加载新图片
    loadImage(index);
  }, [images, onImageChange, setTransform, loadImage]);

  // 导航
  const handlePrev = useCallback(() => {
    handleImageChange(currentIndex - 1);
  }, [currentIndex, handleImageChange]);

  const handleNext = useCallback(() => {
    handleImageChange(currentIndex + 1);
  }, [currentIndex, handleImageChange]);

  // 缩放控制
  const handleZoomIn = useCallback(() => {
    setTransform({ ...transform, scale: Math.min(transform.scale + 0.5, 5) });
  }, [transform, setTransform]);

  const handleZoomOut = useCallback(() => {
    setTransform({ ...transform, scale: Math.max(transform.scale - 0.5, 0.5) });
  }, [transform, setTransform]);

  const handleReset = useCallback(() => {
    setTransform({ scale: 1, translateX: 0, translateY: 0, rotate: 0 });
  }, [setTransform]);

  // 全屏控制
  const handleFullscreen = useCallback(() => {
    if (!document.fullscreenElement) {
      const container = document.querySelector('.image-viewer-container');
      if (container) {
        container.requestFullscreen().catch(console.error);
      }
      setIsFullscreen(true);
    } else {
      document.exitFullscreen().catch(console.error);
      setIsFullscreen(false);
    }
  }, []);

  // 监听全屏状态变化
  useEffect(() => {
    const handleFullscreenChange = () => {
      setIsFullscreen(!!document.fullscreenElement);
    };

    document.addEventListener('fullscreenchange', handleFullscreenChange);
    return () => document.removeEventListener('fullscreenchange', handleFullscreenChange);
  }, []);

  // 键盘导航
  useKeyboard({
    onNavigate: (dir) => {
      if (dir === 'prev') handlePrev();
      else handleNext();
    },
    onZoomIn: handleZoomIn,
    onZoomOut: handleZoomOut,
    onReset: handleReset,
    onFullscreen: handleFullscreen,
    onClose: () => {
      if (isFullscreen) {
        document.exitFullscreen().catch(console.error);
      }
    }
  });

  // 重试加载
  const handleRetry = useCallback(() => {
    loadImage(currentIndex);
  }, [currentIndex, loadImage]);

  if (!images || images.length === 0) {
    return (
      <div className="image-viewer-empty">
        <div>暂无图片</div>
      </div>
    );
  }

  return (
    <div 
      className={`image-viewer-container ${className} ${isFullscreen ? 'fullscreen' : ''}`}
      role="region"
      aria-label="图片查看器"
    >
      {/* 主显示区域 */}
      <div 
        className="image-display-area"
        onPointerDown={onPointerDown}
        onPointerMove={onPointerMove}
        onPointerUp={onPointerUp}
        onWheel={onWheel}
        style={{
          cursor: transform.scale > 1 ? 'grab' : 'default'
        }}
      >
        <div
          className="image-wrapper"
          style={{
            transform: `scale(${transform.scale}) translate(${transform.translateX / transform.scale}px, ${transform.translateY / transform.scale}px)`,
            transition: transform.scale === 1 ? 'transform 0.2s ease' : 'none'
          }}
        >
          {currentImage && (
            <>
              <img
                src={currentImage.url}
                alt={currentImage.alt || '图片'}
                className="main-image"
                draggable={false}
                loading="lazy"
              />
              {currentImage.caption && (
                <div className="image-caption">{currentImage.caption}</div>
              )}
            </>
          )}
        </div>

        {/* 加载状态 */}
        {loadingStates[currentIndex] && <LoadingSpinner />}

        {/* 错误状态 */}
        {loadError[currentIndex] && (
          <ErrorPlaceholder onRetry={handleRetry} />
        )}
      </div>

      {/* 工具栏 */}
      {showToolbar && (
        <Toolbar
          zoom={transform.scale}
          onZoomIn={handleZoomIn}
          onZoomOut={handleZoomOut}
          onReset={handleReset}
          onFullscreen={handleFullscreen}
          onPrev={handlePrev}
          onNext={handleNext}
          currentIndex={currentIndex}
          totalImages={images.length}
          isFullscreen={isFullscreen}
        />
      )}

      {/* 缩略图 */}
      {showThumbnails && images.length > 1 && (
        <Thumbnail
          images={images}
          currentIndex={currentIndex}
          onSelect={handleImageChange}
        />
      )}

      {/* 快捷键提示 */}
      <div className="keyboard-hints">
        <span>← → 导航</span>
        <span>+ - 缩放</span>
        <span>0 重置</span>
        <span>F 全屏</span>
        <span>Esc 退出</span>
      </div>
    </div>
  );
};
