# aws-2tier-portfolio

# AWS 2-Tier Architecture Portfolio

## 概要
AWS上にWebサーバーとDBサーバーを分離した2層構成のインフラをTerraformで構築。

---

## 使用技術
- AWS (VPC / EC2 / RDS / Subnet / Security Group / IGW)
- Terraform
- MySQL 8.0
- Linux（Amazon Linux 2）

---

## アーキテクチャ構成
- Public Subnet：EC2（Webサーバ）
- Private Subnet：RDS（DB）
- Internet Gateway経由で外部アクセス
- Security Groupで通信制御

---

## 構成図
（ここに画像を入れる）

---

## 構築手順
1. VPC作成
2. Subnet作成（Public / Private）
3. Internet Gateway作成
4. Route Table設定
5. EC2構築
6. RDS構築
7. EC2 → RDS接続確認

---

## 工夫した点
- TerraformによるIaC化
- セキュリティグループで最小権限設計
- RDSをPrivate Subnetに配置し外部非公開
- 変数化による再利用性向上

---

## 苦労した点
- RDSの構成変更による再作成挙動の理解
- Terraformのstate管理

---

## 今後の改善
- ALB追加（3層構成化）
- CloudWatch導入
- Terraform module化
- CI/CD（GitHub Actions）

---

## 作成者
クラウドインフラ学習中（LinuC / AWS / Terraform）
