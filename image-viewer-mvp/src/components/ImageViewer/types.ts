// ImageViewer 类型定义

export interface ImageItem {
  id: string | number;
  url: string;
  alt?: string;
  caption?: string;
  thumbnailUrl?: string;
}

export interface ImageViewerProps {
  images: ImageItem[];
  initialIndex?: number;
  showThumbnails?: boolean;
  showToolbar?: boolean;
  lazyLoad?: boolean;
  onImageChange?: (index: number, image: ImageItem) => void;
  className?: string;
}

export interface TransformState {
  scale: number;
  translateX: number;
  translateY: number;
  rotate: number;
}

export interface GestureState {
  isDragging: boolean;
  startX: number;
  startY: number;
  lastTranslateX: number;
  lastTranslateY: number;
}
