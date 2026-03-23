// hooks/useGesture.ts
// 手势处理钩子（缩放、拖拽）

import { useState, useCallback, useRef } from 'react';
import type { TransformState, GestureState } from '../types';

interface UseGestureOptions {
  onTransformChange?: (transform: TransformState) => void;
  minScale?: number;
  maxScale?: number;
}

interface UseGestureReturn {
  transform: TransformState;
  gestureState: GestureState;
  onPointerDown: (e: React.PointerEvent) => void;
  onPointerMove: (e: React.PointerEvent) => void;
  onPointerUp: (e: React.PointerEvent) => void;
  onWheel: (e: React.WheelEvent) => void;
  setTransform: (transform: TransformState) => void;
}

export const useGesture = (options: UseGestureOptions = {}): UseGestureReturn => {
  const {
    onTransformChange,
    minScale = 0.5,
    maxScale = 5
  } = options;

  const [transform, setTransformState] = useState<TransformState>({
    scale: 1,
    translateX: 0,
    translateY: 0,
    rotate: 0
  });

  const gestureState = useRef<GestureState>({
    isDragging: false,
    startX: 0,
    startY: 0,
    lastTranslateX: 0,
    lastTranslateY: 0
  });

  const [gestureStateForRender, setGestureStateForRender] = useState<GestureState>(gestureState.current);

  const setTransform = useCallback((newTransform: TransformState) => {
    const clampedTransform = {
      ...newTransform,
      scale: Math.max(minScale, Math.min(maxScale, newTransform.scale))
    };
    setTransformState(clampedTransform);
    onTransformChange?.(clampedTransform);
  }, [minScale, maxScale, onTransformChange]);

  const onPointerDown = useCallback((e: React.PointerEvent) => {
    e.preventDefault();
    (e.target as Element).setPointerCapture(e.pointerId);
    
    gestureState.current = {
      isDragging: true,
      startX: e.clientX,
      startY: e.clientY,
      lastTranslateX: transform.translateX,
      lastTranslateY: transform.translateY
    };
    setGestureStateForRender(gestureState.current);
  }, [transform.translateX, transform.translateY]);

  const onPointerMove = useCallback((e: React.PointerEvent) => {
    if (!gestureState.current.isDragging) return;
    e.preventDefault();

    const deltaX = e.clientX - gestureState.current.startX;
    const deltaY = e.clientY - gestureState.current.startY;

    setTransformState(prev => ({
      ...prev,
      translateX: gestureState.current.lastTranslateX + deltaX,
      translateY: gestureState.current.lastTranslateY + deltaY
    }));
  }, []);

  const onPointerUp = useCallback((e: React.PointerEvent) => {
    e.preventDefault();
    (e.target as Element).releasePointerCapture(e.pointerId);
    
    gestureState.current.isDragging = false;
    setGestureStateForRender(gestureState.current);

    // 更新最后的位置
    gestureState.current.lastTranslateX = transform.translateX;
    gestureState.current.lastTranslateY = transform.translateY;
  }, [transform.translateX, transform.translateY]);

  const onWheel = useCallback((e: React.WheelEvent) => {
    e.preventDefault();
    
    const delta = e.deltaY > 0 ? -0.1 : 0.1;
    const newScale = Math.max(minScale, Math.min(maxScale, transform.scale + delta));

    setTransformState(prev => ({
      ...prev,
      scale: newScale
    }));
  }, [transform.scale, minScale, maxScale]);

  return {
    transform,
    gestureState: gestureStateForRender,
    onPointerDown,
    onPointerMove,
    onPointerUp,
    onWheel,
    setTransform
  };
};
