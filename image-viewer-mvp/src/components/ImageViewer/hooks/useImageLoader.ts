// hooks/useImageLoader.ts
// 图片加载状态管理

import { useState, useEffect, useCallback } from 'react';
import type { ImageItem } from '../types';

interface UseImageLoaderReturn {
  loadedImages: Record<number, boolean>;
  loadingStates: Record<number, boolean>;
  loadError: Record<number, boolean>;
  loadImage: (index: number) => void;
}

export const useImageLoader = (
  images: ImageItem[],
  lazyLoad: boolean = true
): UseImageLoaderReturn => {
  const [loadedImages, setLoadedImages] = useState<Record<number, boolean>>({});
  const [loadingStates, setLoadingStates] = useState<Record<number, boolean>>({});
  const [loadError, setLoadError] = useState<Record<number, boolean>>({});

  const loadImage = useCallback((index: number) => {
    if (index < 0 || index >= images.length) return;
    if (loadedImages[index] || loadingStates[index]) return;

    setLoadingStates(prev => ({ ...prev, [index]: true }));

    const img = new Image();
    img.onload = () => {
      setLoadedImages(prev => ({ ...prev, [index]: true }));
      setLoadingStates(prev => ({ ...prev, [index]: false }));
    };
    img.onerror = () => {
      setLoadError(prev => ({ ...prev, [index]: true }));
      setLoadingStates(prev => ({ ...prev, [index]: false }));
    };
    img.src = images[index].url;
  }, [images, loadedImages, loadingStates]);

  useEffect(() => {
    if (!lazyLoad) {
      // 加载所有图片
      images.forEach((_, index) => loadImage(index));
    } else {
      // 懒加载：预加载当前和前后各 2 张
      const preloadRange = 2;
      for (let i = Math.max(0, 0 - preloadRange); 
           i < Math.min(images.length, 0 + preloadRange + 1); i++) {
        loadImage(i);
      }
    }
  }, []);

  return { loadedImages, loadingStates, loadError, loadImage };
};
