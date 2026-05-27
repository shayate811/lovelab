# argocd/

Ansible が ArgoCD を一度だけインストールした後、クラスタ上のアドオン管理はここに移譲する。

## 責務の境界

```
Ansible （ここまで）
  ├── OS 設定（swap off, sysctl, kernel modules）
  ├── containerd インストール
  ├── kubeadm / kubelet / kubectl インストール
  ├── kubeadm init + Cilium CNI   ← CNI は鶏卵問題のため Ansible のまま
  ├── worker join
  └── ArgoCD インストール          ← ここで Ansible の仕事は終わり

ArgoCD （ここから）
  ├── argocd/apps/ 以下の Application マニフェストを監視
  └── クラスタ上のアドオンを Git = 真実として同期
```

## アドオンを追加するとき

`argocd/apps/` に Application マニフェストを追加して push するだけ。
ArgoCD が自動で検知してクラスタに適用する。

## apps/ に追加予定のアドオン

| アドオン | 用途 |
|---------|------|
| metrics-server | kubectl top / HPA |
| ingress-nginx | L7 ルーティング |
| cert-manager | TLS 証明書の自動発行 |
| longhorn | 永続ストレージ（NAS 直結と併用） |
| prometheus-stack | メトリクス・アラート |
