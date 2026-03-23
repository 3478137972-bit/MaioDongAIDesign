// hooks/useKeyboard.ts
// 键盘事件处理钩子

import { useEffect, useCallback } from 'react';

interface UseKeyboardOptions {
  onNavigate?: (direction: 'prev' | 'next') => void;
  onZoomIn?: () => void;
  onZoomOut?: () => void;
  onReset?: () => void;
  onFullscreen?: () => void;
  onClose?: () => void;
}

export const useKeyboard = (options: UseKeyboardOptions) => {
  const {
    onNavigate,
    onZoomIn,
    onZoomOut,
    onReset,
    onFullscreen,
    onClose
  } = options;

  useEffect(() => {
    const handleKeyDown = (e: KeyboardEvent) => {
      // 防止默认行为
      if (['ArrowLeft', 'ArrowRight', 'ArrowUp', 'ArrowDown', '+', '-', '=', '0', 'f', 'F', 'Escape'].includes(e.key)) {
        e.preventDefault();
      }

      switch (e.key) {
        // 导航
        case 'ArrowLeft':
        case 'ArrowUp':
          onNavigate?.('prev');
          break;
        case 'ArrowRight':
        case 'ArrowDown':
          onNavigate?.('next');
          break;

        // 缩放
        case '+':
        case '=':
          onZoomIn?.();
          break;
        case '-':
        case '_':
          onZoomOut?.();
          break;
        case '0':
          onReset?.();
          break;

        // 全屏
        case 'f':
        case 'F':
          onFullscreen?.();
          break;

        // 关闭
        case 'Escape':
          onClose?.();
          break;
      }
    };

    document.addEventListener('keydown', handleKeyDown);
    return () => document.removeEventListener('keydown', handleKeyDown);
  }, [onNavigate, onZoomIn, onZoomOut, onReset, onFullscreen, onClose]);
};
