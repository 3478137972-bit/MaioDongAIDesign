// RechargeModal.jsx - 积分充值页面组件
import React, { useState } from 'react';
import './RechargeModal.css';

function RechargeModal({ isOpen, onClose, wechatQR, wechatId = 'your_wechat_id' }) {
  const [copied, setCopied] = useState(false);
  const [qrLoaded, setQrLoaded] = useState(false);
  const [qrError, setQrError] = useState(false);

  // 复制微信号
  const copyWechatId = () => {
    navigator.clipboard.writeText(wechatId);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  if (!isOpen) return null;

  return (
    <div className="modal-overlay" onClick={onClose}>
      <div className="modal-content" onClick={(e) => e.stopPropagation()}>
        {/* 头部 */}
        <div className="modal-header">
          <h2>💰 积分充值</h2>
          <button className="close-btn" onClick={onClose}>×</button>
        </div>

        {/* 重要提示 */}
        <div className="alert-box">
          <div className="alert-icon">⚠️</div>
          <div className="alert-content">
            <strong>重要提示</strong>
            <p>请先联系客服确认后再扫码充值！</p>
          </div>
        </div>

        {/* 客服联系方式 */}
        <div className="contact-section">
          <p className="contact-label">客服微信：</p>
          <div className="contact-info">
            <code className="wechat-id">{wechatId}</code>
            <button 
              className={`copy-btn ${copied ? 'copied' : ''}`}
              onClick={copyWechatId}
            >
              {copied ? '✓ 已复制' : '📋 复制'}
            </button>
          </div>
          <p className="contact-hint">（二维码失效时可搜索添加）</p>
        </div>

        {/* 二维码区域 */}
        <div className="qr-section">
          {!qrError ? (
            <img
              src={wechatQR}
              alt="客服微信二维码"
              className={`qr-code ${qrLoaded ? 'loaded' : ''}`}
              style={{ width: '200px', height: '200px' }}
              onLoad={() => setQrLoaded(true)}
              onError={() => {
                setQrError(true);
                setQrLoaded(true);
              }}
            />
          ) : (
            <div className="qr-error-fallback">
              <p>二维码加载失败</p>
              <p>请搜索微信号：<strong>{wechatId}</strong></p>
            </div>
          )}
          <p className="qr-hint">📱 扫码添加客服微信</p>
        </div>

        {/* 充值步骤 */}
        <div className="steps-section">
          <h4>📋 充值步骤</h4>
          <ol className="steps-list">
            <li>
              <span className="step-icon">👤</span>
              <span>添加客服微信</span>
            </li>
            <li>
              <span className="step-icon">💬</span>
              <span>发送"充值 XX 元"确认金额</span>
            </li>
            <li>
              <span className="step-icon">💳</span>
              <span>扫码支付并发送凭证</span>
            </li>
            <li>
              <span className="step-icon">✅</span>
              <span>客服确认，积分到账</span>
            </li>
          </ol>
        </div>

        {/* 充值比例 */}
        <div className="rate-section">
          <h4>💹 充值比例</h4>
          <table className="rate-table">
            <thead>
              <tr>
                <th>充值金额</th>
                <th>获得积分</th>
              </tr>
            </thead>
            <tbody>
              <tr><td>10 元</td><td>100 积分</td></tr>
              <tr><td>50 元</td><td>500 积分</td></tr>
              <tr><td>100 元</td><td>1000 积分</td></tr>
              <tr><td>200 元</td><td>2000 积分</td></tr>
            </tbody>
          </table>
          <p className="bonus-hint">🎉 首次充值额外赠送 20%！</p>
        </div>

        {/* 注意事项 */}
        <div className="notes-section">
          <h4>⚠️ 注意事项</h4>
          <ul className="notes-list">
            <li>务必先联系客服确认后再充值</li>
            <li>保留好支付凭证截图</li>
            <li>积分到账后会有系统通知</li>
            <li>如遇问题，请提供支付凭证联系客服</li>
          </ul>
        </div>

        {/* 服务时间 */}
        <div className="time-section">
          <p>⏰ 服务时间：工作日 9:00-18:00，周末 10:00-16:00</p>
          <p>🌙 非工作时间充值，次日处理</p>
        </div>

        {/* 底部按钮 */}
        <div className="modal-actions">
          <button className="btn-primary" onClick={() => window.location.href = '/recharge-records'}>
            📋 查看充值记录
          </button>
          <button className="btn-secondary" onClick={onClose}>
            关闭
          </button>
        </div>
      </div>
    </div>
  );
}

export default RechargeModal;
