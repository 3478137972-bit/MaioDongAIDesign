// subcomponents/LoadingSpinner.tsx
// 加载动画组件

import React from 'react';
import './LoadingSpinner.css';

export const LoadingSpinner: React.FC = () => {
  return (
    <div className="loading-spinner">
      <div className="spinner"></div>
      <div className="loading-text">加载中...</div>
    </div>
  );
};
