// subcomponents/Thumbnail.tsx
// 缩略图组件

import React from 'react';
import './Thumbnail.css';
import type { ImageItem } from '../types';

interface ThumbnailProps {
  images: ImageItem[];
  currentIndex: number;
  onSelect: (index: number) => void;
}

export const Thumbnail: React.FC<ThumbnailProps> = ({
  images,
  currentIndex,
  onSelect
}) => {
  return (
    <div className="thumbnail-container">
      <div className="thumbnail-list">
        {images.map((image, index) => (
          <div
            key={image.id}
            className={`thumbnail-item ${index === currentIndex ? 'active' : ''}`}
            onClick={() => onSelect(index)}
            role="button"
            tabIndex={0}
            onKeyDown={(e) => {
              if (e.key === 'Enter' || e.key === ' ') {
                e.preventDefault();
                onSelect(index);
              }
            }}
            aria-label={`查看图片 ${index + 1}: ${image.alt || ''}`}
            aria-current={index === currentIndex ? 'true' : undefined}
          >
            <img
              src={image.thumbnailUrl || image.url}
              alt={image.alt || `图片 ${index + 1}`}
              loading="lazy"
            />
            {image.caption && (
              <div className="thumbnail-caption">{image.caption}</div>
            )}
          </div>
        ))}
      </div>
    </div>
  );
};
